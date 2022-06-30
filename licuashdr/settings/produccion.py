from licuashdr.settings.base import *
import os

SECRET_KEY = os.getenv(
    'SECRET_KEY', '!5xzake&%a6^8tr3a&*q*np05^kp@!idqvel8u#n@(#f3+td$u')

DEBUG = False

ALLOWED_HOSTS = ['api.licuas.sandav.es']

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('DB_NAME', 'ciFnOgIpel2k8ftxw4o8'),
        'USER': os.getenv('DB_USER', 'excem'),
        'PASSWORD': os.getenv('DB_PWD', 'Sandav2019'),
        'HOST': os.getenv('DB_HOST', '127.0.0.1'),
        'PORT': os.getenv('DB_PORT', '8003'),
        'ATOMIC_REQUESTS': True,
    }
}

#CORS_ORIGIN_ALLOW_ALL = False
CORS_ORIGIN_ALLOW_ALL = True

CORS_ORIGIN_WHITELIST = [
    'https://licuas.sandav.es',
    'https://www.licuas.sandav.es',
]

FRONTEND_URL = os.getenv('FRONTEND_URL', "https://licuas.sandav.es")

STATIC_ROOT = os.path.join(BASE_DIR, "static")
# no tenemos la cuenta de correo del cliente asi que se establece como back hasta que nos la den para evitar errores.
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'