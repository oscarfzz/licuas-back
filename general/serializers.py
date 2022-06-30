from rest_framework import serializers
from general.models import *
from drf_base64.serializers import ModelSerializer
from django.conf import settings
from django.utils.translation import gettext_lazy as _
import os


class ZonaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Zona
        fields = '__all__'


class GrupoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Grupo
        fields = '__all__'


class ActividadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actividad
        fields = '__all__'


class SituacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Situacion
        fields = '__all__'


class AmbitoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ambito
        fields = '__all__'


class ClasificacionGtoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Clasificacion_gto
        fields = '__all__'


class EmpresaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Empresa
        fields = '__all__'


class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = ('__all__')


class AmpliacionPresupuestoObraSerializer(serializers.ModelSerializer):
    class Meta:
        model = AmpliacionPresupuestoObra
        fields = '__all__'


class AmpliacionCosteObraSerializer(serializers.ModelSerializer):
    class Meta:
        model = AmpliacionCosteObra
        fields = '__all__'


class ObraSerializer(serializers.ModelSerializer):
    empresa_descripcion = serializers.SerializerMethodField(read_only=True)
    cliente_descripcion = serializers.SerializerMethodField(read_only=True)
    zona_descripcion = observaciones = serializers.CharField(
        source='zona.nombre', read_only=True)
    ambito_descripcion = observaciones = serializers.CharField(
        source='ambito.nombre', read_only=True)
    grupo_descripcion = observaciones = serializers.CharField(
        source='grupo.nombre', read_only=True)
    actividad_descripcion = observaciones = serializers.CharField(
        source='actividad.nombre', read_only=True)
    situacion_descripcion = observaciones = serializers.CharField(
        source='situacion.nombre', read_only=True)
    clasificacion_descripcion = observaciones = serializers.CharField(
        source='clasificacion.nombre', read_only=True)
    divisa_descripcion = observaciones = serializers.CharField(
        source='divisa.codigo', read_only=True)
    delegacion = serializers.SerializerMethodField(read_only=True)
    subdelegacion = serializers.SerializerMethodField(read_only=True)
    delegacion_descripcion = serializers.SerializerMethodField(read_only=True)
    class Meta:
        model = Obra
        fields = '__all__'
        extra_kwargs = {
            'participacion_licuas': {'max_digits': 14, 'decimal_places': 2}
        }

    def get_empresa_descripcion(self, obj):
        return str(obj.empresa)

    def get_cliente_descripcion(self, obj):
        return str(obj.cliente)

    def get_delegacion(self, obj):
        return str(obj.delegacion.id)

    def get_delegacion_descripcion(self, obj):
        return str(obj.delegacion)

    def get_subdelegacion(self, obj):
        return str(obj.subdelegacion)

class ObraDetalleSerializer(serializers.ModelSerializer):
    ampliaciones_presupuesto = AmpliacionPresupuestoObraSerializer(
        many=True, read_only=True)
    ampliaciones_coste = AmpliacionCosteObraSerializer(
        many=True, read_only=True)

    empresa_descripcion = serializers.SerializerMethodField(read_only=True)
    cliente_descripcion = serializers.SerializerMethodField(read_only=True)

    def get_empresa_descripcion(self, obj):
        return str(obj.empresa)

    def get_cliente_descripcion(self, obj):
        return str(obj.cliente)

    class Meta:
        model = Obra
        fields = '__all__'


class EmpleadoSerializer(serializers.ModelSerializer):
    texto = serializers.SerializerMethodField()

    class Meta:
        model = Empleado
        fields = ('id', 'codigo', 'responsable', 'usuario', 'texto')

    def get_texto(self, obj):
        usuario = '{} {}'.format(obj.usuario.first_name, obj.usuario.last_name)

        responsable = _('Sin asignar')

        if obj.responsable:
            responsable = '{} {}'.format(
                obj.responsable.first_name, obj.responsable.last_name)

        return '{} ({})'.format(usuario, responsable)


class ResponsableSerializer(serializers.ModelSerializer):
    nombre = serializers.SerializerMethodField(read_only=True)
    grupos = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = User
        fields = ('id', 'nombre', 'grupos')

    def get_nombre(self, obj):
        return '{} {}'.format(obj.first_name, obj.last_name)

    def get_grupos(self, obj):
        lista_grupos = obj.groups.filter(id__in=(1, 2, 3))

        return ', '.join(map(str, lista_grupos))


class CambioDivisaSerializer(serializers.ModelSerializer):
    divisa_descripcion = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = CambioDivisa
        fields = "__all__"

    def get_divisa_descripcion(self, obj):
        return obj.divisa.descripcion


class UnidadOrganizativaSerializer(serializers.ModelSerializer):
    class Meta:
        model = UnidadOrganizativa
        fields = "__all__"


class ParametroUnidadOrganizativaSerializer(serializers.ModelSerializer):
    delegacion = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = ParametroUnidadOrganizativa

        fields = ["id", "year", "cuarto", "gasto_delegacion",
                  "gasto_central", "unidad", "delegacion"]

    def get_delegacion(self, obj):
        return obj.unidad.padre.id


class ParametroUnidadOrganizativaSerializerReadOnly(serializers.ModelSerializer):
    unidad = serializers.CharField(
        source='unidad.descripcion', read_only=True)

    class Meta:
        model = ParametroUnidadOrganizativa

        fields = "__all__"
