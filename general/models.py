from django.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import User, Group
from django.conf import settings
from django.core.exceptions import ValidationError
from django.db.models.signals import post_save
from django.dispatch import receiver

from rest_framework import status
from licuashdr.CustomError import CustomError
from hdr.models import HojaDeRuta


@receiver(post_save, sender=User)
def autoEmpleado(sender, instance, created, raw, **kwargs):

    if created or not hasattr(instance.empleado, "id"):
        instance.empleado = Empleado.objects.create(
            usuario=instance, codigo=instance.username)

    if instance.groups.count() == 0:
        try:
            grupoJefe = Group.objects.get(3)
            instance.groups.add(grupoJefe)
        except:
            pass


def codigoEmpleadoRepetido(codigo, empleadoId=None):
    empleado_repetido = Empleado.objects.all().exclude(
        pk=empleadoId).filter(codigo=codigo)

    if len(empleado_repetido) > 0:
        raise CustomError(_("El código de empleado está repetido") % {
            "código": codigo}, _("Empleado"), status_code=status.HTTP_409_CONFLICT)


class Zona (models.Model):
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la zona"), unique=True)

    class Meta:
        verbose_name = _('zona')
        verbose_name_plural = _('zonas')

    def __str__(self):
        return self.nombre


class Grupo (models.Model):
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la grupo"), unique=True)

    class Meta:
        verbose_name = _('grupo')
        verbose_name_plural = _('grupos')

    def __str__(self):
        return self.nombre


class Actividad (models.Model):
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la actividad"), unique=True)

    class Meta:
        verbose_name = _('actividad')
        verbose_name_plural = _('actividades')

    def __str__(self):
        return self.nombre


class Situacion (models.Model):
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la situacion"), unique=True)

    class Meta:
        verbose_name = _('situacion')
        verbose_name_plural = _('situaciones')

    def __str__(self):
        return self.nombre


class Ambito (models.Model):
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la ambito"), unique=True)

    class Meta:
        verbose_name = _('ambito')
        verbose_name_plural = _('ambitos')

    def __str__(self):
        return self.nombre


class Clasificacion_gto (models.Model):
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la ambito"), unique=True)

    class Meta:
        verbose_name = _('clasificacion')
        verbose_name_plural = _('clasificaciones')

    def __str__(self):
        return self.nombre


class CambioDivisa(models.Model):
    divisa = models.ForeignKey("divisas.Divisa", verbose_name=_(
        "divisa"), on_delete=models.CASCADE, null=False, related_name='cambios')
    year = models.IntegerField(null=False, blank=False, verbose_name=_("año"))
    cuarto = models.IntegerField(
        null=False, blank=False, choices=settings.CUARTOS, verbose_name=_("cuatrimestre"))
    importe = models.DecimalField(null=False, blank=False, max_digits=10,
                                  decimal_places=6, verbose_name=_("importe del cambio respecto al EUR"))

    class Meta:
        verbose_name = _("cambio de divisa")
        verbose_name_plural = _("cambios de divisa")
        unique_together = [['divisa', 'year', 'cuarto'], ]

    def __str__(self):
        return str(self.year) + '/' + str(self.cuarto) + '/' + self.divisa.codigo


class Empresa (models.Model):
    codigo = models.CharField(_("codigo"), db_column="codigo", max_length=20,
                              null=False, blank=False, help_text=_("Codigo empresa bi"), unique=True)
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la empresa"))

    class Meta:
        verbose_name = _('empresa')
        verbose_name_plural = _('empresas')
        indexes = [models.Index(fields=['codigo', ]), ]

    def __str__(self):
        return self.codigo + ' - ' + self.nombre


class Cliente (models.Model):
    codigo = models.CharField(_("código"), max_length=50, null=False,
                              blank=False, help_text=_("código único de cliente"), unique=True)
    nombre = models.CharField(_("nombre"), db_column="nombre", max_length=255,
                              null=False, blank=False, help_text=_("Nombre de la empresa"))

    class Meta:
        verbose_name = _('cliente')
        verbose_name_plural = _('clientes')
        indexes = [models.Index(fields=['codigo', ]), ]

    def __str__(self):
        return self.nombre


class Obra (models.Model):
    codigo = models.CharField(_("codigo"), db_column="codigo", max_length=255,
                              null=False, blank=False, help_text=_("Codigo de la obra"))
    descripcion = models.TextField(
        _("descripcion"), null=False, blank=False, help_text=_("descripcion de la obra"))
    empresa = models.ForeignKey(Empresa, related_name='obras',  blank=False, null=False,
                                on_delete=models.PROTECT, verbose_name=_("empresas"), help_text=_("empresa a la que pertence la obra"))
    cliente = models.ForeignKey(Cliente, related_name='obras',  blank=False, null=False,
                                on_delete=models.PROTECT, verbose_name=_("clientes"), help_text=_("cliente a la que pertence la obra"))
    zona = models.ForeignKey(Zona, related_name='obras',  blank=True, null=True,
                             on_delete=models.PROTECT, verbose_name=_("zonas"), help_text=_("zona a la que pertence la obra"))
    grupo = models.ForeignKey(Grupo, related_name='obras',  blank=True, null=True,
                              on_delete=models.PROTECT, verbose_name=_("grupos"), help_text=_("grupo a la que pertence la obra"))
    actividad = models.ForeignKey(Actividad, related_name='obras',  blank=True, null=True,
                                  on_delete=models.PROTECT, verbose_name=_("actividades"), help_text=_("actividad a la que pertence la obra"))
    situacion = models.ForeignKey(Situacion, related_name='obras',  blank=True, null=True,
                                  on_delete=models.PROTECT, verbose_name=_("situaciones"), help_text=_("situacion a la que pertence la obra"))
    ambito = models.ForeignKey(Ambito, related_name='obras',  blank=True, null=True,
                               on_delete=models.PROTECT, verbose_name=_("ambitos"), help_text=_("ambito a la que pertence la obra"))
    clasificacion = models.ForeignKey(Clasificacion_gto, related_name='obras',  blank=True, null=True,
                                      on_delete=models.PROTECT, verbose_name=_("Clasificaciones"), help_text=_("clasificacion a la que pertence la obra"))
    responsables = models.ManyToManyField(User, related_name='obras', blank=True,
                                          help_text=_("responsables"),  verbose_name=_('usuario con perfil responsable de obra'))
    obsoleta = models.BooleanField(_("obsoleta"), null=False, default=False, help_text=_(
        "indica si es una obra obsoleta"))
    bi = models.BooleanField(_("se usará en BI"), null=False, default=True, help_text=_(
        "indica si se usará en los cálculos BI"))
    codigo_estudio = models.CharField(
        _("código de estudio"), max_length=255, help_text=_("código de estudio asociado"), null=True)
    tipo = models.BooleanField(_("obra"), null=False, default=True, help_text=_(
        "indica si es una obra o un servicio"))
    activo = models.BooleanField(
        _("activo"), null=False, default=True, help_text=_("indica si está activa"))
    plazo = models.IntegerField(_("plazo inicial oficial"), null=False,
                                blank=False, help_text=_("plazo inicial oficial en meses"), default=0)
    prorroga = models.IntegerField(
        _("prórrogas aprobadas"), help_text=_("prórrogas aprobadas en meses"), default=0)
    fecha_fin = models.DateField(_("fecha de fin oficial"), auto_now=False,
                                 auto_now_add=False, help_text=_("fecha del fin de obra oficial"), null=True, blank=True)
    fecha_prevista_fin = models.DateField(_("fecha prevista de fin"), auto_now=False,
                                          auto_now_add=False, help_text=_("fecha prevista real del fin de obra"), null=True, blank=True)
    presupuesto = models.DecimalField(_("presupuesto de adjudicación"), max_digits=14,
                                      decimal_places=2, help_text=_("importe del presupuesto de adjudicación"), default=0.00)
    coste_previsto = models.DecimalField(_("coste previsto"), max_digits=14,
                                         decimal_places=2, help_text=_("importe del coste previsto"), default=0.00)
    participacion_licuas = models.DecimalField(_("participación licuas"), max_digits=14,
                                      decimal_places=2, help_text=_("participación licuas"), default=1.00)
    divisa = models.ForeignKey("divisas.Divisa", verbose_name=_(
        "divisa"), on_delete=models.PROTECT, help_text=_("divisa asociada"), default=2, related_name='obras')
    orden = models.IntegerField(_("orden"), null=True, blank=True)
    delegacion = models.ForeignKey("general.UnidadOrganizativa", verbose_name=_(
        "delegación"), on_delete=models.PROTECT, null=True, blank=True, related_name='obras_delegacion')
    subdelegacion = models.ForeignKey("general.UnidadOrganizativa", verbose_name=_(
        "subdelegación"), on_delete=models.PROTECT, null=True, blank=True, related_name='obras_subdelegacion')
    observaciones = models.TextField(
        _("observaciones"), null=True, blank=True, help_text=_("observaciones de la obra"))

    class Meta:
        verbose_name = _("obra")
        verbose_name_plural = _("obras")
        unique_together = [['codigo', 'empresa']]
        indexes = [models.Index(fields=['codigo', 'empresa']), ]

    def __str__(self):
        return self.empresa.codigo + '-' + self.codigo


class AmpliacionPresupuestoObra(models.Model):
    obra = models.ForeignKey("general.Obra", verbose_name=_(
        "obra"), on_delete=models.CASCADE, related_name="ampliaciones_presupuesto", help_text=_("obra de la ampliación de presupuesto"))
    fecha = models.DateField(_("fecha"), auto_now=False,
                             auto_now_add=False, help_text=_("fecha de la ampliación de presupuesto"))
    descripcion = models.TextField(
        _("descripción"), null=True, help_text=_("descripción de la ampliación de presupuesto"))
    importe = models.DecimalField(
        _("importe"), max_digits=14, decimal_places=2, help_text=_("importe de la ampliación de presupuesto"))

    def save(self, *args, **kwargs):
        cuatrimestre = 1
        if (self.fecha.month > 8):
            cuatrimestre = 3
        elif (self.fecha.month > 4):
            cuatrimestre = 2

        # Buscamos si la obra tiene un hdr abierto para ese año y cuatrimestre
        hdrs_fecha = HojaDeRuta.objects.filter(obra__pk=self.obra.pk, year=self.fecha.year, cuarto=cuatrimestre, estado=2).count()
        
        if hdrs_fecha == 0:
            raise CustomError(_("No hay ningún HDR abierto para esta obra y cuatrimestre"), self.fecha, status_code=status.HTTP_406_NOT_ACCEPTABLE)
            
        super().save(*args, **kwargs)  # Llamada al método padre de guardado
        

    class Meta:
        verbose_name = _("ampliación de presupuesto de obra")
        verbose_name_plural = _("ampliaciones de presupuesto de obra")

    def __str__(self):
        return str(self.obra) + ' - ' + str(self.fecha) + ' - ' + str(self.importe)


class AmpliacionCosteObra(models.Model):
    obra = models.ForeignKey("general.Obra", verbose_name=_(
        "obra"), on_delete=models.CASCADE, related_name="ampliaciones_coste", help_text=_("obra de la ampliación de coste"))
    fecha = models.DateField(_("fecha"), auto_now=False,
                             auto_now_add=False, help_text=_("fecha de la ampliación de coste"))
    descripcion = models.TextField(
        _("descripción"), help_text=_("descripción de la ampliación de coste"))
    importe = models.DecimalField(
        _("importe"), max_digits=14, decimal_places=2, help_text=_("importe de la ampliación de coste"))

    class Meta:
        verbose_name = _("ampliación de coste de obra")
        verbose_name_plural = _("ampliaciones de coste de obra")

    def __str__(self):
        return str(self.obra) + ' - ' + str(self.fecha) + ' - ' + str(self.importe)


class Empleado(models.Model):
    usuario = models.OneToOneField("auth.User", verbose_name=_(
        "usuario"), on_delete=models.CASCADE, related_name='empleado', help_text='usuario asociado al empleado')
    responsable = models.ForeignKey("auth.User", verbose_name=_(
        "responsable"), on_delete=models.CASCADE, related_name='subordinados', help_text='responsable del empleado', null=True, blank=False)
    codigo = models.CharField(_("código"), max_length=50, null=False,
                              blank=False, unique=True, help_text=_("código único de empleado"))

    class Meta:
        verbose_name = _("empleado")
        verbose_name_plural = _("empleados")
        indexes = [models.Index(fields=['codigo', ]), ]

    def __str__(self):
        return self.usuario.username

    def save(self, *args, **kwargs):
        # Comprobamos que según el perfil, puede elegirse un responsable:
        # Perfil 1 - Sin responsable
        # Perfil 2 - Respo perfil 1
        # Perfil 3 - Respo perfil 2/3
        if self.usuario.groups.filter(pk=1) and hasattr(self.responsable, 'id'):
            raise ValidationError(
                "Un usuario administrador no puede tener responsables asociados", code=500)
        elif (self.usuario.groups.filter(pk=2) | self.usuario.groups.filter(pk=3)) and hasattr(self.responsable, 'id') and not (self.responsable.groups.filter(pk=1) | self.responsable.groups.filter(pk=2)):
            raise ValidationError(
                "Un usuario jefe de obra o responsable, sólo puede tener como responsable un usuario jefe de equipo o administrador", code=500)
        # Si el código viene en blanco, lo rellenamos con el username
        if self.codigo == None:
            self.codigo = self.usuario.username

        # Comprobamos si el código de empleado está repetido
        codigoEmpleadoRepetido(self.codigo, self.pk)

        super().save(*args, **kwargs)  # Llamada al método padre de guardado


class UnidadOrganizativa(models.Model):
    descripcion = models.TextField(verbose_name=_("descripción"))
    padre = models.ForeignKey(
        "self", on_delete=models.PROTECT, related_name="subunidades", null=True)

    class Meta:
        verbose_name = _("unidad organizativa")
        verbose_name_plural = _("unidades organizativas")
        unique_together = [['descripcion', 'padre'], ]

    def __str__(self):
        return self.descripcion

    def save(self, *args, **kwargs):
        # Comprobamos que sólo hay 2 niveles
        if hasattr(self.padre, 'padre') and self.padre.padre is not None:
            raise ValidationError("Sólo puede haber dos niveles", code=500)
        # Comprobamos que si tiene padre no tenga descendentes
        elif self.pk is not None and self.padre is not None:
            descendentes = UnidadOrganizativa.objects.all(
            ).select_related().filter(padre=self.pk)

            if len(descendentes) > 0:
                raise ValidationError("Sólo puede haber dos niveles", code=500)

        super().save(*args, **kwargs)  # Llamada al método padre de guardado


class ParametroUnidadOrganizativa(models.Model):
    unidad = models.ForeignKey("general.UnidadOrganizativa", verbose_name=_(
        "unidad"), on_delete=models.CASCADE, null=False)
    year = models.IntegerField(null=False, blank=False, verbose_name=_("año"))
    cuarto = models.IntegerField(
        null=False, blank=False, choices=settings.CUARTOS, verbose_name=_("cuatrimestre"))
    gasto_delegacion = models.DecimalField(
        _("% de gasto delegación"), max_digits=5, decimal_places=2, null=False)
    gasto_central = models.DecimalField(
        _("% de gasto central"), max_digits=5, decimal_places=2, null=False)

    class Meta:
        verbose_name = _("parametro de unidad organizativa")
        verbose_name_plural = _("parametros de unidad organizativa")
        unique_together = [['unidad', 'year', 'cuarto'], ]

    def __str__(self):
        return str(self.year) + '/' + str(self.cuarto) + '/' + self.unidad.descripcion
