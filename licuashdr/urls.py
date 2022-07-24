"""licuashdr URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.urls import include, path
from general.views import importar_csv
from hdr.views import hdr_en_cuatrimestre, abrir_hdrs, hdr_por_obra_year_cuarto, dashboard, tablero, tableroObras


urlpatterns = [
    # web pública
    # para logarse y ver el http://localhost:8000/oauth/applications/
    path('admin/', admin.site.urls),
    path('oauth/', include('oauth2_provider.urls', namespace='oauth2_provider')),
    # endpoints api
    path('api/v1/seguridad/', include('seguridad.urls')),
    path('api/v1/general/', include('general.urls')),
    path('api/v1/lista/', include('lista.urls')),
    path('api/v1/hdr/', include('hdr.urls')),
    path('api/v1/csv/', importar_csv, name='csv'),
    path('api/v1/hdr_obra_year_cuarto/',
         hdr_por_obra_year_cuarto, name='hdr-obra-year-cuarto'),
    path('api/v1/hdr_cuatrimestre/', hdr_en_cuatrimestre, name='hdr-cuarto'),
    path('api/v1/hdr_abrir/', abrir_hdrs, name='hdr-abrir'),
    path('api/v1/dashboard/', dashboard, name='dashboard'),
    path('api/v1/tablero/', tablero, name='tablero'),
    path('api/v1/tablero_obras/', tableroObras, name='tableroObras')
]
