from django.forms import DecimalField, IntegerField
from rest_framework import viewsets
from rest_framework.decorators import action
from licuashdr.Permissions import BasePermissions, PerfilAdministrador, PerfilResponsable, PerfilJefeDeObra, TienePerfil, ResponsableOSubditosRespoObraHDR
from hdr.models import HojaDeRuta, HojaDeRutaCertificacion, HojaDeRutaPago, HojaDeRutaPagoAuxiliar, HojaDeRutaProduccion, HojaDeRutaCobro, BI, Objetivo
from hdr.serializers import HojaDeRutaSerializer, HojaDeRutaDetalleSerializer, ReadHojaDeRutaSerializer, HojaDeRutaProduccionSerializer, HojaDeRutaCertificacionSerializer, HojaDeRutaPagoSerializer, HojaDeRutaCobroSerializer, BISerializer, ReadBISerializer, ObjetivoSerializer, DashboardSerializer
from hdr.util import calcularPrecioConFiltros
from rest_framework.response import Response
from licuashdr.util import exportar_modelo_a_excel
from django.http import Http404
from licuashdr.CustomError import CustomError
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework import permissions
from django.utils.translation import gettext_lazy as _
from django.db.models import Q, When, Case, Sum
from django.db.models.functions import Cast
from general.serializers import EmpleadoSerializer
from django.conf import settings
from django.db.models import Value, IntegerField

class HojaDeRutaExcelViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRuta.objects.all().select_related('produccion', 'certificacion', 'cobro', 'obra',
                                                           'obra__empresa', 'obra__delegacion', 'obra__subdelegacion', 'obra__clasificacion', 'obra__situacion',
                                                            'obra__divisa').prefetch_related('objetivos', 'obra__responsables')
    serializer_class = HojaDeRutaDetalleSerializer
    permission_classes = (ResponsableOSubditosRespoObraHDR, )

    def list(self, request):
        if request.user.groups.filter(pk=1):
            # Si es admin debe ver las pendientes de validar
            filtro = Q(estado=3)
        else:
            # Se mostrarán las HDR que perteneces a una obra de la que es responsable el usuario
            filtro = Q(obra__responsables__in=[request.user.id, ])
            # O aquellas HDR que pertenecen a una obra de las que algún subordinado del usuario es responsable
            filtro = filtro | Q(obra__responsables__in=request.user.subordinados.values_list(
                "usuario_id", flat=True))
            # Y que estén abiertas
            # filtro = filtro & Q(estado=2) # Se comenta para mostrar todas y poner iconos en la lista en función del estado
        queryset = HojaDeRuta.objects.filter(filtro).select_related('produccion', 'certificacion', 'cobro', 'obra',
                                                           'obra__empresa', 'obra__delegacion', 'obra__subdelegacion', 'obra__clasificacion', 'obra__situacion',
                                                            'obra__divisa').prefetch_related('objetivos').distinct()
        serializer = ReadHojaDeRutaSerializer(
            queryset, context={'request': request}, many=True)
        return Response(serializer.data)


class HojaDeRutaExcelAdminViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRuta.objects.all().select_related('produccion', 'certificacion', 'cobro', 'obra',
                                                           'obra__empresa', 'obra__delegacion', 'obra__subdelegacion', 'obra__clasificacion', 'obra__situacion',
                                                            'obra__divisa').prefetch_related('objetivos', 'obra__responsables')
    serializer_class = HojaDeRutaDetalleSerializer
    permission_classes = (PerfilAdministrador, )

    def list(self, request):
        queryset = HojaDeRuta.objects.select_related('produccion', 'certificacion', 'cobro', 'obra',
                                                           'obra__empresa', 'obra__delegacion', 'obra__subdelegacion', 'obra__clasificacion', 'obra__situacion',
                                                            'obra__divisa').prefetch_related("objetivos").distinct()
        serializer = ReadHojaDeRutaSerializer(
            queryset, context={'request': request}, many=True)
        return Response(serializer.data)


class HojaDeRutaProduccionExcelViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaProduccion.objects.all()
    serializer_class = HojaDeRutaProduccionSerializer
    permission_classes = (ResponsableOSubditosRespoObraHDR, )


class HojaDeRutaCertificacionExcelViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaCertificacion.objects.all()
    serializer_class = HojaDeRutaCertificacionSerializer
    permission_classes = (ResponsableOSubditosRespoObraHDR, )

class HojaDeRutaPagoExcelViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaPago.objects.all()
    serializer_class = HojaDeRutaPagoSerializer
    permission_classes = (ResponsableOSubditosRespoObraHDR, )


class HojaDeRutaCobroExcelViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaCobro.objects.all()
    serializer_class = HojaDeRutaCobroSerializer
    permission_classes = (ResponsableOSubditosRespoObraHDR, )


class ObjetivoExcelViewSet(viewsets.ModelViewSet):
    queryset = Objetivo.objects.all()
    serializer_class = ObjetivoSerializer
    permission_classes = (ResponsableOSubditosRespoObraHDR, )


class HojaDeRutaViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRuta.objects.all().select_related(
        'obra').prefetch_related('obra__responsables')
    serializer_class = HojaDeRutaDetalleSerializer
    permission_classes = (TienePerfil, )

    def list(self, request):
        queryset = HojaDeRuta.objects.all().select_related('produccion', 'certificacion', 'cobro', 'obra',
                                                           'obra__empresa', 'obra__delegacion', 'obra__subdelegacion', 'obra__clasificacion', 'obra__situacion',
                                                            'obra__divisa').prefetch_related("objetivos")
        serializer = ReadHojaDeRutaSerializer(
            queryset, context={'request': request}, many=True)
        return Response(serializer.data)

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        hojaDeRuta = self.get_object()
        serializer = self.get_serializer(hojaDeRuta, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        if request.data.get('periodo_pago', False):
            request.data.update({"year": hojaDeRuta.pago.hoja.year,"cuarto": hojaDeRuta.pago.hoja.cuarto,"cod_obra": [
                hojaDeRuta.pago.hoja.obra.id
                ]})
            actualizarPagoAuxiliar(request, hojaDeRuta.pago)
        return Response(serializer.data)

class HojaDeRutaProduccionViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaProduccion.objects.all()
    serializer_class = HojaDeRutaProduccionSerializer
    permission_classes = (TienePerfil, )

    def update(self, request, *args, **kwargs):
        data = request.data
        partial = kwargs.pop('partial', False)
        rutaProduccion = self.get_object()
        serializer = self.get_serializer(rutaProduccion, data=data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)

        if data.get('importe_coste_mes_1') or data.get('importe_coste_mes_2') or data.get('importe_coste_mes_3') or data.get('importe_coste_mes_4') or data.get('importe_coste_proximo') or data.get('importe_coste_siguiente'):
            actualizarPagoAuxiliar(request, rutaProduccion.hoja.pago)

        if getattr(rutaProduccion, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the rutaProduccion.
            rutaProduccion._prefetched_objects_cache = {}

        return Response(serializer.data)

class HojaDeRutaCertificacionViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaCertificacion.objects.all()
    serializer_class = HojaDeRutaCertificacionSerializer
    permission_classes = (BasePermissions, )

class HojaDeRutaPagoViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaPago.objects.all()
    serializer_class = HojaDeRutaPagoSerializer
    permission_classes = (BasePermissions, )

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        pago = serializer.save()
        pagoSerializer = actualizarPagoAuxiliar(request, pago)
        headers = self.get_success_headers(pagoSerializer.data)
        return Response(pagoSerializer.data, status=status.HTTP_201_CREATED, headers=headers)

    def update(self, request, *args, **kwargs):
        instancePago = self.get_object()
        
        mes_1 = request.data.get('importe_mes_1', False)
        mes_2 = request.data.get('importe_mes_2', False)
        mes_3 = request.data.get('importe_mes_3', False)
        mes_4 = request.data.get('importe_mes_4', False)
        sinModificar = False
        if type(mes_1) != bool:
            if mes_1 == str(instancePago.importe_mes_1):
                sinModificar = True
        elif type(mes_2) != bool:
            if mes_2 == str(instancePago.importe_mes_2):
                sinModificar = True
        elif type(mes_3) != bool:
            if mes_3 == str(instancePago.importe_mes_3):
                sinModificar = True
        elif type(mes_4) != bool:
            if mes_4 == str(instancePago.importe_mes_4):
                sinModificar = True
        if sinModificar:
            serializerPago = self.get_serializer(instancePago)
            return Response(serializerPago.data)

        partial = kwargs.pop('partial', False)
        request.data.update({"pago_actualizar": False})
        serializer = self.get_serializer(instancePago, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        request.data.update({"year": instancePago.hoja.year,"cuarto": instancePago.hoja.cuarto,"cod_obra": [
            instancePago.hoja.obra.id
            ]})
        _ , _tableroCalcular = tableroCalcular(request)
        datoDirecto = _tableroCalcular['directo']
        directoFinObra = datoDirecto.get('fin',0)


        cantidad, actual_suma, actual_suma_pago = self.actualizarPagoAuxiliarXX(request, instancePago )
        valorModificar = 0
        borrarAuxiliar = False

        if actual_suma_pago > directoFinObra:
            borrarAuxiliar = True
        elif cantidad != 0:
            valorModificar = (directoFinObra - actual_suma) / cantidad

        self.actualizarPagoAuxiliarXX(request, instancePago, valorModificar, True, borrarAuxiliar)
        serializerPago = self.get_serializer(instancePago)
        return Response(serializerPago.data)

    def actualizarPagoAuxiliarXX(self, request, instancePago, valorModificar=0, actualizar = False, borrarAuxiliar = False):
        if borrarAuxiliar:
            instancePago.pago_auxiliar.all().delete()
            return 0, 0

        cantidad = 0
        actual_suma_pago = 0
        actual_suma = 0
        mes_1 = request.data.get('importe_mes_1', False)
        mes_2 = request.data.get('importe_mes_2', False)
        mes_3 = request.data.get('importe_mes_3', False)
        mes_4 = request.data.get('importe_mes_4', False)


        if type(mes_1) != bool:
            if instancePago.importe_mes_2 != 0:
                if actualizar:
                    instancePago.importe_mes_2 += valorModificar
                    instancePago.save()
                cantidad = cantidad + 1
            if instancePago.importe_mes_3 != 0:
                if actualizar:
                    instancePago.importe_mes_3 += valorModificar
                    instancePago.save()
                cantidad = cantidad + 1
            if instancePago.importe_mes_4 != 0:
                if actualizar:
                    instancePago.importe_mes_4 += valorModificar
                    instancePago.save()
                cantidad = cantidad + 1
        elif type(mes_2) != bool:
            if instancePago.importe_mes_3 != 0:
                if actualizar:
                    instancePago.importe_mes_3 += valorModificar
                    instancePago.save()
                cantidad = cantidad + 1
            if instancePago.importe_mes_4 != 0:
                if actualizar:
                    instancePago.importe_mes_4 += valorModificar
                    instancePago.save()
                cantidad = cantidad + 1
        elif type(mes_3) != bool:
            if instancePago.importe_mes_4 != 0:
                if actualizar:
                    instancePago.importe_mes_4 += valorModificar
                    instancePago.save()
                cantidad = cantidad + 1

        actual_suma_pago = actual_suma_pago + instancePago.importe_anterior + instancePago.importe_presente +  instancePago.importe_mes_1 + instancePago.importe_mes_2 + instancePago.importe_mes_3 + instancePago.importe_mes_4 + instancePago.importe_proximo + instancePago.importe_siguiente + instancePago.importe_pendiente
        instanceAuxiliares = instancePago.pago_auxiliar.all()
        if not actualizar:
            instanceAuxiliares = instanceAuxiliares.exclude(year=instancePago.hoja.year, cuarto=instancePago.hoja.cuarto)

        for auxiliar in instanceAuxiliares:
            if auxiliar.importe_mes_1 != 0:
                if actualizar:
                    if valorModificar < 0 and abs(valorModificar) > auxiliar.importe_mes_1:
                        auxiliar.importe_mes_1 = 0
                    else:
                        auxiliar.importe_mes_1 += valorModificar
                    auxiliar.save()
                cantidad = cantidad + 1
                actual_suma = actual_suma + auxiliar.importe_mes_1
            if auxiliar.importe_mes_2 != 0:
                if actualizar:
                    if valorModificar < 0 and abs(valorModificar) > auxiliar.importe_mes_2:
                        auxiliar.importe_mes_2 = 0
                    else:
                        auxiliar.importe_mes_2 += valorModificar
                    auxiliar.save()
                cantidad = cantidad + 1
                actual_suma = actual_suma + auxiliar.importe_mes_2
            if auxiliar.importe_mes_3 != 0:
                if actualizar:
                    if valorModificar < 0 and abs(valorModificar) > auxiliar.importe_mes_3:
                        auxiliar.importe_mes_3 = 0
                    else:
                        auxiliar.importe_mes_3 += valorModificar
                    auxiliar.save()
                cantidad = cantidad + 1
                actual_suma = actual_suma + auxiliar.importe_mes_3
            if auxiliar.importe_mes_4 != 0:
                if actualizar:
                    if valorModificar < 0 and abs(valorModificar) > auxiliar.importe_mes_4:
                        auxiliar.importe_mes_4 = 0
                    else:
                        auxiliar.importe_mes_4 += valorModificar
                    auxiliar.save()
                cantidad = cantidad + 1
                actual_suma = actual_suma + auxiliar.importe_mes_4
        actual_suma = actual_suma + actual_suma_pago
        return cantidad, actual_suma, actual_suma_pago


def actualizarPagoAuxiliar(request, pago):
    HojaDeRutaPagoAuxiliar.objects.filter(pago=pago).delete()
    request.data.update({"year": pago.hoja.year,"cuarto": pago.hoja.cuarto,"cod_obra": [
        pago.hoja.obra.id
        ]})

    _ , _tableroCalcular = tableroCalcular(request)
    datoDirecto = _tableroCalcular['directo']
    importe_mes_1 = datoDirecto.get('realizado',0)
    importe_mes_2 = datoDirecto.get('presente_mes_1',0)
    importe_mes_3 = datoDirecto.get('presente_mes_2',0)
    importe_mes_4 = datoDirecto.get('presente_mes_3',0)
    pago.importe_proximo = datoDirecto.get('presente_mes_4',0)
    pago.importe_siguiente = datoDirecto.get('proximo',0)
    pago.importe_pendiente = datoDirecto.get('siguiente',0)
    pago.save()

    analizarPeriodoCobro(pago, importe_mes_1, importe_mes_2, importe_mes_3, importe_mes_4)

    sumatoriaMes = HojaDeRutaPagoAuxiliar.objects.filter(obra=pago.hoja.obra, cuarto=pago.hoja.cuarto, year=pago.hoja.year).aggregate(
        importe_mes_1=Sum('importe_mes_1'),
        importe_mes_2=Sum('importe_mes_2'),
        importe_mes_3=Sum('importe_mes_3'),
        importe_mes_4=Sum('importe_mes_4'))
    pago.importe_mes_1 = sumatoriaMes.get('importe_mes_1',0)
    pago.importe_mes_2 = sumatoriaMes.get('importe_mes_2',0)
    pago.importe_mes_3 = sumatoriaMes.get('importe_mes_3',0)
    pago.importe_mes_4 = sumatoriaMes.get('importe_mes_4',0)
    pago.save()

    pagoSerializer= HojaDeRutaPagoSerializer(pago)
    return pagoSerializer

def analizarPeriodoCobro(pago, importe_mes_1,importe_mes_2,importe_mes_3,importe_mes_4):
    year = pago.hoja.year
    cuarto = pago.hoja.cuarto

    if pago.hoja.periodo_pago == 30 or pago.hoja.periodo_pago == 150:
        if pago.hoja.periodo_pago == 150:
            year, cuarto = siguienteCuarto(year, cuarto)

        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_1': importe_mes_1,
                'mes_2': importe_mes_2,
                'mes_3': importe_mes_3,
                'mes_4': importe_mes_4,
            }
        )
    elif pago.hoja.periodo_pago == 60 or pago.hoja.periodo_pago == 180:
        if pago.hoja.periodo_pago == 180:
            year, cuarto = siguienteCuarto(year, cuarto)

        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_2': importe_mes_1,
                'mes_3': importe_mes_2,
                'mes_4': importe_mes_3,
            }
        )
        year, cuarto = siguienteCuarto(year, cuarto)
        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_1': importe_mes_4,
            }
        )
    elif pago.hoja.periodo_pago == 90 or pago.hoja.periodo_pago == 210:
        if pago.hoja.periodo_pago == 210:
            year, cuarto = siguienteCuarto(year, cuarto)

        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_3': importe_mes_1,
                'mes_4': importe_mes_2,
            }
        )
        year, cuarto = siguienteCuarto(year, cuarto)
        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_1': importe_mes_3,
                'mes_2': importe_mes_4,
            }
        )
    elif pago.hoja.periodo_pago == 120:
        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_4': importe_mes_1,
            }
        )
        year, cuarto = siguienteCuarto(year, cuarto)
        crearPagoAuxiliar(pago, year, cuarto,
            {
                'mes_1': importe_mes_2,
                'mes_2': importe_mes_3,
                'mes_3': importe_mes_4,
            }
        )

def crearPagoAuxiliar(pago, year, cuarto, meses):
    pagoAuxiliar = HojaDeRutaPagoAuxiliar.objects.create(pago=pago, year=year, cuarto=cuarto, obra=pago.hoja.obra)
    pagoAuxiliar.importe_mes_1 = meses.get('mes_1',0)
    pagoAuxiliar.importe_mes_2 = meses.get('mes_2',0)
    pagoAuxiliar.importe_mes_3 = meses.get('mes_3',0)
    pagoAuxiliar.importe_mes_4 = meses.get('mes_4',0)
    pagoAuxiliar.save()

def siguienteCuarto(year, cuarto):
        if cuarto == 1:
            return year, 2
        if cuarto == 2:
            return year, 3
        if cuarto == 3:
            return year+1, 1


class HojaDeRutaCobroViewSet(viewsets.ModelViewSet):
    queryset = HojaDeRutaCobro.objects.all()
    serializer_class = HojaDeRutaCobroSerializer
    permission_classes = (TienePerfil, )


class ObjetivoViewSet(viewsets.ModelViewSet):
    queryset = Objetivo.objects.all()
    serializer_class = ObjetivoSerializer
    permission_classes = (BasePermissions, )


class BIViewSet(viewsets.ModelViewSet):
    queryset = BI.objects.all()
    serializer_class = BISerializer
    permission_classes = (BasePermissions, )

    def list(self, request):
        queryset = BI.objects.all()
        serializer = ReadBISerializer(
            queryset, context={'request': request}, many=True)
        return Response(serializer.data)


def exportar_excel_bi(request):
    datos = BI.objects.all()
    if datos.count() > 0:
        return exportar_modelo_a_excel(BI, datos)
    raise Http404("Datos BI no encontrados")


@api_view(["POST", ])
@permission_classes([permissions.IsAdminUser, ])
def hdr_por_obra_year_cuarto(request):
    # Recoger obra, año y cuatrimestre
    obra = request.data.get("obra", None)
    year = request.data.get("year", None)
    cuarto = request.data.get("cuarto", None)
    if not obra:
        raise CustomError(_("No se han recibido la obra"), _(
            "HDRs por obra, año y cuatrimestre"), status_code=status.HTTP_400_BAD_REQUEST)
    # Buscar las HDRs para esa obra
    hdrs = HojaDeRuta.objects.filter(obra=obra)
    # Si se especifica el año, filtrar por ese campo también
    if year:
        hdrs = hdrs.filter(year=year)
    # Si se especifica el cuarto, filtrar por ese campo también
    if cuarto:
        hdrs = hdrs.filter(
            cuarto=cuarto)
    # Optimizamos la query
    hdrs = hdrs.select_related('obra', 'obra__empresa', 'produccion',
                               'certificacion', 'cobro').prefetch_related('objetivos')
    # Retornar las hdrs serializadas
    serializado = ReadHojaDeRutaSerializer(hdrs, many=True)
    return Response(serializado.data)


@api_view(["POST", ])
@permission_classes([PerfilAdministrador])
def hdr_en_cuatrimestre(request):
    # Recoger año y cuatrimestre
    year = request.data.get("year", None)
    cuarto = request.data.get("cuarto", None)
    if not year or not cuarto:
        raise CustomError(_("No se han recibido el año y cuatrimestre"), _(
            "HDRs en cuatrimestre"), status_code=status.HTTP_400_BAD_REQUEST)
    # Buscar las HDRs cerradas para ese año y cuatrimestre
    hdrs = HojaDeRuta.objects.filter(year=year).filter(
        cuarto=cuarto).filter(estado=1).select_related('obra', 'obra__empresa', 'produccion', 'certificacion', 'cobro').prefetch_related('objetivos').all()
    # Retornar las hdrs serializadas
    serializado = ReadHojaDeRutaSerializer(hdrs, many=True)
    return Response(serializado.data)


@api_view(["POST", ])
@permission_classes([PerfilAdministrador])
def abrir_hdrs(request):
    from django.core.exceptions import ValidationError
    # Recoger ids
    ids = request.data.get("ids", None)
    if not ids:
        raise CustomError(_("No se ha recibido ningún HDR para abrir"), _(
            "Apertura masiva de HDR"), status_code=status.HTTP_400_BAD_REQUEST)
    # Recoger la fecha
    fecha = request.data.get("fecha_fin", None)
    if not fecha:
        raise CustomError(_("No se ha recibido la fecha de fin de entrega"), _(
            "Apertura masiva de HDR"), status_code=status.HTTP_400_BAD_REQUEST)
    # Buscar las HDRs cerradas para ese año y cuatrimestre
    hdrs = HojaDeRuta.objects.filter(id__in=ids).filter(estado=1).all()
    # Abrir cada HDR, acumulando los errores en otro objeto
    correctos = []
    errores = []
    for hdr in hdrs:
        try:
            hdr.estado = 2
            hdr.fecha_fin_entrega = fecha
            hdr.save()
            correctos.append(hdr)
        except ValidationError as error:
            raise CustomError(_("Se ha recibido una fecha inválida"), _(
                "Apertura masiva de HDR"), status_code=status.HTTP_400_BAD_REQUEST)
        except Exception as error:
            print(error)
            errores.append(hdr)
    correcto_serializado = ReadHojaDeRutaSerializer(correctos, many=True)
    error_serializado = ReadHojaDeRutaSerializer(errores, many=True)
    return Response({"correctos": correcto_serializado.data, "errores": error_serializado.data})


@api_view(["GET", ])
@permission_classes([TienePerfil])
def dashboard(request):
    import datetime
    usuario = request.user
    # Comprobamos el perfil
    #   Perfil 1 - Admin
    #   Perfil 2 - Responsable
    #   Perfil 3 - Jefe de Obra
    filtros = Q()
    validar = None
    obras = None
    clientes = None
    total = {}
    subordinados = usuario.subordinados.select_related('usuario')
    if usuario.groups.filter(pk=1):
        # Si es admin:
        #   - Debe ver los HDRs pendientes de validar (con fecha fin de entrega)
        #   - Debe ver el total de HDRs del cuarto, pendientes de rellenar abiertas y pendientes de validar
        #   - Debe ver los HDRs abiertos de las obras de las que es responsable personas a su cargo (con fin fecha de entrega)
        #   - Debe ver los HDRs abiertos de las obras de las que es responsable (con fin fecha de entrega)
        filtros = Q(obra__in=usuario.obras.all())
        for subordinado in usuario.subordinados.all():
            filtros |= Q(obra__in=subordinado.usuario.obras.all())
        validar = HojaDeRuta.objects.filter(estado=3)
    elif usuario.groups.filter(pk=2):
        # Si es responsable:
        #   - Debe ver los HDRs abiertos de las obras de las que es responsable personas a su cargo (con fin fecha de entrega)
        #   - Debe ver los HDRs abiertos de las obras de las que es responsable (con fin fecha de entrega)
        filtros = Q(obra__in=usuario.obras.all())
        for subordinado in usuario.subordinados.all():
            filtros |= Q(obra__in=subordinado.usuario.obras.all())
    elif usuario.groups.filter(pk=3):
        # Si es jefe de obra:
        #   - Debe ver los HDRs abiertos de las obras de las que es responsable (con fin fecha de entrega)
        #   - Debe de ver el total de HDR de este cuarto de las obras de las que es responsable, HDR abiertos de las obras de las que es responsable y el total de HDR pendientes de validar de las obras de las que es responsable
        filtros = Q(obras__in=usuario.obras.all())
    pendiente = HojaDeRuta.objects.filter(filtros).filter(estado=2)
    # Urgentes son aquellas pendientes que están cerca de su fecha fin
    fecha_fin = datetime.date.today(
    ) + datetime.timedelta(days=settings.DIAS_PREVIOS_FIN_URGENTE)
    urgentes = pendiente.filter(fecha_fin_entrega__lte=fecha_fin)
    # Calculamos los totales
    total["cuarto"] = HojaDeRuta.objects.filter(
        filtros).exclude(estado=1).count()
    total["abiertas"] = pendiente.count()
    total["validar"] = 0
    if validar:
        total["validar"] = validar.count()
    # Serializamos los datos
    pendiente_serializado = ReadHojaDeRutaSerializer(
        pendiente.all(), many=True)
    urgente_serializado = ReadHojaDeRutaSerializer(
        urgentes.all(), many=True)
    validar_serializado = ReadHojaDeRutaSerializer(validar.all(), many=True)
    subordinados_serializado = EmpleadoSerializer(
        subordinados.all(), many=True)
    return Response({"pendiente": pendiente_serializado.data, "validar": validar_serializado.data, "subordinados": subordinados_serializado.data, "total": total, "urgentes": urgente_serializado.data})


@api_view(["POST", ])
@permission_classes([TienePerfil])
def tablero(request):
    serializado, _ = tableroCalcular(request)
    return Response(serializado.data)

def tableroCalcular(request):
    """
    Recibe un año y cuatrimestre y retorna las HDRs correspondientes

    Con el año y el cuatrimestre retorna los valores de las HDRs correspondientes

    :param request: petición http
    :type request: Request
    """
    # Comprobamos que hemos recibido los parámetros mínimos y recogemos el resto
    year = request.data.get("year", None)
    if not year:
        raise CustomError(_("No se ha recibido el año a consultar"), _(
            "Tablero de Mandos"), status_code=status.HTTP_400_BAD_REQUEST)
    cuarto = request.data.get("cuarto", None)
    if not cuarto:
        raise CustomError(_("No se ha el año recibido el cuatrimestre a consultar"), _(
            "Tablero de Mandos"), status_code=status.HTTP_400_BAD_REQUEST)
    cod_obra = request.data.get("cod_obra", None)
    empresa = request.data.get("empresa", None)
    situacion = request.data.get("situacion", None)
    responsables = request.data.get("responsables", None)
    delegacion = request.data.get("delegacion", None)
    subdelegacion = request.data.get("subdelegacion", None)
    participacion_licuas = request.data.get("participacionLicuas", None)
    divisa = request.data.get("divisa", None)
    # Creamos la query base a partir de los parámetros recibidos
    query = HojaDeRuta.objects.filter(year=year, cuarto=cuarto).select_related(
        'produccion', 'certificacion', 'cobro', 'obra').prefetch_related('objetivos', 'obra__responsables')

    # Filtramos la query en función del tipo de usuario que tenemos
    usuario = request.user
    if not usuario.groups.filter(pk=1):
        query = query.filter(obra__in=usuario.obras.all().values_list('id', flat=True))

    # Añadimos filtros en función de los parámetros recibidos
    if cod_obra is not None:
        query = query.filter(obra__in=cod_obra)
    if empresa is not None:
        query = query.filter(obra__empresa__in=empresa)
    if situacion is not None:
        query = query.filter(obra__situacion__in=situacion)
    if responsables is not None:
        query = query.filter(obra__responsables__in=responsables)
    if delegacion is not None:
        query = query.filter(obra__delegacion__in=delegacion)
    if subdelegacion is not None:
        query = query.filter(obra__subdelegacion__in=subdelegacion)

    # Comprobamos que retorna valores, sino, devolvemos error
    if not query.count() > 0:
        serializado = DashboardSerializer(None, many=True)
        return serializado, None

    # Construimos cada fila del tablero según especificaciones
    from django.db.models import Sum, Value, F, CharField, Subquery, OuterRef, DecimalField
    from django.db.models.functions import Coalesce
    from itertools import chain

    # Condiciones para el cambio de divisas
    from general.models import CambioDivisa
    from divisas.models import Divisa

    
    
    cambios_divisas_parcial = CambioDivisa.objects.filter(cuarto=cuarto,year=year)
    cambios_divisas_sbqry = cambios_divisas_parcial.filter(divisa_id=OuterRef('id')).values('importe')
    lista_id = cambios_divisas_parcial.values_list("divisa_id")
    cambios_divisas = Divisa.objects.annotate(importe = Case(
            When(Q(id__in=lista_id), then=( Subquery(cambios_divisas_sbqry, output_field=DecimalField()) )),
            default= Value(1, DecimalField()) ,
            output_field=DecimalField()
        ))
  

    subquery = cambios_divisas.filter(id=OuterRef('obra__divisa_id')).values('importe')

    activar_cambio = False
    if divisa:
        if len(cambios_divisas) > 0:
            activar_cambio = True
        else:
            activar_cambio = False

    # Produccion
    produccion = query.all()
    produccion = produccion.annotate(
        importe_anterior=Case(
            When(Q(obra__divisa_id__in=[query.id for query in cambios_divisas]), then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_contrato_anterior'), 0.00) + Coalesce(F('importe_ampliacion_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_contrato_anterior'), 0.00) + Coalesce(F('importe_ampliacion_anterior'), 0.00)),
            output_field=DecimalField()
        )
        ,
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_contrato_consolidado'), 0.00)+
                       Coalesce(F('importe_ampliacion_consolidado'), 0.00)+
                       # Coalesce(F('importe_contrato_anterior'), 0.00)+
                       # Coalesce(F('importe_ampliacion_anterior'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+
                           Coalesce(F('produccion__importe_contrato_resto'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_contrato_consolidado'), 0.00)+
                       Coalesce(F('importe_ampliacion_consolidado'), 0.00)+
                       # Coalesce(F('importe_contrato_anterior'), 0.00)+
                       # Coalesce(F('importe_ampliacion_anterior'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+
                           Coalesce(F('produccion__importe_contrato_resto'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_proximo'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_proximo'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00)+
                        
                        Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)
                        
                        +Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)
                        ),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00)+
                        
                        Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)
                        
                        +Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)
                        ),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((
                        # F('importe_fin')+
                        Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(
                # F('importe_fin')+
                Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_contrato_consolidado_mes=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_contrato_consolidado'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_contrato_consolidado'), 0.00)),
            output_field=DecimalField()
        ),
        importe_realizado=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_contrato_consolidado'), 0.00)+Coalesce(F('importe_ampliacion_consolidado'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_contrato_consolidado'), 0.00)+Coalesce(F('importe_ampliacion_consolidado'), 0.00)),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((
                        # F('importe_anterior')+F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto')),
                        F('importe_anterior')+F('importe_realizado')+F('importe_prevision')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            # default=(F('importe_anterior')+F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto')),
            default=(F('importe_anterior')+F('importe_realizado')+F('importe_prevision')),
            output_field=DecimalField()
        ),


        # importe_prevision=Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F(
        #     'produccion__importe_contrato_resto'), 0.00)+Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00)+Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00),
        # importe_fin=F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto'),
        # importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),
        # importe_presente_mes_1=Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00),
        # importe_presente_mes_2=Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00),
        # importe_presente_mes_3=Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00),
        # importe_presente_mes_4=Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00),
        # importe_presente_resto=Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00),
        # importe_contrato_consolidado_mes = Coalesce(F('importe_contrato_consolidado'), 0.00)
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        objetivos=Sum('importe_objetivos'),
        contrato_consolidado = Sum('importe_contrato_consolidado_mes'),
        contrato_anterior = Sum('importe_contrato_anterior'),
        realizado=Sum('importe_realizado')
    )

    produccion["nombre"] = "(20)_PROD.TOTAL"
    produccion["fin"] = produccion["anterior"] + produccion["realizado"] + produccion["prevision"]

    # Coste Directo
    directo = query.all()
    directo = directo.annotate(
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_coste_directo_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_coste_directo_anterior'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
                      Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                      Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                      Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                      Coalesce(F('produccion__importe_coste_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
                      Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                      Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                      Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                      Coalesce(F('produccion__importe_coste_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_proximo'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_proximo'), 0.00)),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_siguiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_siguiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                       Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                       Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                       Coalesce(F('produccion__importe_coste_resto'), 0.00)+F('importe_proximo') +
                       F('importe_siguiente')+F('importe_resto')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                       Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                       Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                       Coalesce(F('produccion__importe_coste_resto'), 0.00)+F('importe_proximo') +
                       F('importe_siguiente')+F('importe_resto')),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_anterior')+ F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_anterior')+ F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto')),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_1'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_1'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_2'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_2'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_3'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_3'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_4'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_4'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_realizado=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_coste_directo_consolidado'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_coste_directo_consolidado'), 0.00)),
            output_field=DecimalField()
        ),
        # importe_anterior=Coalesce(F('importe_coste_directo_anterior'), 0.00),
        # importe_presente=Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
        # Coalesce(F('produccion__importe_coste_resto'), 0.00),
        # importe_proximo=Coalesce(F('produccion__importe_coste_proximo'), 0.00),
        # importe_siguiente=Coalesce(F('produccion__importe_coste_siguiente'), 0.00),
        # importe_resto=Coalesce(F('produccion__importe_coste_pendiente'), 0.00),
        # importe_prevision=Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
        # Coalesce(F('produccion__importe_coste_resto'), 0.00)+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto'),
        # importe_fin=F('importe_anterior')+ F('importe_presente')+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto'),
        # importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),
        # importe_presente_mes_1=Coalesce(F('produccion__importe_coste_mes_1'), 0.00),
        # importe_presente_mes_2=Coalesce(F('produccion__importe_coste_mes_2'), 0.00),
        # importe_presente_mes_3=Coalesce(F('produccion__importe_coste_mes_3'), 0.00),
        # importe_presente_mes_4=Coalesce(F('produccion__importe_coste_mes_4'), 0.00),
        # importe_presente_resto=Coalesce(F('produccion__importe_coste_resto'), 0.00)
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        objetivos=Sum('importe_objetivos'),
        realizado = Sum('importe_realizado')
    )
    directo["nombre"] = "(301)_COSTEDIRECTO"
    directo["objetivos"] = None

    directo["prevision"] = directo["presente_mes_1"] + directo["presente_mes_2"] + directo["presente_mes_3"] + directo["presente_mes_4"] + directo["presente_resto"] + directo["proximo"]+ directo["siguiente"]+ directo["resto"]

    directo["fin"] = directo["anterior"] + directo["realizado"] + directo["prevision"]

    # Gastos Delegación
    delegacion = query.all()
    delegacion = delegacion.annotate(
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_coste_delegacion_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_coste_delegacion_anterior'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +
                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +
                (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                         Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                         Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                       Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                       Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100+F('importe_proximo') +
        F('importe_siguiente')+F('importe_resto')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100+F('importe_proximo') +
        F('importe_siguiente')+F('importe_resto')),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_presente')+F('importe_proximo') +
                        F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_presente')+F('importe_proximo') +
                F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)) *
             Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)) *
             Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)) *
             Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)) *
             Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_resto'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00) +
                Coalesce(F('produccion__importe_contrato_resto'), 0.00)) *
             Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_realizado=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('importe_contrato_consolidado'), 0.00) +
                        Coalesce(F('importe_ampliacion_consolidado'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('importe_contrato_consolidado'), 0.00) +
                        Coalesce(F('importe_ampliacion_consolidado'), 0.00)) *
                        Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        )
        # importe_anterior=Coalesce(F('importe_coste_delegacion_anterior'), 0.00),
        # importe_presente=
        # (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +
        # (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #  Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_proximo=(Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
        #                  Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_siguiente=(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
        #                    Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_resto=(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
        #                Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_prevision=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #                    Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto'),
        # importe_fin=F('importe_presente')+F('importe_proximo') +
        #  F('importe_siguiente')+F('importe_resto') + F('importe_anterior'),
        # importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),
        # importe_presente_mes_1=Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) * Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_presente_mes_2= Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) * Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_presente_mes_3= Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) * Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_presente_mes_4= Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) * Coalesce(F('gasto_delegacion'), 0.00)/100,
        # importe_presente_resto= Coalesce(F('produccion__importe_contrato_resto'), 0.00) * Coalesce(F('gasto_delegacion'), 0.00)/100,
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        objetivos=Sum('importe_objetivos'),
        realizado = Sum('importe_realizado')
    )
    delegacion["nombre"] = "(302)_G.G. DELEGACION"
    delegacion["objetivos"] = None

    delegacion["prevision"] = delegacion["presente_mes_1"] + delegacion["presente_mes_2"] + delegacion["presente_mes_3"] + delegacion["presente_mes_4"] + delegacion["presente_resto"] + delegacion["proximo"]+ delegacion["siguiente"]+ delegacion["resto"]
    
    delegacion["fin"] = delegacion["anterior"] + delegacion["realizado"] + delegacion["prevision"]


    # Gastos Central
    central = query.all()
    central = central.annotate(
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_coste_central_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_coste_central_anterior'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +
                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +
                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                         Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                         Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                       Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                       Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100+F('importe_proximo') +
                            F('importe_siguiente')+F('importe_resto')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100+F('importe_proximo') +
                        F('importe_siguiente')+F('importe_resto')),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_presente')+F('importe_proximo') +
                        F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_presente')+F('importe_proximo') +
                F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)) *
             Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)) *
             Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)) *
             Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) +
                Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)) *
             Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_resto'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00) +
                Coalesce(F('produccion__importe_contrato_resto'), 0.00)) *
             Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_realizado=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('importe_contrato_consolidado'), 0.00) +
                        Coalesce(F('importe_ampliacion_consolidado'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('importe_contrato_consolidado'), 0.00) +
                        Coalesce(F('importe_ampliacion_consolidado'), 0.00)) *
                        Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        )
        
        # importe_anterior=Coalesce(F('importe_coste_central_anterior'), 0.00),
        # importe_presente=
        # (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +

        # (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #  Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100,
        # importe_proximo=(Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
        #                  Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100,
        # importe_siguiente=(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
        #                    Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100,
        # importe_resto=(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
        #                Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100,
        # importe_prevision=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #                    Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto'),
        # importe_fin=F('importe_presente')+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto') + F('importe_anterior'),
        # importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),
        # importe_presente_mes_1= Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) * Coalesce(F('gasto_central'), 0.00)/100,
        # importe_presente_mes_2= Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) * Coalesce(F('gasto_central'), 0.00)/100,
        # importe_presente_mes_3= Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) * Coalesce(F('gasto_central'), 0.00)/100,
        # importe_presente_mes_4= Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) * Coalesce(F('gasto_central'), 0.00)/100,
        # importe_presente_resto= Coalesce(F('produccion__importe_contrato_resto'), 0.00) * Coalesce(F('gasto_central'), 0.00)/100,
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        objetivos=Sum('importe_objetivos'),
        realizado=Sum('importe_realizado')
    )
    central["nombre"] = "(303)_G.G. GENERALES CENTRAL"
    central["objetivos"] = None

    central["prevision"] = central["presente_mes_1"] + central["presente_mes_2"] + central["presente_mes_3"] + central["presente_mes_4"] + central["presente_resto"] + central["proximo"]+ central["siguiente"]+ central["resto"]
    
    central["fin"] = central["anterior"] + central["realizado"] + central["prevision"]


    # Coste
    #tocado por Hugo importe contrato consolidado suma
    coste = query.all()
    coste = coste.annotate(
        importe_contrato_consolidado_suma=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('importe_contrato_consolidado'), 0.00)+Coalesce(F('importe_ampliacion_consolidado'), 0.00))),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('importe_contrato_consolidado'), 0.00)+Coalesce(F('importe_ampliacion_consolidado'), 0.00))),
            output_field=DecimalField()
        ),
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_coste_central_anterior'), 0.00) +
                            Coalesce(F('importe_coste_delegacion_anterior'), 0.00) +
                            Coalesce(F('importe_coste_directo_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_coste_central_anterior'), 0.00) +
                            Coalesce(F('importe_coste_delegacion_anterior'), 0.00) +
                            Coalesce(F('importe_coste_directo_anterior'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100
                    )
                    +
                    (
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100
                    )
                    +
                    (
                        Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                        Coalesce(F('produccion__importe_coste_resto'), 0.00)
                    )),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100
                    )
                    +
                    (
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100
                    )
                    +
                    (
                        Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                        Coalesce(F('produccion__importe_coste_resto'), 0.00)
                    )),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_proximo'), 0.00) + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_proximo'), 0.00) + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_siguiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_siguiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_pendiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_pendiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        prevision_directo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                       Coalesce(F('produccion__importe_coste_mes_3'), 0.00) + Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                       Coalesce(F('produccion__importe_coste_resto'), 0.00) +
                       
                       Coalesce(F('produccion__importe_coste_proximo'), 0.00) +
                       Coalesce(F('produccion__importe_coste_siguiente'), 0.00) +
                       Coalesce(F('produccion__importe_coste_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                       Coalesce(F('produccion__importe_coste_mes_3'), 0.00) + Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                       Coalesce(F('produccion__importe_coste_resto'), 0.00) +
                       
                       Coalesce(F('produccion__importe_coste_proximo'), 0.00) +
                       Coalesce(F('produccion__importe_coste_siguiente'), 0.00) +
                       Coalesce(F('produccion__importe_coste_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        prevision_delegacion=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((( Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                              Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                              Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100),
            output_field=DecimalField()
        ),
        prevision_central=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('prevision_directo') + F('prevision_delegacion')+F('prevision_central')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('prevision_directo') + F('prevision_delegacion')+F('prevision_central')),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_2'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_2'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_3'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_3'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_mes_4'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_mes_4'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_resto'), 0.00) + (Coalesce(F('produccion__importe_contrato_resto'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_resto'), 0.00) + (Coalesce(F('produccion__importe_contrato_resto'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        # importe_contrato_consolidado_suma = (Coalesce(F('importe_contrato_consolidado'), 0.00)+Coalesce(F('importe_ampliacion_consolidado'), 0.00)),
        # importe_anterior =  Coalesce(F('importe_coste_central_anterior'), 0.00) +
        #                     Coalesce(F('importe_coste_delegacion_anterior'), 0.00) +
        #                     Coalesce(F('importe_coste_directo_anterior'), 0.00),

        # OLD versión muy antigua
        # importe_presente=Coalesce(F('importe_coste_directo_consolidado'), 0.00)

        #+Coalesce(F('importe_coste_delegacion_consolidado'), 0.00)

        # +Coalesce(F('importe_coste_central_consolidado'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + ((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) +
        #                                                          Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00)))/100 +
        # Coalesce(F('produccion__importe_coste_mes_2'), 0.00) + ((Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) +
        #                                                          Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00)))/100 +
        # Coalesce(F('produccion__importe_coste_mes_3'), 0.00) + ((Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #                                                          Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00)))/100 +
        # Coalesce(F('produccion__importe_coste_mes_4'), 0.00) + ((Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) +
        #                                                          Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00)))/100 +
        # Coalesce(F('produccion__importe_coste_resto'), 0.00) + ((Coalesce(F('produccion__importe_contrato_resto'), 0.00) +
        #                                                          Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00)))/100,
        # importe_presente =
        # (
        #     (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +

        #     (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #     Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100
        # )
        # +
        # (
        #     (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +

        #     (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #     Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100
        # )
        # +
        # (
        #     Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
        #     Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
        #     Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
        #     Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
        #     Coalesce(F('produccion__importe_coste_resto'), 0.00)
        # ),

        # importe_proximo=Coalesce(F('produccion__importe_coste_proximo'), 0.00) + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
        #                                                                           Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100,
        # importe_siguiente=Coalesce(F('produccion__importe_coste_siguiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
        #                                                                               Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100,
        # importe_resto=Coalesce(F('produccion__importe_coste_pendiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
        #                                                                           Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100,
        # prevision_directo=Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
        # Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
        # Coalesce(F('produccion__importe_coste_resto'), 0.00) + Coalesce(F('produccion__importe_coste_proximo'), 0.00) +
        # Coalesce(F('produccion__importe_coste_siguiente'), 0.00) +
        # Coalesce(F('produccion__importe_coste_pendiente'), 0.00),
        # prevision_delegacion=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #                       Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
        #                                                                                                                                                                                                                                                                                                                                                                                 Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
        #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
        #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100,
        # prevision_central=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
        #                    Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
        #                                                                                                                                                                                                                                                                                                                                                                         Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
        #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
        #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100,
        # importe_prevision=F('prevision_directo') + F('prevision_delegacion')+F('prevision_central'),
        # importe_fin=F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior'),
        # importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),,
        #importe_presente_mes_1= ((Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)) * Coalesce(F('gasto_central'), 0.00) / 100),
        # importe_presente_mes_2= Coalesce(F('produccion__importe_coste_mes_2'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)
        # * Coalesce(F('gasto_delegacion'), 0.00) / 100) +  (Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) * Coalesce(F('gasto_central'), 0.00) / 100),
        # importe_presente_mes_3= Coalesce(F('produccion__importe_coste_mes_3'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)
        # * Coalesce(F('gasto_delegacion'), 0.00) / 100) +  (Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) * Coalesce(F('gasto_central'), 0.00) / 100),
        # importe_presente_mes_4= Coalesce(F('produccion__importe_coste_mes_4'), 0.00) + (Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)
        # * Coalesce(F('gasto_delegacion'), 0.00) / 100) +  (Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) * Coalesce(F('gasto_central'), 0.00) / 100),
        # importe_presente_resto= Coalesce(F('produccion__importe_coste_resto'), 0.00) + (Coalesce(F('produccion__importe_contrato_resto'), 0.00)
        # * Coalesce(F('gasto_delegacion'), 0.00) / 100) +  (Coalesce(F('produccion__importe_contrato_resto'), 0.00) * Coalesce(F('gasto_central'), 0.00) / 100),
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        # prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        #objetivos=Sum('importe_objetivos')
    )
    coste["nombre"] = "(30)_COSTE"
    coste["realizado"] = directo['realizado'] + delegacion['realizado'] + central['realizado']

    coste_fin_obra = coste['presente']+coste['proximo'] + coste['siguiente']+coste['resto'] + coste['anterior']
    produccion_fin_obra = produccion['presente']+produccion['proximo'] + produccion['siguiente']+produccion['resto'] + produccion['anterior']

    coste_fin_obra = round(coste_fin_obra, 2)
    produccion_fin_obra = round(produccion_fin_obra, 2)

    coste["prevision"] = directo["prevision"] + delegacion["prevision"] + central["prevision"]

    coste["fin"] = coste["anterior"] + coste["realizado"] + coste["prevision"]

    # Resultado
    resultado = query.all()
    resultado = resultado.annotate(
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('importe_contrato_anterior'), 0.00) + Coalesce(F('importe_ampliacion_anterior'), 0.00) -
                        (Coalesce(F('importe_coste_central_anterior'), 0.00) +
                            Coalesce(F('importe_coste_delegacion_anterior'), 0.00) +
                            Coalesce(F('importe_coste_directo_anterior'), 0.00))
                    ),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('importe_contrato_anterior'), 0.00) + Coalesce(F('importe_ampliacion_anterior'), 0.00) -
                        (Coalesce(F('importe_coste_central_anterior'), 0.00) +
                            Coalesce(F('importe_coste_delegacion_anterior'), 0.00) +
                            Coalesce(F('importe_coste_directo_anterior'), 0.00))),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((
                    (Coalesce(F('importe_contrato_consolidado'), 0.00)+
                       Coalesce(F('importe_ampliacion_consolidado'), 0.00)+
                       # Coalesce(F('importe_contrato_anterior'), 0.00)+
                       # Coalesce(F('importe_ampliacion_anterior'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+
                           Coalesce(F('produccion__importe_contrato_resto'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00))-
                    ((
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100
                    )
                    +
                    (
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100
                    )
                    +
                    (
                        Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                        Coalesce(F('produccion__importe_coste_resto'), 0.00)
                    ))),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(
                    (Coalesce(F('importe_contrato_consolidado'), 0.00)+
                       Coalesce(F('importe_ampliacion_consolidado'), 0.00)+
                       # Coalesce(F('importe_contrato_anterior'), 0.00)+
                       # Coalesce(F('importe_ampliacion_anterior'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                       Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+
                           Coalesce(F('produccion__importe_contrato_resto'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                           Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)
                           +Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00))-
                    ((
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_central'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100
                    )
                    +
                    (
                        (((Coalesce(F('importe_contrato_consolidado'), 0.00) + Coalesce(F('importe_ampliacion_consolidado'), 0.00) ) * Coalesce(F('gasto_delegacion'), 0.00)) / 100) +

                        (Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100
                    )
                    +
                    (
                        Coalesce(F('importe_coste_directo_consolidado'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
                        Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
                        Coalesce(F('produccion__importe_coste_resto'), 0.00)
                    ))),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(produccion["presente_mes_1"], 0.00) - Coalesce(coste["presente_mes_1"], 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(produccion["presente_mes_1"], 0.00) - Coalesce(coste["presente_mes_1"], 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(produccion["presente_mes_2"], 0.00) - Coalesce(coste["presente_mes_2"], 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(produccion["presente_mes_2"], 0.00) - Coalesce(coste["presente_mes_2"], 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(produccion["presente_mes_3"], 0.00) - Coalesce(coste["presente_mes_3"], 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(produccion["presente_mes_3"], 0.00) - Coalesce(coste["presente_mes_3"], 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(produccion["presente_mes_4"], 0.00) - Coalesce(coste["presente_mes_4"], 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(produccion["presente_mes_4"], 0.00) - Coalesce(coste["presente_mes_4"], 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(produccion["presente_resto"], 0.00) - Coalesce(coste["presente_resto"], 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(produccion["presente_resto"], 0.00) - Coalesce(coste["presente_resto"], 0.00)),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00) -
                        (Coalesce(F('produccion__importe_coste_proximo'), 0.00) + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100)
                        ),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                    Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)-
                    (Coalesce(F('produccion__importe_coste_proximo'), 0.00) + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100)
                    ),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))-
                                            (Coalesce(F('produccion__importe_coste_siguiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))-
                    (Coalesce(F('produccion__importe_coste_siguiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        resto_produccion=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                    Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        resto_coste=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_coste_pendiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_coste_pendiente'), 0.00) + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*(Coalesce(F('gasto_delegacion'), 0.00)+Coalesce(F('gasto_central'), 0.00))/100),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('resto_produccion')-F('resto_coste')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('resto_produccion')-F('resto_coste')),
            output_field=DecimalField()
        ),
        importe_resto_produccion=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                        Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                    Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        prevision_produccion=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F(
                        'produccion__importe_contrato_resto'), 0.00)+Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00)+Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F(
                    'produccion__importe_contrato_resto'), 0.00)+Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00)+Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        prevision_directo=Coalesce(F('produccion__importe_coste_mes_1'), 0.00) + Coalesce(F('produccion__importe_coste_mes_2'), 0.00) +
        Coalesce(F('produccion__importe_coste_mes_3'), 0.00) +
        Coalesce(F('produccion__importe_coste_mes_4'), 0.00) +
        Coalesce(F('produccion__importe_coste_resto'), 0.00) + Coalesce(F('produccion__importe_coste_proximo'), 0.00) +
        Coalesce(F('produccion__importe_coste_siguiente'), 0.00) +
        Coalesce(F('produccion__importe_coste_pendiente'), 0.00),
        prevision_delegacion=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00) + Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                              Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00) + Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_delegacion'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100+(Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_delegacion'), 0.00)/100,
        prevision_central=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_2'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00) +
                           Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_4'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_contrato_resto'), 0.00) + Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)) * Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_proximo'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100 + (Coalesce(F('produccion__importe_contrato_pendiente'), 0.00) +
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00))*Coalesce(F('gasto_central'), 0.00)/100,
        importe_prevision_resta=F('prevision_directo') +
        F('prevision_delegacion')+F('prevision_central'),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F(
                        'produccion__importe_contrato_resto'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)-
                        (F('prevision_directo') + F('prevision_delegacion')+F('prevision_central'))
                        ),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('produccion__importe_contrato_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_2'), 0.00)+Coalesce(F('produccion__importe_contrato_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_mes_4'), 0.00)+Coalesce(F(
                        'produccion__importe_contrato_resto'), 0.00)+
                        Coalesce(F('produccion__importe_contrato_proximo'), 0.00)+Coalesce(F('produccion__importe_contrato_siguiente'), 0.00) +
                        Coalesce(F('produccion__importe_contrato_pendiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_1'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_2'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_mes_3'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_mes_4'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_resto'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_proximo'), 0.00)+
                        Coalesce(F('produccion__importe_ampliaciones_siguiente'), 0.00)+Coalesce(F('produccion__importe_ampliaciones_pendiente'), 0.00)-
                        (F('prevision_directo') + F('prevision_delegacion')+F('prevision_central'))
                        ),
            output_field=DecimalField()
        ),
        prevision_coste=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('prevision_produccion') +F('prevision_delegacion')+F('prevision_central')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('prevision_produccion') +F('prevision_delegacion')+F('prevision_central')),
            output_field=DecimalField()
        ),
        importe_fin_produccion=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_presente')+F('importe_proximo') +F('importe_siguiente')+F('importe_resto_produccion')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_presente')+F('importe_proximo') +F('importe_siguiente')+F('importe_resto_produccion')),
            output_field=DecimalField()
        ),

        importe_objetivo_venta=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(
                        (Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),

        importe_objetivo_coste=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros(
                        (Coalesce(Sum('objetivos__coste'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(Sum('objetivos__coste'), 0.00)),
            output_field=DecimalField()
        ),

        # importe_fin=Case(
        #     When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
        #             calcularPrecioConFiltros((resultado_fin),
        #                 Subquery(subquery, output_field=CharField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
        #             )
        #         ),
        #     default=(resultado_fin),
        #     output_field=CharField()
        # ),
        # importe_objetivos=Case(
        #     When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
        #             calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
        #                 Subquery(subquery, output_field=CharField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
        #             )
        #         ),
        #     default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
        #     output_field=CharField()
        # ),
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        # resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        objetivo_venta=Sum('importe_objetivo_venta'),
        objetivo_coste=Sum('importe_objetivo_coste')
        #fin=Sum('importe_fin'),
        #objetivos=Sum('importe_objetivos')
    )
    resultado["realizado"] = (produccion['realizado'] - coste['realizado'] )

    resultado["resto"] = (produccion['resto'] - coste['resto'] )

    #Creamos importe fin y objetivos
    # resultado["objetivos"] = resultado["objetivo_venta"] + resultado["fin"]
    resultado["objetivos"] = resultado["objetivo_venta"] - resultado["objetivo_coste"]

    resultado["fin"] = produccion_fin_obra - coste_fin_obra

    resultado["nombre"] = "(35)_RESULTADO"
    # Certificación
    certificacion = query.all()
    certificacion = certificacion.annotate(
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_anterior'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_presente'), 0.00)+Coalesce(F('certificacion__importe_mes_1'), 0.00)+Coalesce(F('certificacion__importe_mes_2'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_3'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_4'), 0.00) +
                        Coalesce(F('certificacion__importe_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_presente'), 0.00)+Coalesce(F('certificacion__importe_mes_1'), 0.00)+Coalesce(F('certificacion__importe_mes_2'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_3'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_4'), 0.00) +
                        Coalesce(F('certificacion__importe_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_proximo'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_proximo'), 0.00)),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_siguiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_siguiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_mes_1'), 0.00)+Coalesce(F('certificacion__importe_mes_2'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_3'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_4'), 0.00)+Coalesce(F('certificacion__importe_resto'), 0.00)+F('importe_proximo') +
                        F('importe_siguiente')+F('importe_resto')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_mes_1'), 0.00)+Coalesce(F('certificacion__importe_mes_2'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_3'), 0.00) +
                        Coalesce(F('certificacion__importe_mes_4'), 0.00)+Coalesce(F('certificacion__importe_resto'), 0.00)+F('importe_proximo') +
                        F('importe_siguiente')+F('importe_resto')),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_mes_1'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_mes_1'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_mes_2'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_mes_2'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_mes_3'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_mes_3'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_mes_4'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_mes_4'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_realizado_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('certificacion__importe_presente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('certificacion__importe_presente'), 0.00)),
            output_field=DecimalField()
        ),
        # importe_anterior=Coalesce(F('certificacion__importe_anterior'), 0.00),
        # importe_presente=Coalesce(F('certificacion__importe_presente'), 0.00)+Coalesce(F('certificacion__importe_mes_1'), 0.00)+Coalesce(F('certificacion__importe_mes_2'), 0.00) +
        # Coalesce(F('certificacion__importe_mes_3'), 0.00) +
        # Coalesce(F('certificacion__importe_mes_4'), 0.00) +
        # Coalesce(F('certificacion__importe_resto'), 0.00),
        # importe_proximo=Coalesce(F('certificacion__importe_proximo'), 0.00),
        # importe_siguiente=Coalesce(F('certificacion__importe_siguiente'), 0.00),
        # importe_resto=Coalesce(F('certificacion__importe_pendiente'), 0.00),
        # importe_prevision=Coalesce(F('certificacion__importe_mes_1'), 0.00)+Coalesce(F('certificacion__importe_mes_2'), 0.00) +
        # Coalesce(F('certificacion__importe_mes_3'), 0.00) +
        # Coalesce(F('certificacion__importe_mes_4'), 0.00)+Coalesce(F('certificacion__importe_resto'), 0.00)+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto'),
        # importe_fin=F('importe_prevision')+F('importe_anterior'),
        # importe_fin=F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior'),
        #  importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),
        # importe_presente_mes_1=Coalesce(F('certificacion__importe_mes_1'), 0.00),
        # importe_presente_mes_2=Coalesce(F('certificacion__importe_mes_2'), 0.00),
        # importe_presente_mes_3=Coalesce(F('certificacion__importe_mes_3'), 0.00),
        # importe_presente_mes_4=Coalesce(F('certificacion__importe_mes_4'), 0.00),
        # importe_presente_resto=Coalesce(F('certificacion__importe_resto'), 0.00),
        # importe_realizado_presente = Coalesce(F('certificacion__importe_presente'), 0.00)
    ).aggregate(
        anterior=Sum('importe_anterior'),
        #Agregado correctamente
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        objetivos=Sum('importe_objetivos'),
        realizado_presente=Sum('importe_realizado_presente')
    )
    certificacion["nombre"] = "(40)_CERTIFICACION"
    certificacion["objetivos"] = None

    certificacion["prevision"] = certificacion["presente_mes_1"] + certificacion["presente_mes_2"] + certificacion["presente_mes_3"] + certificacion["presente_mes_4"] + certificacion["presente_resto"] + certificacion["proximo"]+ certificacion["siguiente"]+ certificacion["resto"]
    
    certificacion["realizado"] = certificacion["realizado_presente"]

    certificacion["fin"] = certificacion["anterior"] + certificacion["realizado"] + certificacion["prevision"]


    # Cobro
    cobro = query.all()
    cobro = cobro.annotate(
        importe_anterior=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_anterior'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_anterior'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_1'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00) +
                        Coalesce(F('cobro__importe_mes_3'), 0.00) +
                        Coalesce(F('cobro__importe_mes_4'), 0.00) +
                        Coalesce(F('cobro__importe_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_1'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00) +
                        Coalesce(F('cobro__importe_mes_3'), 0.00) +
                        Coalesce(F('cobro__importe_mes_4'), 0.00) +
                        Coalesce(F('cobro__importe_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_proximo=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_proximo'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_proximo'), 0.00)),
            output_field=DecimalField()
        ),
        importe_siguiente=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_siguiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_siguiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_pendiente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_pendiente'), 0.00)),
            output_field=DecimalField()
        ),
        importe_prevision=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_mes_1'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00) +
                         Coalesce(F('cobro__importe_mes_3'), 0.00) +
                         Coalesce(F('cobro__importe_mes_4'), 0.00)+Coalesce(F('cobro__importe_resto'), 0.00)+F('importe_proximo') +
                         F('importe_siguiente')+F('importe_resto')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_mes_1'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00) +
                         Coalesce(F('cobro__importe_mes_3'), 0.00) +
                         Coalesce(F('cobro__importe_mes_4'), 0.00)+Coalesce(F('cobro__importe_resto'), 0.00)+F('importe_proximo') +
                         F('importe_siguiente')+F('importe_resto')),
            output_field=DecimalField()
        ),
        importe_fin=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior')),
            output_field=DecimalField()
        ),
        importe_objetivos=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_1=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_mes_1'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_mes_1'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_2=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_mes_2'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_mes_2'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_3=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_mes_3'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_mes_3'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_mes_4=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_mes_4'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_mes_4'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_resto=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_resto'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_resto'), 0.00)),
            output_field=DecimalField()
        ),
        importe_presente_realizado=Case(
            When(obra__divisa_id__in=[query.id for query in cambios_divisas], then=(
                    calcularPrecioConFiltros((Coalesce(F('cobro__importe_presente'), 0.00)),
                        Subquery(subquery, output_field=DecimalField()), F('obra__participacion_licuas'), activar_cambio, participacion_licuas)
                    )
                ),
            default=(Coalesce(F('cobro__importe_presente'), 0.00)),
            output_field=DecimalField()
        ),
        # importe_anterior=Coalesce(F('cobro__importe_anterior'), 0.00),
        # importe_presente=Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_1'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00) +
        # Coalesce(F('cobro__importe_mes_3'), 0.00) +
        # Coalesce(F('cobro__importe_mes_4'), 0.00) +
        # Coalesce(F('cobro__importe_resto'), 0.00),
        # importe_proximo=Coalesce(F('cobro__importe_proximo'), 0.00),
        # importe_siguiente=Coalesce(F('cobro__importe_siguiente'), 0.00),
        # importe_resto=Coalesce(F('cobro__importe_pendiente'), 0.00),
        # importe_prevision=Coalesce(F('cobro__importe_mes_1'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00) +
        # Coalesce(F('cobro__importe_mes_3'), 0.00) +
        # Coalesce(F('cobro__importe_mes_4'), 0.00)+Coalesce(F('cobro__importe_resto'), 0.00)+F('importe_proximo') +
        # F('importe_siguiente')+F('importe_resto'),
        # importe_fin=F('importe_prevision')+F('importe_anterior'),
        # importe_fin=F('importe_presente')+F('importe_proximo') + F('importe_siguiente')+F('importe_resto') + F('importe_anterior'),
        # importe_objetivos=F('importe_fin')+Coalesce(Sum('objetivos__venta'), 0.00),
        # importe_presente_mes_1=Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_1'), 0.00),
        # importe_presente_mes_2=Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_2'), 0.00),
        # importe_presente_mes_3=Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_3'), 0.00),
        # importe_presente_mes_4=Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_mes_4'), 0.00),
        # importe_presente_resto=Coalesce(F('cobro__importe_presente'), 0.00)+Coalesce(F('cobro__importe_resto'), 0.00)
    ).aggregate(
        anterior=Sum('importe_anterior'),
        presente=Sum('importe_presente'),
        presente_mes_1=Sum('importe_presente_mes_1'),
        presente_mes_2=Sum('importe_presente_mes_2'),
        presente_mes_3=Sum('importe_presente_mes_3'),
        presente_mes_4=Sum('importe_presente_mes_4'),
        presente_resto=Sum('importe_presente_resto'),
        proximo=Sum('importe_proximo'),
        siguiente=Sum('importe_siguiente'),
        resto=Sum('importe_resto'),
        prevision=Sum('importe_prevision'),
        fin=Sum('importe_fin'),
        objetivos=Sum('importe_objetivos'),
        realizado_presente=Sum('importe_presente_realizado')
    )
    cobro["nombre"] = "(50)_COBRO (RECEP. DOCUMENTO)"
    cobro["objetivos"] = None

    cobro["prevision"] = cobro["presente_mes_1"] + cobro["presente_mes_2"] + cobro["presente_mes_3"] + cobro["presente_mes_4"] + cobro["presente_resto"] + cobro["proximo"]+ cobro["siguiente"]+ cobro["resto"]
    
    cobro["realizado"] = cobro["realizado_presente"]

    cobro["fin"] = cobro["anterior"] + cobro["realizado"] + cobro["prevision"]


    # Producción - Certificación
    prod_cert = {}
    prod_cert["anterior"] = produccion["anterior"] - certificacion["anterior"]
    prod_cert["presente"] = produccion["presente"] - certificacion["presente"] + prod_cert["anterior"]
    prod_cert["proximo"] = produccion["proximo"] - certificacion["proximo"] + prod_cert["presente"]
    prod_cert["siguiente"] = produccion["siguiente"] - certificacion["siguiente"] + prod_cert["proximo"]
    prod_cert["resto"] = produccion["resto"] - certificacion["resto"] + prod_cert["siguiente"]
    #prod_cert["prevision"] = produccion["prevision"] - certificacion["prevision"] + prod_cert["resto"]

    prod_cert["nombre"] = "PRODUC. - CERTIFIC (A Origen)"
    prod_cert['contrato_consolidado'] = produccion['contrato_consolidado']
    prod_cert["objetivos"] = None
    prod_cert['importe_presente_real'] = produccion["contrato_consolidado"] - certificacion["realizado_presente"] + prod_cert["anterior"]
    prod_cert['realizado'] = produccion["realizado"]-certificacion["realizado_presente"]+prod_cert["anterior"]
    prod_cert['presente_mes_1'] =produccion["presente_mes_1"] - certificacion["presente_mes_1"] + prod_cert['realizado']
    prod_cert['presente_mes_2'] =produccion["presente_mes_2"] - certificacion["presente_mes_2"] + prod_cert['presente_mes_1']
    prod_cert['presente_mes_3'] =produccion["presente_mes_3"] - certificacion["presente_mes_3"] + prod_cert['presente_mes_2']
    prod_cert['presente_mes_4'] =produccion["presente_mes_4"] - certificacion["presente_mes_4"] + prod_cert['presente_mes_3']
    prod_cert['presente_resto'] =produccion["presente_resto"] - certificacion["presente_resto"] + prod_cert['presente_mes_4']

    prod_cert["fin"] = produccion["fin"] - certificacion["fin"]




    # Certificación - Cobro
    cert_cobro = {}
    cert_cobro["anterior"] = certificacion["anterior"] - cobro["anterior"]
    cert_cobro["presente"] = certificacion["presente"] - cobro["presente"] + cert_cobro["anterior"]
    cert_cobro["proximo"] = certificacion["proximo"] - cobro["proximo"] + cert_cobro["presente"]
    cert_cobro["siguiente"] = certificacion["siguiente"] - cobro["siguiente"] + cert_cobro["proximo"]
    cert_cobro["resto"] = certificacion["resto"] - cobro["resto"] + cert_cobro["siguiente"]
    #cert_cobro["prevision"] = certificacion["prevision"] - cobro["prevision"] + cert_cobro["resto"]
    cert_cobro["objetivos"] = None
    cert_cobro["nombre"] = "CERTIFIC. - COBRO (A Origen)"
    cert_cobro["objetivos"] = None
    # calcular certificado cobro realizado año
    cert_cobro["realizado"] = certificacion["realizado_presente"] - cobro["realizado_presente"] + cert_cobro["anterior"]
    cert_cobro['presente_mes_1'] = cert_cobro["realizado"] + certificacion["presente_mes_1"] - cobro['presente_mes_1']
    cert_cobro['presente_mes_2'] = cert_cobro["presente_mes_1"] + certificacion["presente_mes_2"] - cobro['presente_mes_2']
    cert_cobro['presente_mes_3'] = cert_cobro["presente_mes_2"] + certificacion["presente_mes_3"] - cobro['presente_mes_3']
    cert_cobro['presente_mes_4'] = cert_cobro["presente_mes_3"] + certificacion["presente_mes_4"] - cobro['presente_mes_4']
    cert_cobro['presente_resto'] = cert_cobro["presente_mes_4"] + certificacion["presente_resto"] - cobro['presente_resto']

    cert_cobro["fin"] = certificacion["fin"] - cobro["fin"]

    # Retorno final
    cobro['realizado'] = cobro["realizado_presente"]

    #Calculando margen bruto y margen neto
    keyCalcular = [
        'anterior',
        'realizado',
        'presente_mes_1',
        'presente_mes_2',
        'presente_mes_3',
        'presente_mes_4',
        'presente_resto',
        # 'presente', se calcula sumando los anteriores
        'proximo',
        'siguiente',
        'resto',
        # 'prevision', se calcula sumando los anteriores
        'fin',
        ]

    margenBruto = {'nombre': 'MARGEN BRUTO', 'presente': 0, 'prevision': 0 }
    for key in keyCalcular:
        _produccion = produccion[key] if produccion.get(key) else 0
        _directo = directo[key] if directo.get(key)  else 0
        margenBruto[key] = _produccion - _directo

    margenNeto = {'nombre': 'MARGEN NETO', 'presente': 0, 'prevision': 0 }
    for key in keyCalcular:
        _margenBruto = margenBruto[key] if margenBruto.get(key) else 0
        _delegacion = delegacion[key] if delegacion.get(key)  else 0
        _central = central[key] if central.get(key) else 0
        margenNeto[key] = _margenBruto - _delegacion - _central
    
    keyPresente =[
        'realizado',
        'presente_mes_1',
        'presente_mes_2',
        'presente_mes_3',
        'presente_mes_4']
    for key in keyPresente:
        margenBruto['presente'] += margenBruto[key]
        margenNeto['presente'] += margenNeto[key]

    keyPrevision = [
         'presente',
        'proximo',
        'siguiente',
        'resto']
    for key in keyPrevision:
        margenBruto['prevision'] += margenBruto[key]
        margenNeto['prevision'] += margenNeto[key]

    retorno = []
    retorno.append(produccion)
    retorno.append(directo)
    retorno.append(margenBruto)
    retorno.append(delegacion)
    retorno.append(central)
    retorno.append(margenNeto)
    retorno.append(coste)
    retorno.append(resultado)
    retorno.append(certificacion)
    retorno.append(cobro)
    retorno.append(prod_cert)
    retorno.append(cert_cobro)

    serializado = DashboardSerializer(retorno, many=True)
    return serializado, {'directo': directo}
