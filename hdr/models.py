from django.db import models
from django.utils.translation import gettext_lazy as _
from django.conf import settings
from licuashdr.util import enviar_correo
from django.contrib.auth.models import User
from django.core.mail import mail_admins
import smtplib
from licuashdr.CustomError import CustomError
from rest_framework import status
from django.core.exceptions import ValidationError

ESTADOS = [
    (1, 'CERRADA'),
    (2, 'ABIERTA'),
    (3, 'PENDIENTE'),
    (4, 'VALIDADA'),
]

def validar_periodo(value):
    if value not in [30, 60, 90, 120, 150, 180, 210]:
        raise ValidationError(
            _('El período %(value)s no es correcto'),
            params={'value': value},
        )

class HojaDeRuta(models.Model):
    obra = models.ForeignKey("general.Obra", verbose_name=_(
        "obra asociada"), on_delete=models.CASCADE)
    year = models.IntegerField(null=False, blank=False, verbose_name=_("año"))
    cuarto = models.IntegerField(
        null=False, blank=False, choices=settings.CUARTOS, verbose_name=_("cuatrimestre"))
    fecha_fin_entrega = models.DateField(
        _("fecha de fin de la entrega"), auto_now=False, auto_now_add=False, null=True, blank=True)
    estado = models.IntegerField(_("estado"), choices=ESTADOS, default=1)
    gasto_delegacion = models.DecimalField(
        _("% de gasto delegación"), max_digits=5, decimal_places=2, null=True, blank=True)
    gasto_delegacion_personalizado = models.BooleanField(
        _("% de gasto delegación personalizado"), default=False)
    gasto_central = models.DecimalField(
        _("% de gasto central"), max_digits=5, decimal_places=2, null=True, blank=True)
    gasto_central_personalizado = models.BooleanField(
        _("% de gasto central personalizado"), default=False)
    importe_contrato_anterior = models.DecimalField(
        _("importe de contrato inicial hasta fin del año anterior"), max_digits=14, decimal_places=2, default=0.00)
    importe_contrato_consolidado = models.DecimalField(
        _("importe de contrato inicial consolidado durante el año"), max_digits=14, decimal_places=2, default=0.00)
    importe_ampliacion_anterior = models.DecimalField(
        _("importe de ampliaciones hasta fin del año anterior"), max_digits=14, decimal_places=2, default=0.00)
    importe_ampliacion_consolidado = models.DecimalField(
        _("importe de ampliaciones consolidado durante el año"), max_digits=14, decimal_places=2, default=0.00)
    importe_coste_directo_anterior = models.DecimalField(
        _("importe de costes directos e indirectos hasta fin del año anterior"), max_digits=14, decimal_places=2, default=0.00)
    importe_coste_directo_consolidado = models.DecimalField(
        _("importe de costes directos e indirectos consolidado durante el año"), max_digits=14, decimal_places=2, default=0.00)
    importe_coste_delegacion_anterior = models.DecimalField(
        _("importe de costes asociados a la delegación hasta fin del año anterior"), max_digits=14, decimal_places=2, default=0.00)
    importe_coste_delegacion_consolidado = models.DecimalField(
        _("importe de costes asociados a la delegación consolidado durante el año"), max_digits=14, decimal_places=2, default=0.00)
    importe_coste_central_anterior = models.DecimalField(
        _("importe de costes asociados a la central hasta fin del año anterior"), max_digits=14, decimal_places=2, default=0.00)
    importe_coste_central_consolidado = models.DecimalField(
        _("importe de costes asociados a la central consolidado durante el año"), max_digits=14, decimal_places=2, default=0.00)
    fecha_creacion = models.DateTimeField(
        _("fecha de creación"), auto_now=False, auto_now_add=True)
    fecha_modificacion = models.DateTimeField(
        _("fecha de último modificación"), auto_now=True, auto_now_add=False)
    usuario_creacion = models.ForeignKey("auth.User", verbose_name=_(
        "usuario de creación"), related_name="hdr_creadas", on_delete=models.PROTECT, null=False, blank=True)
    usuario_modificacion = models.ForeignKey("auth.User", verbose_name=_(
        "usuario de última modificación"), related_name="hdr_modificadas", on_delete=models.PROTECT, null=False, blank=True)
    observaciones = models.TextField(_("observaciones"), null=True, blank=True)
    periodo_cobro = models.IntegerField(_("periodo de cobro"), default=30, validators=[validar_periodo])
    periodo_pago = models.IntegerField(_("periodo de pago"), default=30, validators=[validar_periodo])
    cf_acreedor = models.DecimalField(_("cf de acreedor"), max_digits=5, decimal_places=2, null=True, blank=True)
    cf_deudor = models.DecimalField(_("cf de deudor"), max_digits=5, decimal_places=2, null=True, blank=True)

    @property
    def anterior(self):
        from django.db.models import IntegerField
        from django.db.models.functions import Cast, Concat
        from django.db.models import F
        return HojaDeRuta.objects.filter(obra=self.obra).annotate(orden=Cast(Concat(F('year'), F('cuarto')), output_field=IntegerField())).filter(orden__lt=str(
            self.year)+str(self.cuarto)).order_by('-orden').first()

    @property
    def siguiente(self):
        from django.db.models import IntegerField
        from django.db.models.functions import Cast, Concat
        from django.db.models import F
        return HojaDeRuta.objects.filter(obra=self.obra).annotate(orden=Cast(Concat(F('year'), F('cuarto')), output_field=IntegerField())).filter(orden__gt=str(
            self.year)+str(self.cuarto)).order_by('orden').first()

    class Meta:
        verbose_name = _("hoja de ruta")
        verbose_name_plural = _("hojas de ruta")
        unique_together = [['obra', 'year', 'cuarto'], ]
        indexes = [models.Index(fields=['obra', 'year', 'cuarto']), ]

    def __str__(self):
        return str(self.year) + '/' + str(self.cuarto) + '/' + str(self.obra)

    @classmethod
    def from_db(cls, db, field_names, values):
        instance = super(HojaDeRuta, cls).from_db(db, field_names, values)
        instance._loaded_values = dict(zip(field_names, values))
        return instance

    def correo_apertura(self):
        cuarto = self.get_cuarto_display()
        enlace = self.frontend_url()
        try:
            enviar_correo(asunto="Apertura HDR", correo_desde=settings.EMAIL_HOST_USER, correos_a=self.obra.responsables.values_list('email', flat=True), texto=settings.CORREO_APERTURA.format(
                cuarto=cuarto, año=self.year, obra=self.obra, enlace=enlace, fecha=self.fecha_fin_entrega), html=settings.CORREO_APERTURA_HTML.format(cuarto=cuarto, año=self.year, obra=self.obra, enlace=enlace, fecha=self.fecha_fin_entrega), html_default=True, alternatives=True, silencioso=False)
        except smtplib.SMTPException as excepcion:
            mail_admins(subject="Error", message="Error al enviar correo de apertura de HDR." +
                        repr(excepcion), fail_silently=True)

    def correo_rechazo(self):
        cuarto = self.get_cuarto_display()
        enlace = self.frontend_url()
        try:
            enviar_correo(asunto="Rechazo HDR", correo_desde=settings.EMAIL_HOST_USER, correos_a=self.obra.responsables.values_list('email', flat=True), texto=settings.CORREO_RECHAZO.format(
                cuarto=cuarto, año=self.year, obra=self.obra, enlace=enlace, fecha=self.fecha_fin_entrega), html=settings.CORREO_RECHAZO_HTML.format(cuarto=cuarto, año=self.year, obra=self.obra, enlace=enlace, fecha=self.fecha_fin_entrega), html_default=True, alternatives=True, silencioso=False)
        except smtplib.SMTPException as excepcion:
            mail_admins(subject="Error", message="Error al enviar correo de rechazo de HDR." +
                        repr(excepcion), fail_silently=True)

    def lista_correos(self):
        """
        Retorna una lista de correos de responsables

        Método que retorna una lista de correos electrónicos de los jefes de los responsables de obra y los administradores

        :return: lista de correos
        :rtype: list
        """
        correos = User.objects.filter(
            groups__in=[1, ]).values_list('email', flat=True)
        responsables = self.obra.responsables.all()
        for responsable in responsables:
            try:
                correos.append(responsable.responsable.email)
            except AttributeError as error:
                pass
        return correos

    def correo_validacion(self):
        cuarto = self.get_cuarto_display()
        enlace = self.frontend_url()
        # Se debe enviar correo a administradores y los jefes de los responsables
        correos_a = self.lista_correos()
        try:
            enviar_correo(asunto="Validación HDR", correo_desde=settings.EMAIL_HOST_USER, correos_a=correos_a, texto=settings.CORREO_VALIDACION.format(
                cuarto=cuarto, año=self.year, obra=self.obra, enlace=enlace, fecha=self.fecha_fin_entrega), html=settings.CORREO_VALIDACION_HTML.format(cuarto=cuarto, año=self.year, obra=self.obra, enlace=enlace, fecha=self.fecha_fin_entrega), html_default=True, alternatives=True, silencioso=False)
        except smtplib.SMTPException as excepcion:
            mail_admins(subject="Error", message="Error al enviar correo de validación de HDR." +
                        repr(excepcion), fail_silently=True)

    def asentar_bi(self):
        pass

    def save(self, *args, **kwargs):
        funcion = None
        if self._state.adding:
            # Nueva siempre debe estar Cerrada
            self.estado = 1
            # Buscamos si hay hdr anteriores que tengan un % central o delegación personalizado
            # Si lo encontramos, lo aplicamos
            # Sino buscamos el de la subdelegación
            from django.db.models.functions import Cast, Concat
            from django.db.models import CharField
            personalizada_delegacion = HojaDeRuta.objects.filter(obra=self.obra, gasto_delegacion_personalizado=True).annotate(fecha=Concat(Cast(
                'year', CharField()), Cast('cuarto', CharField()))).order_by('-fecha').first()
            personalizada_central = HojaDeRuta.objects.filter(obra=self.obra, gasto_central_personalizado=True).annotate(fecha=Concat(Cast(
                'year', CharField()), Cast('cuarto', CharField()))).order_by('-fecha').first()
            if not personalizada_delegacion is None:
                self.gasto_delegacion = personalizada_delegacion.gasto_delegacion
                self.gasto_delegacion_personalizado = True
            if not personalizada_central is None:
                self.gasto_central = personalizada_central.gasto_central
                self.gasto_central_personalizado = True
            if self.gasto_delegacion_personalizado == False or self.gasto_central_personalizado == False:
                from general.models import ParametroUnidadOrganizativa
                parametro = ParametroUnidadOrganizativa.objects.filter(unidad=self.obra.subdelegacion).annotate(fecha=Concat(Cast(
                    'year', CharField()), Cast('cuarto', CharField()))).order_by('-fecha').first()
                if self.gasto_delegacion_personalizado == False and not parametro is None and parametro.gasto_delegacion:
                    self.gasto_delegacion = parametro.gasto_delegacion
                if self.gasto_central_personalizado == False and not parametro is None and parametro.gasto_central:
                    self.gasto_central = parametro.gasto_central
        elif self.estado == 2:
            # Abierta
            if self._loaded_values['estado'] == 1:
                # Viene de Cerrada
                # Se debe enviar correo a los jefes de obra avisando de que se ha abierto la HDR
                funcion = getattr(self, 'correo_apertura')
            elif self._loaded_values['estado'] == 3:
                # Viene de Pendiente de validar
                # Se debe enviar correo a los jefes de obra avisando de que se ha rechazado la HDR
                funcion = getattr(self, 'correo_rechazo')
        elif self.estado == 3 and self._loaded_values['estado'] == 2:
            # Pendiente de validar y viene de abierta
            # Se debe enviar correo a administradores y responsables de jefes de obra avisando de que se ha solicitado la validación del HDR
            funcion = getattr(self, 'correo_validacion')
        elif self.estado == 4 and self._loaded_values['estado'] == 3:
            # Validada y viene de Pendiente de validar
            # Se deben asentar los datos en BI
            funcion = getattr(self, 'asentar_bi')
        elif self.estado != self._loaded_values['estado']:
            # Posible estado inconsistente
            raise CustomError(_("Estado inconsistente, no debería cerrarse una HDR Validada"), _(
                "hdr"), status_code=status.HTTP_409_CONFLICT)
        elif self.gasto_central != self._loaded_values['gasto_central']:
            self.gasto_central_personalizado = True
        elif self.gasto_delegacion != self._loaded_values['gasto_delegacion']:
            self.gasto_delegacion_personalizado = True
        super().save(*args, **kwargs)  # Llamada al método padre de guardado
        if funcion:
            try:
                funcion()
            except Exception as excepcion:
                print(repr(excepcion))

    def frontend_url(self):
        """
        Devuelve la URL del objeto para el frontend

        Utiliza el settings para calcular y retornar la url del objeto en el frontend

        :return: URL de frontend
        :rtype: str
        """
        return settings.FRONTEND_URL + "/hdr_excel/" + str(self.pk) + "/"


class HojaDeRutaProduccion(models.Model):
    hoja = models.OneToOneField("hdr.HojaDeRuta", verbose_name=_(
        "hoja de ruta"), on_delete=models.CASCADE, related_name="produccion")
    importe_contrato_mes_1 = models.DecimalField(
        _("importe de producción del contrato inicial para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_mes_2 = models.DecimalField(
        _("importe de producción del contrato inicial para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_mes_3 = models.DecimalField(
        _("importe de producción del contrato inicial para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_mes_4 = models.DecimalField(
        _("importe de producción del contrato inicial para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_resto = models.DecimalField(
        _("importe de producción del contrato inicial para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_proximo = models.DecimalField(
        _("importe de producción del contrato inicial para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_siguiente = models.DecimalField(
        _("importe de producción del contrato inicial para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_contrato_pendiente = models.DecimalField(
        _("importe de producción del contrato inicial para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_mes_1 = models.DecimalField(
        _("importe de producción de ampliaciones para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_mes_2 = models.DecimalField(
        _("importe de producción de ampliaciones para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_mes_3 = models.DecimalField(
        _("importe de producción de ampliaciones para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_mes_4 = models.DecimalField(
        _("importe de producción de ampliaciones para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_resto = models.DecimalField(
        _("importe de producción de ampliaciones para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_proximo = models.DecimalField(
        _("importe de producción de ampliaciones para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_siguiente = models.DecimalField(
        _("importe de producción de ampliaciones para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_ampliaciones_pendiente = models.DecimalField(
        _("importe de producción de ampliaciones para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_mes_1 = models.DecimalField(
        _("importe de producción de coste directo para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_mes_2 = models.DecimalField(
        _("importe de producción de coste directo para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_mes_3 = models.DecimalField(
        _("importe de producción de coste directo para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_mes_4 = models.DecimalField(
        _("importe de producción de coste directo para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_resto = models.DecimalField(
        _("importe de producción de coste directo para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_proximo = models.DecimalField(
        _("importe de producción de coste directo para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_siguiente = models.DecimalField(
        _("importe de producción de coste directo para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_coste_pendiente = models.DecimalField(
        _("importe de producción de coste directo para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_mes_1 = models.DecimalField(
        _("importe de producción de gastos de delegación para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_mes_2 = models.DecimalField(
        _("importe de producción de gastos de delegación para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_mes_3 = models.DecimalField(
        _("importe de producción de gastos de delegación para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_mes_4 = models.DecimalField(
        _("importe de producción de gastos de delegación para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_resto = models.DecimalField(
        _("importe de producción de gastos de delegación para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_proximo = models.DecimalField(
        _("importe de producción de gastos de delegación para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_siguiente = models.DecimalField(
        _("importe de producción de gastos de delegación para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_delegacion_pendiente = models.DecimalField(
        _("importe de producción de gastos de delegación para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_mes_1 = models.DecimalField(
        _("importe de producción de gastos de central para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_mes_2 = models.DecimalField(
        _("importe de producción de gastos de central para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_mes_3 = models.DecimalField(
        _("importe de producción de gastos de central para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_mes_4 = models.DecimalField(
        _("importe de producción de gastos de central para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_resto = models.DecimalField(
        _("importe de producción de gastos de central para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_proximo = models.DecimalField(
        _("importe de producción de gastos de central para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_siguiente = models.DecimalField(
        _("importe de producción de gastos de central para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_central_pendiente = models.DecimalField(
        _("importe de producción de gastos de central para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)

    class Meta:
        verbose_name = _("producción de hoja de ruta")
        verbose_name_plural = _("producciones de hojas de ruta")

    def __str__(self):
        return str(self.hoja) + ' Producción'


class HojaDeRutaCertificacion(models.Model):
    hoja = models.OneToOneField("hdr.HojaDeRuta", verbose_name=_(
        "hoja de ruta"), on_delete=models.CASCADE, related_name="certificacion")
    importe_anterior = models.DecimalField(
        _("importe de certificación hasta fin del año anterior"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_presente = models.DecimalField(
        _("importe de certificación del presente año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_1 = models.DecimalField(
        _("importe de certificación para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_2 = models.DecimalField(
        _("importe de certificación para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_3 = models.DecimalField(
        _("importe de certificación para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_4 = models.DecimalField(
        _("importe de certificación para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_resto = models.DecimalField(
        _("importe de certificación para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_proximo = models.DecimalField(
        _("importe de certificación para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_siguiente = models.DecimalField(
        _("importe de certificación para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_pendiente = models.DecimalField(
        _("importe de certificación para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)

    class Meta:
        verbose_name = _("certificacion de hoja de ruta")
        verbose_name_plural = _("certificaciones de hojas de ruta")

    def __str__(self):
        return str(self.hoja) + ' Certificación'
        
class HojaDeRutaPago(models.Model):
    hoja = models.OneToOneField("hdr.HojaDeRuta", verbose_name=_(
        "hoja de ruta"), on_delete=models.CASCADE, related_name="pago")
    # pago_actualizar = True indica que el pago debe ser actualizado con el coste directo,
    # Si el pago es modificado manualmente se debe poner a False
    pago_actualizar = models.BooleanField(default=True)
    importe_anterior = models.DecimalField(
        _("importe de pago hasta fin del año anterior"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_presente = models.DecimalField(
        _("importe de pago del presente año"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_1 = models.DecimalField(
        _("importe de pago para el primer mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_2 = models.DecimalField(
        _("importe de pago para el segundo mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_3 = models.DecimalField(
        _("importe de pago para el tercer mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_4 = models.DecimalField(
        _("importe de pago para el cuarto mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_resto = models.DecimalField(
        _("importe de pago para el resto del año"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_proximo = models.DecimalField(
        _("importe de pago para el próximo año"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_siguiente = models.DecimalField(
        _("importe de pago para el siguiente año al próximo"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_pendiente = models.DecimalField(
        _("importe de pago para el resto de años"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)

    class Meta:
        verbose_name = _("pago de hoja de ruta")
        verbose_name_plural = _("pagos de hojas de ruta")

    def __str__(self):
        return str(self.hoja) + ' Pago'

class HojaDeRutaPagoAuxiliar(models.Model):
    obra = models.ForeignKey("general.Obra", verbose_name=_(
        "obra asociada"), on_delete=models.CASCADE, related_name="pago_auxiliar")
    year = models.IntegerField(null=False, blank=False, verbose_name=_("año"))
    cuarto = models.IntegerField(
        null=False, blank=False, choices=settings.CUARTOS, verbose_name=_("cuatrimestre"))
    pago = models.ForeignKey("hdr.HojaDeRutaPago", verbose_name=_(
        "pago asociada"), on_delete=models.CASCADE, related_name="pago_auxiliar")

    importe_mes_1 = models.DecimalField(
        _("importe de pago para el primer mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_2 = models.DecimalField(
        _("importe de pago para el segundo mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_3 = models.DecimalField(
        _("importe de pago para el tercer mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_4 = models.DecimalField(
        _("importe de pago para el cuarto mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)

    class Meta:
        verbose_name = _("pago auxiliar de hoja de ruta")
        verbose_name_plural = _("pagos auxiliares de hojas de ruta")

    def __str__(self):
        return str(self.id) + ' Pago auxiliar'

class HojaDeRutaCapitalFinanciero(models.Model):
    hoja = models.OneToOneField("hdr.HojaDeRuta", verbose_name=_(
        "hoja de ruta"), on_delete=models.CASCADE, related_name="capital_financiero")
    importe_anterior = models.DecimalField(
        _("importe de capital financiero hasta fin del año anterior"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_presente = models.DecimalField(
        _("importe de capital financiero del presente año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_1 = models.DecimalField(
        _("importe de capital financiero para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_2 = models.DecimalField(
        _("importe de capital financiero para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_3 = models.DecimalField(
        _("importe de capital financiero para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_mes_4 = models.DecimalField(
        _("importe de capital financiero para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_resto = models.DecimalField(
        _("importe de capital financiero para el resto del año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_proximo = models.DecimalField(
        _("importe de capital financiero para el próximo año"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_siguiente = models.DecimalField(
        _("importe de capital financiero para el siguiente año al próximo"), max_digits=14, decimal_places=2, null=True, blank=True)
    importe_pendiente = models.DecimalField(
        _("importe de capital financiero para el resto de años"), max_digits=14, decimal_places=2, null=True, blank=True)

    class Meta:
        verbose_name = _("capital financiero de hoja de ruta")
        verbose_name_plural = _("capitales financieros de hojas de ruta")

    def __str__(self):
        return str(self.hoja) + ' Capital Financiero'


class HojaDeRutaCobro(models.Model):
    hoja = models.OneToOneField("hdr.HojaDeRuta", verbose_name=_(
        "hoja de ruta"), on_delete=models.CASCADE, related_name="cobro")
    # cobro_actualizar = True indica que el cobro debe ser actualizado con certificacion,
    # Si el cobro es modificado manualmente se debe poner a False
    cobro_actualizar = models.BooleanField(default=True)
    importe_anterior = models.DecimalField(
        _("importe de cobro hasta fin del año anterior"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_presente = models.DecimalField(
        _("importe de cobro del presente año"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_mes_1 = models.DecimalField(
        _("importe de cobro para el primer mes del cuatrimestre"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_mes_2 = models.DecimalField(
        _("importe de cobro para el segundo mes del cuatrimestre"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_mes_3 = models.DecimalField(
        _("importe de cobro para el tercer mes del cuatrimestre"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_mes_4 = models.DecimalField(
        _("importe de cobro para el cuarto mes del cuatrimestre"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_resto = models.DecimalField(
        _("importe de cobro para el resto del año"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_proximo = models.DecimalField(
        _("importe de cobro para el próximo año"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_siguiente = models.DecimalField(
        _("importe de cobro para el siguiente año al próximo"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)
    importe_pendiente = models.DecimalField(
        _("importe de cobro para el resto de años"), max_digits=14, decimal_places=2, default=0, null=True, blank=True)

    class Meta:
        verbose_name = _("cobro de hoja de ruta")
        verbose_name_plural = _("cobros de hojas de ruta")

    def __str__(self):
        return str(self.hoja) + ' Cobro'
        
class HojaDeRutaCobroAuxiliar(models.Model):
    obra = models.ForeignKey("general.Obra", verbose_name=_(
        "obra asociada"), on_delete=models.CASCADE, related_name="cobro_auxiliar")
    year = models.IntegerField(null=False, blank=False, verbose_name=_("año"))
    cuarto = models.IntegerField(
        null=False, blank=False, choices=settings.CUARTOS, verbose_name=_("cuatrimestre"))
    cobro = models.ForeignKey("hdr.HojaDeRutaCobro", verbose_name=_(
        "cobro asociada"), on_delete=models.CASCADE, related_name="cobro_auxiliar")

    importe_mes_1 = models.DecimalField(
        _("importe de cobro para el primer mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_2 = models.DecimalField(
        _("importe de cobro para el segundo mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_3 = models.DecimalField(
        _("importe de cobro para el tercer mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)
    importe_mes_4 = models.DecimalField(
        _("importe de cobro para el cuarto mes del cuatrimestre"), max_digits=14, default=0, decimal_places=2, null=True, blank=True)

    class Meta:
        verbose_name = _("cobro auxiliar de hoja de ruta")
        verbose_name_plural = _("cobros auxiliares de hojas de ruta")

    def __str__(self):
        return str(self.id) + ' Cobro auxiliar'


class Objetivo(models.Model):
    hoja = models.ForeignKey("hdr.HojaDeRuta", verbose_name=_(
        "hoja de ruta"), on_delete=models.CASCADE, related_name="objetivos")
    descripcion = models.TextField(_("descripción"), null=False)
    coste = models.DecimalField(
        _("coste"), max_digits=14, decimal_places=2, default=0.00)
    venta = models.DecimalField(
        _("venta"), max_digits=14, decimal_places=2, default=0.00)

    class Meta:
        verbose_name = _("objetivo")
        verbose_name_plural = _("objetivos")

    def __str__(self):
        return str(self.hoja) + ' - ' + self.descripcion


class BI(models.Model):
    obra = models.ForeignKey("general.Obra", verbose_name=_(
        "obra"), on_delete=models.PROTECT, related_name="bis")
    codigo = models.CharField(_("código"), max_length=20)
    cliente = models.ForeignKey("general.Cliente", verbose_name=_(
        "cliente"), on_delete=models.PROTECT)
    version = models.CharField(_("versión"), max_length=20)
    periodo = models.CharField(_("periodo"), max_length=20)
    concepto = models.CharField(_("concepto"), max_length=255)
    importe = models.DecimalField(
        _("importe"), max_digits=14, decimal_places=2)

    class Meta:
        verbose_name = _("registro Business Intelligence")
        verbose_name_plural = _("registros Business Intelligences")

    def __str__(self):
        return str(self.obra) + '|' + self.codigo
