from general.models import Empresa, Cliente, Empleado, Zona, Grupo, Actividad, Situacion, Ambito, Clasificacion_gto
from divisas.models import Divisa
from django.db.utils import DataError
from django.apps import apps
from django.db import transaction, IntegrityError
from django.contrib.auth.models import Group, User
from django.conf import settings


def importarCSV(archivo, aplicacion, modelo, cabecera, delimitador, encoding, pk, campos):
    """
    Función para importar un archivo CSV en una entidad

    Permite cargar los datos de un archivo CSV para cualquier modelo de django, parametrizando los campos a actualizados y el campo usado para búsqueda de registros

    :param archivo: Ruta completa y nombre del archivo CSV a importar
    :type archivo: str
    :param aplicacion: Nombre de la aplicación Django que contiene el modelo que se debe importar
    :type aplicacion: str
    :param modelo: Nombre del modelo Django que se quiere importar
    :type modelo: str
    :param cabecera: Indica si el archivo CSV contiene una cabecera son valores
    :type cabecera: bool
    :param delimitador: Indica el caracter delimitador que se usa en el archivo CSV
    :type delimitador: str
    :param encoding: Indica la codificación usada en el archivo CSV
    :type encoding: str
    :param pk: Indica el campo que se usará para buscar en registros en la base de datos. Se corresponde con los valores de la primera columna del archivo CSV.
    :type pk: str
    :param campos: Lista de campos que se deben introducir en la base de datos a partir de dla primera columna del archivo CSV.
    :type campos: list
    :raises LookupError: Si no se ha conseguido localizar el modelo a importar
    :raises Exception: Si hay alguna excepción no controlada
    :raises UnicodeDecodeError: Si hay problemas con la decodificación del archivo
    :return: Tupla que contiene los registros creados, actualizados y erróneos que se han tratado
    :rtype: tuple
    """
    try:
        entidad = apps.get_model(aplicacion, modelo)
    except LookupError as error:
        # No se ha encontrado el modelo
        raise error
    import csv
    actualizados = 0
    creados = 0
    errores = 0
    try:
        with open(settings.PATH_EXCEL + "/" + archivo, mode='r', newline='', encoding=encoding) as csvfile:
            filas = csv.reader(csvfile, delimiter=delimitador)
            for indice, fila in enumerate(filas):
                if indice == 0 and cabecera:
                    pass
                else:
                    try:
                        defaults = {}
                        for columna, campo in enumerate(campos, start=1):
                            defaults.update({campo: fila[columna]})
                        parametros = {pk: fila[0],
                                      "defaults": defaults}
                        obj, created = entidad.objects.update_or_create(
                            **parametros)
                        if created:
                            creados += 1
                        else:
                            actualizados += 1
                    except DataError as error:
                        # Error de datos (demasiado largo, inválido...)
                        print(error)
                        errores += 1
                    except Exception as error:
                        # Error no controlado
                        raise error
    except UnicodeDecodeError as error:
        # Error de codificación
        raise error

    return (creados, actualizados, errores)


def empresaCSVImport(archivo, cabecera=True, delimitador=";", encoding="iso8859_15", atomic=True):
    """
    Importar un archivo CSV de Empresas

    Importa los registros de un archvio CSV de Empresas usando el campo 'codigo' para buscar registros similares y rellenando el campo 'nombre'.

    :param archivo: Ruta completa y nombre del archivo CSV
    :type archivo: str
    :param cabecera: Indica si el archivo contiene una cabecera sin valor, defaults to True
    :type cabecera: bool, optional
    :param delimitador: Caracter que se utiliza como delimitador en el archivo CSV, defaults to ";"
    :type delimitador: str, optional
    :param encoding: Codificación del archivo CSV, defaults to "ansi"
    :type encoding: str, optional
    :param atomic: Indica si se debe realizar una transacción única contra la base de datos, defaults to True
    :type atomic: bool, optional
    :raises IntegrityError: Problemas al guardar en BBDD
    :return: Tupla que contiene los registros creados, actualizados y erróneos que se han tratado
    :rtype: tuple
    """
    pk = "codigo"
    campos = ["nombre", ]
    creados = 0
    actualizados = 0
    errores = 0
    if atomic:
        try:
            with transaction.atomic():
                (creados, actualizados, errores) = importarCSV(archivo=archivo, aplicacion="general",
                                                               modelo="Empresa", cabecera=cabecera, delimitador=delimitador, encoding=encoding, pk=pk, campos=campos)
        except IntegrityError as error:
            # Se ha hecho rollback de la transacción completa
            raise error
    else:
        (creados, actualizados, errores) = importarCSV(archivo=archivo, aplicacion="general",
                                                       modelo="Empresa", cabecera=cabecera, delimitador=delimitador, encoding=encoding, pk=pk, campos=campos)
    return (creados, actualizados, errores)


def clienteCSVImport(archivo, cabecera=True, delimitador=";", encoding="iso8859_15", atomic=True):
    """
    Importar un archivo CSV de Clientes

    Importa los registros de un archvio CSV de Clientes usando el campo 'codigo' para buscar registros similares y rellenando el campo 'nombre'.

    :param archivo: Ruta completa y nombre del archivo CSV
    :type archivo: str
    :param cabecera: Indica si el archivo contiene una cabecera sin valor, defaults to True
    :type cabecera: bool, optional
    :param delimitador: Caracter que se utiliza como delimitador en el archivo CSV, defaults to ";"
    :type delimitador: str, optional
    :param encoding: Codificación del archivo CSV, defaults to "ansi"
    :type encoding: str, optional
    :param atomic: Indica si se debe realizar una transacción única contra la base de datos, defaults to True
    :type atomic: bool, optional
    :raises IntegrityError: Problemas al guardar en BBDD
    :return: Tupla que contiene los registros creados, actualizados y erróneos que se han tratado
    :rtype: tuple
    """
    pk = "codigo"
    campos = ["nombre", ]
    creados = 0
    actualizados = 0
    errores = 0
    if atomic:
        try:
            with transaction.atomic():
                (creados, actualizados, errores) = importarCSV(archivo=archivo, aplicacion="general",
                                                               modelo="Cliente", cabecera=cabecera, delimitador=delimitador, encoding=encoding, pk=pk, campos=campos)
        except IntegrityError as error:
            # Se ha hecho rollback de la transacción completa
            raise error
    else:
        (creados, actualizados, errores) = importarCSV(archivo=archivo, aplicacion="general",
                                                       modelo="Cliente", cabecera=cabecera, delimitador=delimitador, encoding=encoding, pk=pk, campos=campos)
    return (creados, actualizados, errores)


def empleadoCSVImport(archivo, cabecera=True, delimitador=";", encoding="iso8859_15", atomic=True):
    creados = 0
    actualizados = 0
    errores = 0
    if atomic:
        try:
            with transaction.atomic():
                try:
                    with open(settings.PATH_EXCEL + "/" + archivo, mode='r', newline='', encoding=encoding) as csvfile:
                        import csv
                        filas = csv.reader(csvfile, delimiter=delimitador)
                        responsable = Group.objects.get(pk=2)
                        jefe_obra = Group.objects.get(pk=3)
                        for indice, fila in enumerate(filas):
                            if indice == 0 and cabecera:
                                pass
                            else:
                                try:
                                    # Buscar empleado
                                    # Si existe, actualizar usuario y empleado
                                    # Si no existe, crear usuario y empleado
                                    codigo = fila[0]
                                    nombre = fila[1].split(',')
                                    firstname = nombre[0]
                                    lastname = nombre[1]
                                    username = fila[2]
                                    email = fila[3]
                                    if fila[4] == "Responsable":
                                        perfil = [responsable, ]
                                    elif fila[4] == "Jefe de Obra":
                                        perfil = [jefe_obra, ]
                                    try:
                                        empleado = Empleado.objects.get(
                                            codigo=codigo)
                                        usuario = empleado.usuario
                                    except Empleado.DoesNotExist:
                                        parametros = {"username": username, "defaults": {
                                            "first_name": firstname, "last_name": lastname, "email": email}}
                                        usuario, created = User.objects.update_or_create(
                                            **parametros
                                        )
                                    parametros = {
                                        "usuario": usuario, "defaults": {"codigo": codigo}}
                                    empleado, created = Empleado.objects.update_or_create(
                                        **parametros)
                                    empleado.usuario.groups.set(perfil)
                                    if created:
                                        creados += 1
                                    else:
                                        actualizados += 1
                                except DataError as error:
                                    # Error de datos (demasiado largo, inválido...)
                                    print(error)
                                    errores += 1
                                except Exception as error:
                                    # Error no controlado
                                    raise error
                except UnicodeDecodeError as error:
                    # Error de codificación
                    raise error
        except IntegrityError as error:
            # Se ha hecho rollback de la transacción completa
            raise error
    else:
        try:
            with open(settings.PATH_EXCEL + "/" + archivo, mode='r', newline='', encoding=encoding) as csvfile:
                import csv
                filas = csv.reader(csvfile, delimiter=delimitador)
                responsable = Group.objects.get(pk=2)
                jefe_obra = Group.objects.get(pk=3)
                for indice, fila in enumerate(filas):
                    if indice == 0 and cabecera:
                        pass
                    else:
                        try:
                            # Buscar empleado
                            # Si existe, actualizar usuario y empleado
                            # Si no existe, crear usuario y empleado
                            codigo = fila[0]
                            nombre = fila[1].split(',')
                            firstname = nombre[0]
                            lastname = nombre[1]
                            username = fila[2]
                            email = fila[3]
                            if fila[4] == "Responsable":
                                perfil = [responsable, ]
                            elif fila[4] == "Jefe de Obra":
                                perfil = [jefe_obra, ]
                            try:
                                empleado = Empleado.objects.get(codigo=codigo)
                                usuario = empleado.usuario
                            except Empleado.DoesNotExist:
                                parametros = {"username": username, "defaults": {
                                    "first_name": firstname, "last_name": lastname, "email": email}}
                                usuario, created = User.objects.update_or_create(
                                    **parametros
                                )
                            parametros = {
                                "usuario": usuario, "defaults": {"codigo": codigo}}
                            empleado, created = Empleado.objects.update_or_create(
                                **parametros)
                            empleado.usuario.groups.set(perfil)
                            if created:
                                creados += 1
                            else:
                                actualizados += 1
                        except DataError as error:
                            # Error de datos (demasiado largo, inválido...)
                            print(error)
                            errores += 1
                        except Exception as error:
                            # Error no controlado
                            raise error
        except UnicodeDecodeError as error:
            # Error de codificación
            raise error
    return (creados, actualizados, errores)


def obraCSVImport(archivo, cabecera=True, delimitador=";", encoding="iso8859_15", atomic=True):
    creados = 0
    actualizados = 0
    errores = 0
    try:
        with open(settings.PATH_EXCEL + "/" + archivo, mode='r', newline='', encoding=encoding) as csvfile:
            import csv
            filas = csv.reader(csvfile, delimiter=delimitador)
            for indice, fila in enumerate(filas):
                if indice == 0 and cabecera:
                    pass
                else:
                    # Recoger los datos del CSV
                    codigo = fila[0]
                    descripcion = fila[3]
                    # area = fila[16]
                    # depart = fila[17]
                    gastos_dele = fila[20]
                    gastos = fila[21]
                    obsoleta = fila[22] == 'VERDADERO'
                    bi = fila[23] == 'SI'
                    orden = fila[24]
                    estudio = fila[24]
                    tipo = fila[25] == 'OB'
                    activo = fila[26] == 'VERDADERO'
                    # Buscar y precargar:
                    #   - Empresa
                    #   - Cliente
                    #   - Zona
                    #   - Grupo
                    #   - Actividad
                    #   - Situación
                    #   - Ambito
                    #   - Clasificación_GTO
                    #   - Responsables
                    #   - Divisa
                    #   - Delegación / Subdelegación **
                    try:
                        empresa = Empresa.objects.get(codigo=fila[1])
                        cliente = Cliente.objects.get(codigo=fila[2])
                        zona = Zona.objects.get(nombre=fila[4])
                        grupo = Grupo.objects.get(nombre=fila[5])
                        actividad = Actividad.objects.get(nombre=fila[6])
                        situacion = Situacion.objects.get(nombre=fila[9])
                        ambito = Ambito.objects.get(nombre=fila[18])
                        clasif = Clasificacion_gto.objects.get(nombre=fila[19])
                        respo1 = Empleado.objects.get(codigo=fila[13])
                        respo2 = Empleado.objects.get(codigo=fila[14])
                        respo3 = Empleado.objects.get(codigo=fila[15])
                        # divisa = Divisa.objects.get(codigo=fila[2])
                        delegacion = Cliente.objects.get(descripcion=fila[7])
                        subdelegacion = Cliente.objects.get(
                            descripcion=fila[8])
                    except Cliente.DoesNotExist as error:
                        raise error
                    except Zona.DoesNotExist as error:
                        raise error
                    except Grupo.DoesNotExist as error:
                        raise error
                    except Actividad.DoesNotExist as error:
                        raise error
                    except Situacion.DoesNotExist as error:
                        raise error
                    except Ambito.DoesNotExist as error:
                        raise error
                    except Clasificacion_gto.DoesNotExist as error:
                        raise error
                    except Divisa.DoesNotExist as error:
                        raise error
                    except Empleado.DoesNotExist as error:
                        raise error
                    # Actualizar o crear obra
                    parametros = {"codigo": codigo, "defaults": {"descripcion": descripcion, "empresa": empresa, "cliente": cliente, "zona": zona, "grupo": grupo, "actividad": actividad,
                                                                 "situacion": situacion, "ambito": ambito, "clasificacion": clasif, "obsoleta": obsoleta, "bi": bi, "codigo_estudio": estudio, "tipo": tipo, "activo": activo}}

    except UnicodeDecodeError as error:
            # Error de codificación
        raise error
    return (creados, actualizados, errores)
