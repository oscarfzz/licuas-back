from django.http import HttpResponse
from openpyxl import Workbook
from openpyxl.writer.excel import save_virtual_workbook
import os
import time

# Create your views here.


def exportar_modelo_a_excel(models, queryset):

    dest_filename = str(models._meta) + time.strftime("%y%m%d%H%M%S") + '.xlsx'

    wb = Workbook()
    ws1 = wb.active
    ws1.title = str(models._meta)

    # Titulos cabecera
    campos = models._meta.get_fields()
    cabecera = []
    for campo in campos:
        # Las relaciones inversas también las trae get_fields pero no se pueden exportar y no son datos de la tabla en si
        es_relacion_inversa = str(type(campo)).find('.reverse_related.') != -1
        if not es_relacion_inversa:
            cabecera.append(campo.name)
    ws1.append(cabecera)

    # Los datos de cada uno de esos campos de cabecera
    for dato in queryset:
        fila = []
        for campo in cabecera:
            valor = getattr(dato, campo)
            if hasattr(valor, 'pk'):
                valor = getattr(valor, 'pk')
            fila.append(valor)
        ws1.append(fila)

    try:
        response = HttpResponse(content=save_virtual_workbook(
            wb), content_type='application/ms-excel')
        response['Content-Disposition'] = 'attachment; filename=' + dest_filename
        # Estas dos líneas es para poder ver el archivo que he generado
        #dest_filename = os.path.expanduser('~/Downloads/' + dest_filename )
        #wb.save(filename = dest_filename)
    except PermissionError:
        print('Problema con los permisos sobre el fichero ' + dest_filename)
    except:
        print(' Excepción no controlada al abrir el excel de tareas generado')

    return response


def enviar_correo(asunto, correo_desde, correos_a, texto=None, html=None, html_default=True, alternatives=True, silencioso=False):
    from django.core.mail import EmailMultiAlternatives
    if html_default and html:
        mensaje = EmailMultiAlternatives(asunto, html, correo_desde, correos_a)
        mensaje.content_subtype = "html"
    elif not html_default and texto:
        mensaje = EmailMultiAlternatives(
            asunto, texto, correo_desde, correos_a)
    else:
        raise ValueError
    if alternatives:
        if texto and html_default:
            mensaje.attach_alternative(texto, "text/plain")
        elif html and not html_default:
            mensaje.attach_alternative(html, "text/html")
    # TODO
    # for indice,archivo in enumerate([adjuntos]):
    #     fp = open(archivo, 'rb')
    #     imagen = MIMEImage(fp.read())
    #     fp.close()
    #     imagen.add_header('Content-ID', '<{}>'.format(indice.__str__()))
    #     mensaje.attach(imagen)
    mensaje.send(fail_silently=silencioso)
