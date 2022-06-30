from django.contrib.auth.models import User
from rest_framework import serializers

from general.models import Empresa
from general.models import Cliente
from general.models import Obra
from general.models import UnidadOrganizativa


class ListaEmpresaSerializer(serializers.ModelSerializer):
    texto = serializers.SerializerMethodField()

    class Meta:
        model = Empresa
        fields = ('id', 'texto')

    def get_texto(self, obj):
        return str(obj)


class ListaClienteSerializer(serializers.ModelSerializer):
    texto = serializers.SerializerMethodField()

    class Meta:
        model = Cliente
        fields = ('id', 'texto')

    def get_texto(self, obj):
        return str(obj)


class ListaObraSerializer(serializers.ModelSerializer):
    texto = serializers.SerializerMethodField()

    class Meta:
        model = Obra
        fields = ('id', 'texto')

    def get_texto(self, obj):
        return str(obj)


class ListaUsuarioSerializer(serializers.ModelSerializer):
    texto = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ('id', 'texto')

    def get_texto(self, obj):
        return '{} {}'.format(obj.first_name, obj.last_name)


class ListaSubdelegacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = UnidadOrganizativa
        fields = ('id', 'descripcion')
