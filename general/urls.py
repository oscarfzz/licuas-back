from rest_framework.urlpatterns import format_suffix_patterns
from django.conf.urls import url, include
from django.urls import path
from rest_framework.routers import DefaultRouter


from general.views import *

router = DefaultRouter()

router.register(r'zona', ZonaViewSet)
router.register(r'grupo', GrupoViewSet)
router.register(r'situacion', SituacionViewSet)
router.register(r'ambito', AmbitoViewSet)
router.register(r'clasificacion', ClasificacionGtoViewSet)
router.register(r'actividad', ActividadViewSet)
router.register(r'empresa', EmpresaViewSet)
router.register(r'cliente', ClienteViewSet)
router.register(r'obra', ObraViewSet)
router.register(r'responsable', ResponsableViewSet)
router.register(r'empleado', EmpleadoViewSet)
router.register(r'cambio', CambioDivisaViewSet)
router.register(r'unidad_organizativa', UnidadOrganizativaViewSet)
router.register(r'parametro_unidad_organizativa',
                ParametroUnidadOrganizativaViewSet)
router.register(r'divisas', DivisaViewSet)
router.register(r'ampliaciones-presupuesto', AmpliacionPresupuestoObraViewSet)
router.register(r'ampliaciones-coste', AmpliacionCosteObraViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
]
