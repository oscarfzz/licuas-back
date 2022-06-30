from django.utils.translation import gettext_lazy as _
CORREO_APERTURA_HTML = _('''
<h1>Licuas</h1>
<p>Se ha abierto la Hoja De Ruta correspondiente al cuarto {cuarto} del año {año} para la obra {obra}.</p>
<p>La fecha límite para la validación es {fecha}</p>
<p style="text-align:center">Puedes acceder a la Hoja De Ruta a través de <a href="{enlace}">este</a> enlace.</p>
<p>Muchas gracias</p>
<h4>Licuas</h4>
''')
CORREO_APERTURA = _('''
Licuas
Se ha abierto la Hoja De Ruta correspondiente al cuarto {cuarto} del año {año} para la obra {obra}.
La fecha límite para la validación es {fecha}
Puedes acceder a la Hoja De Ruta copiando y pegando el siguiente enlace en tu navegador: {enlace}
Muchas gracias
''')
CORREO_RECHAZO_HTML = _('''
<h1>Licuas</h1>
<p>Se ha rechazado la Hoja De Ruta correspondiente al cuarto {cuarto} del año {año} para la obra {obra}.</p>
<p>La fecha límite para la validación es {fecha}</p>
<p style="text-align:center">Puedes acceder a la Hoja De Ruta a través de <a href="{enlace}">este</a> enlace.</p>
<p>Muchas gracias</p>
<h4>Licuas</h4>
''')
CORREO_RECHAZO = _('''
Licuas
Se ha rechazado la Hoja De Ruta correspondiente al cuarto {cuarto} del año {año} para la obra {obra}.
La fecha límite para la validación es {fecha}
Puedes acceder a la Hoja De Ruta copiando y pegando el siguiente enlace en tu navegador: {enlace}
Muchas gracias
''')
CORREO_VALIDACION_HTML = _('''
<h1>Licuas</h1>
<p>Se ha solicitado la validación de la Hoja De Ruta correspondiente al cuarto {cuarto} del año {año} para la obra {obra}.</p>
<p>La fecha límite para la validación es {fecha}</p>
<p style="text-align:center">Puedes acceder a la Hoja De Ruta a través de <a href="{enlace}">este</a> enlace.</p>
<p>Muchas gracias</p>
<h4>Licuas</h4>
''')
CORREO_VALIDACION = _('''
Licuas
Se ha solicitado la validación de la Hoja De Ruta correspondiente al cuarto {cuarto} del año {año} para la obra {obra}.
La fecha límite para la validación es {fecha}
Puedes acceder a la Hoja De Ruta copiando y pegando el siguiente enlace en tu navegador: {enlace}
Muchas gracias
''')
