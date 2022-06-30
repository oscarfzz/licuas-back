from django.db import models
from django.utils.translation import gettext_lazy as _

# Create your models here.


class Divisa(models.Model):
    codigo = models.CharField(
        _("código"), max_length=3, null=False, blank=False)
    descripcion = models.TextField(_("descripción"), null=False, blank=False)

    class Meta:
        verbose_name = _("divisa")
        verbose_name_plural = _("divisas")

    def __str__(self):
        return self.descripcion
