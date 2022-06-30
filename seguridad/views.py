
from django.contrib.auth.models import User, Group, Permission
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import permissions
from seguridad.serializers import GroupSerializer, UserSerializer, ReadUserSerializer
from licuashdr.Permissions import BasePermissions


class PermisosViewSet (viewsets.ReadOnlyModelViewSet):

    queryset = Permission.objects.all()

    def list(self, *args, **kwargs):
        permissions = self.request.user.get_all_permissions()
        for grupo in self.request.user.groups.all():
            permissions.add(grupo.name)
        return Response(permissions)


class UserViewSet(viewsets.ModelViewSet):
    """
    Endpoint que permite editar y visualizar los usuarios
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = (BasePermissions,)

    def list(self, request):
        usuarios = User.objects.select_related('empleado').prefetch_related('groups')
        serializer = ReadUserSerializer(usuarios, many=True)
        return Response(serializer.data)


class GroupViewSet(viewsets.ModelViewSet):
    """
    Endpoint que permite editar y visualizar los grupos
    """
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    permission_classes = (BasePermissions,)
