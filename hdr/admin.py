from django.contrib import admin
from hdr.models import HojaDeRuta, HojaDeRutaProduccion, HojaDeRutaPagoAuxiliar, HojaDeRutaCobro, HojaDeRutaCertificacion, Objetivo, BI, HojaDeRutaCapitalFinanciero,HojaDeRutaPago
# Register your models here.
admin.site.register(HojaDeRuta)
admin.site.register(HojaDeRutaProduccion)
admin.site.register(HojaDeRutaCobro)
admin.site.register(HojaDeRutaCertificacion)
admin.site.register(HojaDeRutaCapitalFinanciero)
admin.site.register(HojaDeRutaPago)
admin.site.register(HojaDeRutaPagoAuxiliar)
admin.site.register(Objetivo)
admin.site.register(BI)
