from django.shortcuts import render
from rest_framework import viewsets, permissions
from django.contrib.auth.models import User
from rest_framework.response import Response
from rest_framework.decorators import action, api_view, permission_classes
# propio de la aplicacion
from licuashdr.CustomError import CustomError
from licuashdr.Permissions import BasePermissions, TienePerfil
from lista.serializers import *
from general.models import Empresa
from general.models import Cliente
from general.models import Obra
from general.models import UnidadOrganizativa
# Create your views here.


class ListaEmpresaViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Empresa.objects.all()
    serializer_class = ListaEmpresaSerializer
    permission_classes = (TienePerfil,)

    def list(self, request):
        usuario = request.user
        if usuario.groups.filter(pk=1):
            queryset = Empresa.objects.all()
            serializer = ListaEmpresaSerializer(queryset, many=True)
            return Response(serializer.data)
        else:
            queryset = Empresa.objects.filter(obras__in=usuario.obras.all().values_list('id', flat=True)).distinct()
            serializer = ListaObraSerializer(queryset, many=True)
            return Response(serializer.data)


class ListaClienteViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Cliente.objects.all()
    serializer_class = ListaClienteSerializer
    permission_classes = (BasePermissions,)


class ListaObraViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Obra.objects.all().select_related('empresa')
    serializer_class = ListaObraSerializer
    permission_classes = (TienePerfil,)

    def list(self, request):
        usuario = request.user
        if usuario.groups.filter(pk=1):
            queryset = Obra.objects.all().select_related('empresa')
            serializer = ListaObraSerializer(queryset, many=True)
            return Response(serializer.data)
        else:
            queryset = usuario.obras.all()
            serializer = ListaObraSerializer(queryset, many=True)
            return Response(serializer.data)


class ListaAdministradorViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = ListaUsuarioSerializer(queryset, many=True)
    permission_classes = (BasePermissions,)

    def list(self, request):
        queryset = User.objects.filter(groups__id=1)
        serializer = ListaUsuarioSerializer(queryset, many=True)
        return Response(serializer.data)


class ListaJefeResponsableViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = ListaUsuarioSerializer
    permission_classes = (BasePermissions,)

    def list(self, request):
        queryset = User.objects.filter(groups__id=3)
        serializer = ListaUsuarioSerializer(queryset, many=True)
        return Response(serializer.data)


class ListaResponsableViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = ListaUsuarioSerializer(queryset, many=True)
    permission_classes = (BasePermissions,)

    def list(self, request):
        queryset = User.objects.filter(groups__id=2)
        serializer = ListaUsuarioSerializer(queryset, many=True)
        return Response(serializer.data)


class ListaResponsableOJefeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = ListaUsuarioSerializer(queryset, many=True)
    permission_classes = (TienePerfil,)

    def list(self, request):
        queryset = User.objects.filter(groups__id__in=[2, 3]).order_by('first_name')
        serializer = ListaUsuarioSerializer(queryset, many=True)
        return Response(serializer.data)


class ListaSubdelegacionViewSet(viewsets.ModelViewSet):
    queryset = UnidadOrganizativa.objects.all()
    serializer_class = ListaSubdelegacionSerializer(queryset, many=True)
    permission_classes = (TienePerfil,)

    def list(self, request):
        queryset = UnidadOrganizativa.objects.exclude(padre__isnull=True)
        serializer = ListaSubdelegacionSerializer(queryset, many=True)
        return Response(serializer.data)


class ListaDelegacionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = UnidadOrganizativa.objects.all()
    serializer_class = ListaSubdelegacionSerializer(queryset, many=True)
    permission_classes = (TienePerfil,)

    def list(self, request):
        queryset = UnidadOrganizativa.objects.exclude(padre__isnull=False)
        serializer = ListaSubdelegacionSerializer(queryset, many=True)
        return Response(serializer.data)

    @action(detail=True)
    def subs(self, request, pk=None):
        padre = UnidadOrganizativa.objects.get(pk=pk)
        unidades = UnidadOrganizativa.objects.filter(padre=padre)
        serializado = ListaSubdelegacionSerializer(unidades, many=True)
        return Response(serializado.data)


@api_view(["POST", ])
@permission_classes([TienePerfil])
def delegacionesSubdelegaciones(request):
    delegaciones = request.data

    if not delegaciones:
        delegaciones = []

    padres = UnidadOrganizativa.objects.filter(pk__in=delegaciones)
    unidades = UnidadOrganizativa.objects.filter(padre__in=padres)
    serializado = ListaSubdelegacionSerializer(unidades, many=True)
    return Response(serializado.data)
