
from rest_framework import serializers
from django.contrib.auth.models import User, Group
from django.conf import settings
from drf_base64.serializers import ModelSerializer
from licuashdr.Permissions import BasePermissions
from general.models import Empleado, codigoEmpleadoRepetido
from django.contrib.auth.hashers import make_password


class GroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Group
        fields = ('id', 'name',)
        read_only_fields = ('name',)
        extra_kwargs = {
            "id": {
                "read_only": False,
                "required": False,
            },
        }


class ListaUserSerializer(serializers.ModelSerializer):
    id = serializers.SerializerMethodField()
    text = serializers.SerializerMethodField()

    def get_text(self, obj):
        return '{} {}'.format(obj.first_name, obj.last_name)

    def get_id(self, obj):
        return obj.id

    class Meta:
        model = User
        fields = ('id', 'text')


class ReadUserSerializer(serializers.ModelSerializer):
    codigo = serializers.CharField(source="empleado.codigo", required=True)
    grupo = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name',
                  'last_name',  'is_active', 'grupo', 'password', 'codigo')
    
    def get_grupo(self, obj):
        grupo = obj.groups.all().first()

        if grupo is None:
            return ""

        return grupo.name


class UserSerializer(serializers.ModelSerializer):
    codigo = serializers.CharField(source="empleado.codigo", required=True)

    class Meta:
        model = User
        fields = ('id', 'username',  'email', 'first_name',
                  'last_name',  'is_active', 'groups', 'password', 'codigo')
        extra_kwargs = {'password': {'required': False}}

    def create(self, validated_data):
        empleado = validated_data.pop("empleado")
        if "groups" in validated_data:
            grupos = validated_data.pop("groups")
        else:
            grupos = None

        # Comprobamos si el código de empleado está repetido
        codigoEmpleadoRepetido(empleado.get("codigo"))

        usuario_pass = make_password(validated_data['password'])
        validated_data['password'] = usuario_pass

        usuario = User.objects.create(**validated_data)

        if grupos:
            usuario.groups.set(grupos)
        if empleado.get("codigo", False):
            usuario.empleado.codigo = empleado.get("codigo")

        usuario.empleado.save()
        usuario.save()

        return usuario

    def update(self, usuario, datos):
        usuario.username = datos.get('username', usuario.username)
        usuario.first_name = datos.get('first_name', usuario.first_name)
        usuario.last_name = datos.get('last_name', usuario.last_name)

        if datos.get('password') != None:
            usuario.set_password(datos.get('password'))

        usuario.email = datos.get('email', usuario.email)
        usuario.is_active = datos.get('is_active', usuario.is_active)
        if "groups" in datos:
            usuario.groups.set(datos.get('groups', usuario.groups))

        usuario.empleado.codigo = datos.get(
            "empleado", None).get("codigo", None)

        usuario.empleado.save()
        usuario.save()

        return usuario
