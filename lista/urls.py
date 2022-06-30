from rest_framework.urlpatterns import format_suffix_patterns
from django.conf.urls import url, include
from django.urls import path
from rest_framework.routers import DefaultRouter

from lista.views import *

router = DefaultRouter()

router.register(r'empresa', ListaEmpresaViewSet)
router.register(r'cliente', ListaClienteViewSet)
router.register(r'obra', ListaObraViewSet)
router.register(r'administrador', ListaAdministradorViewSet)
router.register(r'jefe_responsable', ListaJefeResponsableViewSet)
router.register(r'responsable', ListaResponsableViewSet)
router.register(r'responsable_o_jefe', ListaResponsableOJefeViewSet)
router.register(r'subdelegacion', ListaSubdelegacionViewSet)
router.register(r'delegacion', ListaDelegacionViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
    path('delegaciones_subdelegaciones/', delegacionesSubdelegaciones, name='delegacionesSubdelegaciones')
]
