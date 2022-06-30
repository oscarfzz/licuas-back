from django.contrib import admin
from hdr.models import HojaDeRuta, HojaDeRutaProduccion, HojaDeRutaCobro, HojaDeRutaCertificacion, Objetivo, BI
# Register your models here.
admin.site.register(HojaDeRuta)
admin.site.register(HojaDeRutaProduccion)
admin.site.register(HojaDeRutaCobro)
admin.site.register(HojaDeRutaCertificacion)
admin.site.register(Objetivo)
admin.site.register(BI)
