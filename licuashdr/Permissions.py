from rest_framework import permissions
from django.http import Http404
from django.core import exceptions


class BasePermissions(permissions.DjangoModelPermissions):

    perms_map = {
        'GET': ['%(app_label)s.view_%(model_name)s'],
        'OPTIONS': ['%(app_label)s.view_%(model_name)s'],
        'HEAD': ['%(app_label)s.view_%(model_name)s'],
        'POST': ['%(app_label)s.add_%(model_name)s'],
        'PUT': ['%(app_label)s.change_%(model_name)s'],
        'PATCH': ['%(app_label)s.change_%(model_name)s'],
        'DELETE': ['%(app_label)s.delete_%(model_name)s'],
    }

    def get_required_object_permissions(self, method, model_cls):
        kwargs = {
            'app_label': model_cls._meta.app_label,
            'model_name': model_cls._meta.model_name
        }
        if method not in self.perms_map:
            raise exceptions.MethodNotAllowed(method)

        return [perm % kwargs for perm in self.perms_map[method]]

    def has_permission(self, request, view):
        queryset = self._queryset(view)
        model_cls = queryset.model
        user = request.user
        perms = self.get_required_object_permissions(request.method, model_cls)

        if not user.has_perms(perms):
            return False

        return True

    def has_permission_model(self, request, model_cls):

        perms = self.get_required_object_permissions(
            request.method, model_cls)
        user = request.user
        if not user.has_perms(perms):
            return False
        return True


class HojaDeRutaPermisos(BasePermissions):
    def has_object_permission(self, request, view, obj):
        for usuario in obj.obra.responsables:
            if usuario == request.user:
                return True
            for subordinado in request.user.subordinados:
                if usuario == subordinado:
                    return True
        return False


class PerfilAdministrador(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.groups.filter(id=1).exists()


class PerfilResponsable(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.groups.filter(id=2).exists()


class PerfilJefeDeObra(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.groups.filter(id=3).exists()


class TienePerfil(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.groups.filter(id__in=[1, 2, 3]).exists()


class ResponsableObraHDR(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        for responsable in obj.obra.responsables.all():
            if responsable == request.user:
                return True
        return False


class ResponsableOSubditosRespoObraHDR(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):

        if request.user.groups.filter(pk=1):
            return True

        responsables = None
        if hasattr(obj, "obra"):
            responsables = obj.obra.responsables.all()
        elif hasattr(obj, "hoja"):
            responsables = obj.hoja.obra.responsables.all()

        for responsable in responsables:
            if responsable == request.user:
                return True
            else:
                for subordinado in request.user.subordinados.all().select_related('usuario'):
                    if responsable == subordinado.usuario:
                        return True
                    elif responsable.empleado.responsable == subordinado.usuario:
                        return True
        
        return False


class AdminOResponsableOSubditosRespoObraHDR(ResponsableOSubditosRespoObraHDR):
    def has_object_permission(self, request, view, obj):
        if request.user.groups.filter(id=1).exists():
            return True
        return super().has_object_permission(request, view, obj)
