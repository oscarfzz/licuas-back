from django.conf.urls import url, include
from rest_framework.routers import DefaultRouter
from hdr.views import HojaDeRutaViewSet, HojaDeRutaCertificacionViewSet, HojaDeRutaPagoViewSet, HojaDeRutaPagoExcelViewSet, HojaDeRutaProduccionViewSet, HojaDeRutaCobroViewSet, BIViewSet, ObjetivoViewSet, HojaDeRutaExcelViewSet, HojaDeRutaExcelAdminViewSet, HojaDeRutaProduccionExcelViewSet, HojaDeRutaCertificacionExcelViewSet, HojaDeRutaCobroExcelViewSet, ObjetivoExcelViewSet

router = DefaultRouter()

router.register(r'hojas', HojaDeRutaViewSet)
router.register(r'certificacion', HojaDeRutaCertificacionViewSet)
router.register(r'pago', HojaDeRutaPagoViewSet)
router.register(r'produccion', HojaDeRutaProduccionViewSet)
router.register(r'cobros', HojaDeRutaCobroViewSet)
router.register(r'objetivos', ObjetivoViewSet)
router.register(r'bi', BIViewSet)
router.register(r'excel', HojaDeRutaExcelViewSet)
router.register(r'excel-admin', HojaDeRutaExcelAdminViewSet)
router.register(r'excel-certificacion', HojaDeRutaCertificacionExcelViewSet)
router.register(r'excel-pago', HojaDeRutaPagoExcelViewSet)
router.register(r'excel-produccion', HojaDeRutaProduccionExcelViewSet)
router.register(r'excel-cobro', HojaDeRutaCobroExcelViewSet)
router.register(r'excel-objetivos', ObjetivoExcelViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
]
