from rest_framework import serializers
from hdr.models import HojaDeRuta, ESTADOS, HojaDeRutaProduccion, HojaDeRutaCertificacion, HojaDeRutaCobro, BI, Objetivo, HojaDeRutaPago, HojaDeRutaCapitalFinanciero


class ActualizadorHDR(serializers.ModelSerializer):
    def update(self, instance, validated_data):
        retorno = super().update(instance, validated_data)
        retorno.hoja.usuario_modificacion = self.context['request'].user
        retorno.hoja.save()
        return retorno

    def create(self, validated_data):
        retorno = super().create(validated_data)
        retorno.hoja.usuario_modificacion = self.context['request'].user
        retorno.hoja.save()
        return retorno


class HojaDeRutaProduccionSerializer(ActualizadorHDR):
    class Meta:
        model = HojaDeRutaProduccion
        fields = "__all__"


class HojaDeRutaCertificacionSerializer(ActualizadorHDR):
    class Meta:
        model = HojaDeRutaCertificacion
        fields = "__all__"
class HojaDeRutaPagoSerializer(ActualizadorHDR):
    class Meta:
        model = HojaDeRutaPago
        fields = "__all__"
class HojaDeRutaCapitalFinancieroSerializer(ActualizadorHDR):
    class Meta:
        model = HojaDeRutaCapitalFinanciero
        fields = "__all__"


class HojaDeRutaCobroSerializer(ActualizadorHDR):
    class Meta:
        model = HojaDeRutaCobro
        fields = "__all__"


class ObjetivoSerializer(ActualizadorHDR):
    class Meta:
        model = Objetivo
        fields = "__all__"


class ObjetivoIdSerializer(serializers.ModelSerializer):
    class Meta:
        model = Objetivo
        fields = ["id", ]


class BISerializer(serializers.ModelSerializer):

    class Meta:
        model = BI
        fields = "__all__"


class ReadBISerializer(serializers.ModelSerializer):
    cliente = serializers.SerializerMethodField()
    obra = serializers.SerializerMethodField()

    def get_cliente(self, obj):
        return '{}, {}'.format(obj.cliente.codigo, obj.cliente.nombre)

    def get_obra(self, obj):
        return '{}, {}'.format(obj.obra.codigo, obj.obra.descripcion)

    class Meta:
        model = BI
        fields = "__all__"


class HojaDeRutaSerializer(serializers.ModelSerializer):
    produccion = HojaDeRutaProduccionSerializer(read_only=True)
    certificacion = HojaDeRutaCertificacionSerializer(read_only=True)
    cobro = HojaDeRutaCobroSerializer(read_only=True)

    class Meta:
        model = HojaDeRuta
        # fields = "__all__"
        fields = ["id", "year", "cuarto", "fecha_fin_entrega", "estado", "gasto_delegacion", "gasto_central", "importe_contrato_anterior", "importe_contrato_consolidado", "importe_contrato_pendiente", "importe_ampliacion_anterior", "importe_ampliacion_consolidado", "importe_ampliacion_pendiente", "importe_coste_directo_anterior",
                  "importe_coste_directo_consolidado", "importe_coste_directo_pendiente", "importe_coste_delegacion_anterior", "importe_coste_delegacion_consolidado", "importe_coste_delegacion_pendiente", "importe_coste_central_anterior", "importe_coste_central_consolidado", "importe_coste_central_pendiente", "obra", "produccion", "certificacion", "cobro",
                  "periodo_cobro", "periodo_pago", "cf_acreedor", "cf_deudor"]
        depth = 2


class HojaDeRutaMiniSerializer(serializers.ModelSerializer):
    produccion = serializers.IntegerField(
        read_only=True, source='produccion.id')
    certificacion = serializers.IntegerField(
        read_only=True, source='certificacion.id')
    cobro = serializers.IntegerField(read_only=True, source='cobro.id')
    objetivos = ObjetivoIdSerializer(read_only=True, many=True)

    class Meta:
        model = HojaDeRuta
        fields = ["id", "produccion", "certificacion", "cobro", "objetivos"]


class HojaDeRutaDetalleSerializer(serializers.ModelSerializer):
    produccion = serializers.IntegerField(
        read_only=True, source='produccion.id')
    certificacion = serializers.IntegerField(
        read_only=True, source='certificacion.id')
    cobro = serializers.IntegerField(read_only=True, source='cobro.id')
    objetivos = ObjetivoSerializer(read_only=True, many=True)
    anterior = HojaDeRutaMiniSerializer(read_only=True)
    siguiente = HojaDeRutaMiniSerializer(read_only=True)

    def create(self, validated_data):
        validated_data['usuario_creacion'] = self.context['request'].user
        validated_data['usuario_modificacion'] = self.context['request'].user
        retorno = super().create(validated_data)
        return retorno

    def update(self, instance, validated_data):
        validated_data['usuario_modificacion'] = self.context['request'].user
        retorno = super().update(instance, validated_data)
        return retorno

    class Meta:
        model = HojaDeRuta
        fields = "__all__"


class ReadHojaDeRutaSerializer(serializers.ModelSerializer):
    codigo = serializers.CharField(source='obra.codigo', read_only=True)
    obra = serializers.CharField(source='obra.descripcion', read_only=True)
    empresa = serializers.CharField(source='obra.empresa', read_only=True)
    delegacion = serializers.CharField(
        source='obra.delegacion.descripcion', read_only=True)
    subdelegacion = serializers.CharField(
        source='obra.subdelegacion.descripcion', read_only=True)
    estado = serializers.SerializerMethodField()
    obra_id = serializers.IntegerField(
        read_only=True, source='obra.id')
    produccion = serializers.IntegerField(
        read_only=True, source='produccion.id')
    certificacion = serializers.IntegerField(
        read_only=True, source='certificacion.id')
    cobro = serializers.IntegerField(read_only=True, source='cobro.id')
    objetivos = ObjetivoIdSerializer(read_only=True, many=True)
    clasificacion = serializers.SerializerMethodField()
    situacion = serializers.SerializerMethodField()
    divisa = serializers.SerializerMethodField()
    participacion_licuas = serializers.SerializerMethodField()

    def get_participacion_licuas(self, obj):
        if(obj.obra.participacion_licuas == None):
            return ''
        else:
            return obj.obra.participacion_licuas

    def get_situacion(self, obj):
        if(obj.obra.situacion == None):
            return ''
        else:
            return obj.obra.situacion.nombre

    def get_clasificacion(self, obj):
        if(obj.obra.clasificacion == None):
            return ''
        else:
            return obj.obra.clasificacion.nombre

    def get_divisa(self, obj):
        if(obj.obra.divisa == None):
            return ''
        else:
            return obj.obra.divisa.codigo

    def get_estado(self, obj):
        return obj.get_estado_display()

    class Meta:
        model = HojaDeRuta
        fields = "__all__"


class DashboardSerializer(serializers.Serializer):
    nombre = serializers.CharField(read_only=True)
    anterior = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    presente = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    presente_mes_1 = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    presente_mes_2 = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    presente_mes_3 = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    presente_mes_4 = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    presente_resto = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    proximo = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    siguiente = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    resto = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    prevision = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    fin = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    objetivos = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)
    realizado = serializers.DecimalField(
        max_digits=14, decimal_places=0, read_only=True)

    class Meta:
        fields = "__all__"
