from django.shortcuts import render
from rest_framework import viewsets, permissions
from rest_framework.views import APIView

from rest_framework.decorators import action, authentication_classes, permission_classes
from rest_framework.response import Response
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import IsAuthenticated
from django.utils.translation import gettext_lazy as _
from rest_framework import status
from django.views.generic import View
from django.shortcuts import render

from licuashdr.CustomError import CustomError
from licuashdr.Permissions import BasePermissions, TienePerfil
from general.serializers import *
from general.models import *

from divisas.models import Divisa
from divisas.serializers import DivisaSerializer
from django.db import models

from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from hdr.util import hdrCSVImport
from rest_framework import permissions


@api_view(["POST", ])
@permission_classes([permissions.IsAuthenticated, ])
def importar_csv(request):
    if "archivo" in request.data and "year" in request.data and "cuatrimestre" in request.data:
        archivo = request.data.get("archivo")
        year = request.data.get("year")
        cuatrimestre = request.data.get("cuatrimestre")
        limpiar = request.data.get("limpiar", False)

        # Creamos el archivo temporal
        import datetime
        nombre_archivo = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f") + '.csv'
        import base64
        try:
            with open(settings.PATH_EXCEL + "/" + nombre_archivo, mode='wb') as csvfile:
                # csvfile.write(base64.decodebytes(str.encode(archivo, encoding='iso8859_15')))
                csvfile.write(str.encode(archivo, encoding='iso8859_15'))
        except Exception as error:
            # Eliminamos el archivo temporal
            import os
            try:
                os.remove(settings.PATH_EXCEL + "/" + nombre_archivo)
            except Exception as error:
                pass
            raise CustomError(_("Error al decodificar el archivo"), _(
                "Importación CSV"), status_code=status.HTTP_400_BAD_REQUEST)

        try:
            # Importamos el archivo csv
            retorno = hdrCSVImport(
                archivo=nombre_archivo, year=year, cuarto=cuatrimestre, limpiar=limpiar, usuario=request.user)
        except CustomError as error:
            raise error
        except Exception as error:
            raise CustomError(_("Error durante la importación"), _(
                "Importación CSV"), status_code=status.HTTP_400_BAD_REQUEST)
        finally:
            # Eliminamos el archivo temporal
            import os
            try:
                os.remove(settings.PATH_EXCEL + "/" + nombre_archivo)
            except Exception as error:
                raise error

        # Respuesta

        return Response(data={"estado": "ok", "resumen": retorno}, status=status.HTTP_200_OK)
    raise CustomError(_("Faltan datos para la importación"), _(
        "Importación CSV"), status_code=status.HTTP_400_BAD_REQUEST)


class ZonaViewSet(viewsets.ModelViewSet):
    queryset = Zona.objects.all()
    serializer_class = ZonaSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        zona = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("La zona no puede ser eliminada porque está referenciada") % {
                              "unidad": zona}, _("Zona"), status_code=status.HTTP_409_CONFLICT)


class GrupoViewSet(viewsets.ModelViewSet):
    queryset = Grupo.objects.all()
    serializer_class = GrupoSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        grupo = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("El grupo no puede ser eliminada porque está referenciado") % {
                              "unidad": grupo}, _("Grupo"), status_code=status.HTTP_409_CONFLICT)


class ActividadViewSet(viewsets.ModelViewSet):
    queryset = Actividad.objects.all()
    serializer_class = ActividadSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        actividad = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("La zona no puede ser eliminada porque está referenciada") % {
                              "unidad": actividad}, _("Actividad"), status_code=status.HTTP_409_CONFLICT)


class SituacionViewSet(viewsets.ModelViewSet):
    queryset = Situacion.objects.all()
    serializer_class = SituacionSerializer
    permission_classes = (TienePerfil,)

    def list(self, request):
        usuario = request.user
        if usuario.groups.filter(pk=1):
            queryset = Situacion.objects.all()
            serializer = SituacionSerializer(queryset, many=True)
            return Response(serializer.data)
        else:
            queryset = Situacion.objects.filter(obras__in=usuario.obras.all().values_list('id', flat=True)).distinct()
            serializer = SituacionSerializer(queryset, many=True)
            return Response(serializer.data)

    def destroy(self, request, *args, **kwargs):
        situacion = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("La situación no puede ser eliminada porque está referenciada") % {
                              "unidad": situacion}, _("Situación"), status_code=status.HTTP_409_CONFLICT)


class AmbitoViewSet(viewsets.ModelViewSet):
    queryset = Ambito.objects.all()
    serializer_class = AmbitoSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        ambito = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("El ámbito no puede ser eliminado porque está referenciado") % {
                              "unidad": ambito}, _("Ámbito"), status_code=status.HTTP_409_CONFLICT)


class ClasificacionGtoViewSet(viewsets.ModelViewSet):
    queryset = Clasificacion_gto.objects.all()
    serializer_class = ClasificacionGtoSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        clasificacion = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("La clasificación no puede ser eliminada porque está referenciada") % {
                              "unidad": clasificacion}, _("Clasificación"), status_code=status.HTTP_409_CONFLICT)


class EmpresaViewSet(viewsets.ModelViewSet):
    queryset = Empresa.objects.all()
    serializer_class = EmpresaSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        empresa = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("La empresa no puede ser eliminada porque está referenciada") % {
                              "unidad": empresa}, _("Empresa"), status_code=status.HTTP_409_CONFLICT)


class ClienteViewSet(viewsets.ModelViewSet):
    queryset = Cliente.objects.all()
    serializer_class = ClienteSerializer
    permission_classes = (BasePermissions,)

    def destroy(self, request, *args, **kwargs):
        cliente = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("El cliente no puede ser eliminado porque está referenciado") % {
                              "unidad": cliente}, _("Cliente"), status_code=status.HTTP_409_CONFLICT)


class ObraViewSet(viewsets.ModelViewSet):
    queryset = Obra.objects.all()
    serializer_class = ObraDetalleSerializer
    permission_classes = (TienePerfil,)

    def list(self, request):
        queryset = Obra.objects.all().select_related('cliente', 'empresa', 'divisa', 'delegacion', 'subdelegacion',
                                                     'zona', 'grupo', 'actividad', 'situacion', 'ambito', 'clasificacion').prefetch_related('responsables')
        serializer = ObraSerializer(
            queryset, context={'request': request}, many=True)
        return Response(serializer.data)

    @action(methods=['get'], detail=True,
            url_path='presupuestos', url_name='obras-presupuestos')
    def getPresupuestos(self, request, pk):
        datos = AmpliacionPresupuestoObra.objects.filter(obra_id=pk)
        serializer = AmpliacionPresupuestoObraSerializer(datos, many=True)
        return Response(serializer.data)

    @action(methods=['get'], detail=True,
            url_path='costes', url_name='obras-costes')
    def getCostes(self, request, pk):
        datos = AmpliacionCosteObra.objects.filter(obra_id=pk)
        serializer = AmpliacionCosteObraSerializer(datos, many=True)
        return Response(serializer.data)


class AmpliacionPresupuestoObraViewSet(viewsets.ModelViewSet):
    queryset = AmpliacionPresupuestoObra.objects.all()
    serializer_class = AmpliacionPresupuestoObraSerializer


class AmpliacionCosteObraViewSet(viewsets.ModelViewSet):
    queryset = AmpliacionCosteObra.objects.all()
    serializer_class = AmpliacionCosteObraSerializer


class EmpleadoViewSet(viewsets.ModelViewSet):
    queryset = Empleado.objects.all()
    serializer_class = EmpleadoSerializer
    permission_classes = (BasePermissions,)

    def retrieve(self, request, pk=None):
        queryset = Empleado.objects.select_related().filter(responsable__id=pk)
        serializer = EmpleadoSerializer(
            queryset, context={'request': request}, many=True)

        return Response(serializer.data)

    @action(methods=['get'], detail=True, url_path='empleados', url_name='usuarios-empleados')
    def getEmpleados(self, request, pk):
        grupos_incluir = []
        grupos_excluir = []

        responsable = get_object_or_404(User, pk=pk)
        es_administrador = responsable.groups.filter(id=1).exists()
        es_responsable = responsable.groups.filter(id=2).exists()

        if es_administrador or es_responsable:
            grupos_incluir = [2, 3]
            grupos_excluir = [1]
        else:
            return Response([])

        queryset = Empleado.objects.select_related().filter(
            usuario__groups__in=grupos_incluir).exclude(usuario__groups__in=grupos_excluir).distinct()

        serializer = EmpleadoSerializer(queryset, many=True)
        return Response(serializer.data)


class ResponsableViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = ResponsableSerializer
    permission_classes = (BasePermissions,)

    def list(self, request):
        responsables = User.objects.filter(groups__in=[1, 2]).distinct('id')

        serializer = ResponsableSerializer(responsables, many=True)

        return Response(serializer.data)


class UnidadOrganizativaViewSet(viewsets.ModelViewSet):
    queryset = UnidadOrganizativa.objects.all()
    serializer_class = UnidadOrganizativaSerializer
    permission_classes = (BasePermissions,)

    @action(methods=['get'], detail=True,
            url_path='parametros', url_name='unidad-parametros')
    def getParametros(self, request, pk):
        datos = ParametroUnidadOrganizativa.objects.filter(unidad_id=pk)
        serializer = ParametroUnidadOrganizativaSerializer(datos, many=True)
        return Response(serializer.data)

    def destroy(self, request, *args, **kwargs):
        unidad = self.get_object()
        try:
            return super().destroy(request, *args, **kwargs)
        except models.ProtectedError:
            raise CustomError(_("La unidad organizativa no puede ser eliminada porque tiene dependencias") % {
                              "unidad": unidad}, _("Unidad Organizativa"), status_code=status.HTTP_409_CONFLICT)

    def create(self, request, *args, **kwargs):
        unidad = request.data.get('descripcion')

        try:
            return super().create(request, *args, **kwargs)
        except ValidationError:
            raise CustomError(_("Las unidades organizativas están limitadas a 2 niveles") % {
                              "unidad": unidad}, _("Unidad Organizativa"), status_code=status.HTTP_409_CONFLICT)

    def update(self, request, *args, **kwargs):
        unidad = self.get_object().descripcion

        try:
            return super().update(request, *args, **kwargs)
        except ValidationError:
            raise CustomError(_("Las unidades organizativas están limitadas a 2 niveles") % {
                              "unidad": unidad}, _("Unidad Organizativa"), status_code=status.HTTP_409_CONFLICT)


class DivisaViewSet(viewsets.ModelViewSet):
    queryset = Divisa.objects.all()
    serializer_class = DivisaSerializer
    permission_classes = (BasePermissions,)


class CambioDivisaViewSet(viewsets.ModelViewSet):
    queryset = CambioDivisa.objects.all()
    serializer_class = CambioDivisaSerializer
    permission_classes = (BasePermissions,)


class ParametroUnidadOrganizativaViewSet(viewsets.ModelViewSet):
    queryset = ParametroUnidadOrganizativa.objects.all()
    serializer_class = ParametroUnidadOrganizativaSerializer
    permission_classes = (BasePermissions, )

    def list(self, request):
        queryset = ParametroUnidadOrganizativa.objects.all().select_related('unidad')
        serializer = ParametroUnidadOrganizativaSerializerReadOnly(
            queryset, many=True)
        return Response(serializer.data)
