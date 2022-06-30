from hdr.models import HojaDeRuta, HojaDeRutaCertificacion, HojaDeRutaCobro
from django.conf import settings
from general.models import Obra, Empresa
from django.db.models import Sum, Value, F
# Magnitudes
delegacion_texto = "GG. DELEGACION"
central_texto = "GG. CENTRAL"
contrato_inicial_texto = "PRODUCCION CONTRATO INICIAL"
certificacion_texto = "CERTIFICACION"
cobro_texto = "COBRO"
coste_directo_texto = "COSTE DIRECTO"
ampliaciones_texto = "PRODUCCION DE AMPLIACIONES"
# Conceptos
anterior_texto = "AnosAnteriores".upper()
presente_texto = "ConsolidadoAnoActual".upper()


def calcularPrecioConFiltros(sql, queryDivisa, queryLicuas, activarDivisa, activarLicuas):
    if activarDivisa:
        sql = sql / queryDivisa
        return queryLicuas * (sql) if activarLicuas else sql
    else:
        return queryLicuas * (sql) if activarLicuas else sql

def hdrCSVImport(archivo, year, cuarto, usuario, cabecera=True, delimitador=";", encoding="iso8859_15", atomic=True, limpiar=False):
    if not year or not cuarto:
        raise ValueError("No se ha recibido el año o el cuarto")
    if limpiar:
        try:
            HojaDeRuta.objects.filter(year=year).filter(cuarto=cuarto).delete()
        except Exception as error:
            print(error)
    creados = 0
    actualizados = 0
    errores = []
    try:
        with open(settings.PATH_EXCEL + "/" + archivo, mode='r', newline='', encoding=encoding) as csvfile:
            import csv
            from decimal import Decimal, InvalidOperation
            filas = csv.reader(csvfile, delimiter=delimitador)
            for indice, fila in enumerate(filas):
                certificacion = False
                cobro = False
                if indice == 0 and cabecera:
                    pass
                else:
                    # Recoger los datos del CSV
                    concepto = fila[2].upper()
                    try:
                        importe = Decimal(fila[3].strip().replace(
                            ".", "").replace(",", "."))
                    except InvalidOperation as error:
                        if fila[3].strip() != "" and fila[3].strip() != "-":
                            errores.append(
                                {"tipo": "Importe no convertible a decimal", "valor": fila[3].strip(), "fila": indice})
                        continue
                    magnitud = fila[4].upper()
                    # Buscar y precargar:
                    #   - Empresa
                    #   - Obra
                    try:
                        empresa = Empresa.objects.get(codigo=fila[0])
                        obra = Obra.objects.get(
                            codigo=fila[1], empresa=empresa)
                    except Empresa.DoesNotExist as error:
                        errores.append(
                            {"tipo": "Empresa inexistente", "valor": fila[0], "fila": indice})
                        continue
                    except Obra.DoesNotExist as error:
                        errores.append(
                            {"tipo": "Obra inexistente", "valor": fila[1] + "|" + empresa.codigo, "fila": indice})
                        continue
                    # Decidimos el campo en función de magnitud y concepto para asignarle el importe
                    if magnitud == delegacion_texto:
                        if concepto == anterior_texto:
                            campo = "importe_coste_delegacion_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_coste_delegacion_consolidado"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    elif magnitud == central_texto:
                        if concepto == anterior_texto:
                            campo = "importe_coste_central_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_coste_central_consolidado"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    elif magnitud == contrato_inicial_texto:
                        if concepto == anterior_texto:
                            campo = "importe_contrato_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_contrato_consolidado"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    elif magnitud == certificacion_texto:
                        certificacion = True
                        if concepto == anterior_texto:
                            campo = "importe_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_presente"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    elif magnitud == cobro_texto:
                        cobro = True
                        if concepto == anterior_texto:
                            campo = "importe_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_presente"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    elif magnitud == coste_directo_texto:
                        if concepto == anterior_texto:
                            campo = "importe_coste_directo_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_coste_directo_consolidado"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    elif magnitud == ampliaciones_texto:
                        if concepto == anterior_texto:
                            campo = "importe_ampliacion_anterior"
                        elif concepto == presente_texto:
                            campo = "importe_ampliacion_consolidado"
                        else:
                            errores.append(
                                {"tipo": "Concepto inválido", "valor": concepto, "fila": indice}
                            )
                            continue
                    else:
                        errores.append(
                            {"tipo": "Magnitud inválido", "valor": magnitud, "fila": indice}
                        )
                        continue
                    if certificacion or cobro:
                        defaults = {"usuario_creacion": usuario,
                                    "usuario_modificacion": usuario}
                    else:
                        defaults = {
                            campo: importe, "usuario_creacion": usuario, "usuario_modificacion": usuario}
                    # Actualizar o crear hdr
                    parametros = {"obra": obra, "year": year,
                                  "cuarto": cuarto, "defaults": defaults}
                    hoja, created = HojaDeRuta.objects.update_or_create(
                        **parametros)
                    if created:
                        creados += 1
                    else:
                        actualizados += 1
                    # Actualizar o crear certificacion
                    if certificacion:
                        defaults = {campo: importe}
                        parametros = {"hoja": hoja, "defaults": defaults}
                        HojaDeRutaCertificacion.objects.update_or_create(
                            **parametros)
                    # Actualizar o crear cobro
                    if cobro:
                        defaults = {campo: importe}
                        parametros = {"hoja": hoja, "defaults": defaults}
                        HojaDeRutaCobro.objects.update_or_create(
                            **parametros)
    except UnicodeDecodeError as error:
            # Error de codificación
        raise error
    return (creados, actualizados, errores)
