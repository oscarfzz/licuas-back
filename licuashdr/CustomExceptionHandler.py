from rest_framework.views import exception_handler
from django.db import transaction


@transaction.atomic
def customExceptionHandler(exc, context):

    respuesta = exception_handler(exc, context)
    transaction.set_rollback(True)

    return respuesta
