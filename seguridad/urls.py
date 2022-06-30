
from django.conf.urls import url, include
from rest_framework.routers import DefaultRouter
from seguridad import views

router = DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)
router.register(r'permisos', views.PermisosViewSet)

urlpatterns = [
    url(r'^', include(router.urls)),
]
