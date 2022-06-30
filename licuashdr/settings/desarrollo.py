from licuashdr.settings.base import *

DEBUG = True

SECRET_KEY = '@z9fttd(4u-(t1)%e@abti52=jebz#=s!h0xyon@4cc2bd=_r-'

ALLOWED_HOSTS = ['*']

DATABASES = {
   'default': {
     'ENGINE': 'django.db.backends.postgresql',
     'NAME': 'licuas',
     'USER': 'excem',
     'PASSWORD': 'Sandav2019',
     'HOST': 'homiii.com',
     # 'HOST': '82.223.8.203',
     'PORT': '8003',
     'ATOMIC_REQUESTS': True,
   }
}

USE_TZ = False

# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql',
#         'NAME': 'licuas',
#         'USER': 'admin',
#         'PASSWORD': 'admin',
#         'HOST': '192.168.1.230',
#         'PORT': '5432',
#         'ATOMIC_REQUESTS': True,
#     }
# }

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': './licuas.log',
        },
        # 'terminal': {
        #     'level': 'DEBUG',
        #     'class': 'logging.StreamHandler'
        # },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            # 'handlers': ['file', 'terminal'],
            'level': 'DEBUG',
            'propagate': True,
        },
    },
}

CORS_ORIGIN_ALLOW_ALL = True


STATIC_ROOT = None
STATIC_URL = '/static/'
STATICFILES_DIRS = [
    os.path.join(BASE_DIR, "static"),
]

EMAIL_HOST = 'smtp.sandav.es'
EMAIL_PORT = '587'
EMAIL_HOST_USER = 'gdpr@sandav.es'
EMAIL_HOST_PASSWORD = 'Sandav2018'
EMAIL_USE_TLS = True
EMAIL_USE_SSL = False

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

FRONTEND_URL = "http://127.0.0.1:3000"
