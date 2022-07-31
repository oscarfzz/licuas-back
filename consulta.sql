SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) - COALESCE(hh.importe_coste_directo_anterior, 0.00)) - COALESCE(hh.importe_coste_delegacion_anterior, 0.00) - COALESCE(hh.importe_coste_central_anterior, 0.00))) -
    (CASE WHEN
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp2.importe_coste_mes_1, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_mes_2, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp2.importe_coste_mes_2, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_mes_3, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp2.importe_coste_mes_3, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_mes_4, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp2.importe_coste_mes_4, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) - (CASE WHEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_resto, 0.00) + COALESCE(hp2.importe_ampliaciones_resto, 0.00)) - COALESCE(hp2.importe_coste_resto, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_resto, 0.00) + COALESCE(hp2.importe_contrato_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_resto, 0.00) + COALESCE(hp2.importe_contrato_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'Resultado'::text AS concepto,
    ((((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
     - (CASE WHEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
     + (((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp2.importe_coste_mes_1, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
     - (CASE WHEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
     + (((((COALESCE(hp2.importe_contrato_mes_2, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp2.importe_coste_mes_2, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
     - (CASE WHEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
     + (((((COALESCE(hp2.importe_contrato_mes_3, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp2.importe_coste_mes_3, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
     + (((((COALESCE(hp2.importe_contrato_mes_4, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp2.importe_coste_mes_4, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
     - (CASE WHEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) - COALESCE(hp2.importe_coste_proximo, 0.00)) - (((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) - COALESCE(hp2.importe_coste_siguiente, 0.00)) - (((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) - (CASE WHEN
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) - COALESCE(hp2.importe_coste_pendiente, 0.00)) - (((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) -
    (CASE WHEN
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    + (((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp2.importe_coste_mes_1, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    + (((((COALESCE(hp2.importe_contrato_mes_2, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp2.importe_coste_mes_2, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    + (((((COALESCE(hp2.importe_contrato_mes_3, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp2.importe_coste_mes_3, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    + (((((COALESCE(hp2.importe_contrato_mes_4, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp2.importe_coste_mes_4, 0.00)) - (((COALESCE(hp2.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END)))
     + (((((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) - COALESCE(hp2.importe_coste_proximo, 0.00)) - (((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    + (((((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) - COALESCE(hp2.importe_coste_siguiente, 0.00)) - (((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    + (((((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) - COALESCE(hp2.importe_coste_pendiente, 0.00)) - (((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))
    - (CASE WHEN
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'Resultado'::text AS concepto,
    (((((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) + COALESCE(hp2.importe_contrato_resto, 0.00)) + COALESCE(hp2.importe_contrato_proximo, 0.00)) + COALESCE(hp2.importe_contrato_siguiente, 0.00)) + COALESCE(hp2.importe_contrato_pendiente, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp2.importe_ampliaciones_resto, 0.00)) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00))) - (((((((((COALESCE(hh.importe_coste_directo_anterior, 0.00) + COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + COALESCE(hp2.importe_coste_mes_1, 0.00)) + COALESCE(hp2.importe_coste_mes_2, 0.00)) + COALESCE(hp2.importe_coste_mes_3, 0.00)) + COALESCE(hp2.importe_coste_mes_4, 0.00)) + COALESCE(hp2.importe_coste_resto, 0.00)) + COALESCE(hp2.importe_coste_proximo, 0.00)) + COALESCE(hp2.importe_coste_siguiente, 0.00)) + COALESCE(hp2.importe_coste_pendiente, 0.00))) - ((COALESCE(hh.importe_coste_delegacion_anterior, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + ((((((((((((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp2.importe_contrato_resto, 0.00)) + COALESCE(hp2.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric))) - ((COALESCE(hh.importe_coste_central_anterior, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + ((((((((((((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp2.importe_contrato_resto, 0.00)) + COALESCE(hp2.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((COALESCE(hp2.importe_contrato_proximo, 0.00) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp2.importe_contrato_siguiente, 0.00) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp2.importe_contrato_pendiente, 0.00) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))))) -
    (CASE WHEN
    (((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00)) > 0 THEN
    ((((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))) * (COALESCE(hh.cf_deudor, 0.00) / 100) END))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'Resultado'::text AS concepto,
     0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    (((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - (((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) > 0 THEN
    ((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - (((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00))) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - (((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00))) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) > 0 THEN
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00)) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    ((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - ((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_resto, 0.00)) > 0 THEN
    (((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - ((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_resto, 0.00))) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    (((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - ((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_resto, 0.00))) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    CASE WHEN
    (((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00)) > 0 THEN
    ((((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))) * (COALESCE(hh.cf_acreedor, 0.00) / 100) ELSE
    ((((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))) * (COALESCE(hh.cf_deudor, 0.00) / 100) END AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'GastosFinancierosInternos'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_anterior, 0.00)) - COALESCE(hp.importe_anterior, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_presente, 0.00)) - COALESCE(hp.importe_presente, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_mes_1, 0.00)) - COALESCE(hp.importe_mes_1, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_mes_2, 0.00)) - COALESCE(hp.importe_mes_2, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_mes_3, 0.00)) - COALESCE(hp.importe_mes_3, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_mes_4, 0.00)) - COALESCE(hp.importe_mes_4, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_resto, 0.00)) - COALESCE(hp.importe_resto, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    (((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - (((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) - (((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00))) + (((COALESCE(hc.importe_proximo, 0.00)) - COALESCE(hp.importe_proximo, 0.00))) + (((COALESCE(hc.importe_siguiente, 0.00)) - COALESCE(hp.importe_siguiente, 0.00))) + (((COALESCE(hc.importe_pendiente, 0.00)) - COALESCE(hp.importe_pendiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    (((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))  AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'CapitalFinanciero'::text AS concepto,
    ((((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp2.importe_contrato_mes_1, 0.00) + COALESCE(hp2.importe_contrato_mes_2, 0.00)) + COALESCE(hp2.importe_contrato_mes_3, 0.00)) + COALESCE(hp2.importe_contrato_mes_4, 0.00)) + COALESCE(hp2.importe_contrato_resto, 0.00)) + COALESCE(hp2.importe_contrato_proximo, 0.00)) + COALESCE(hp2.importe_contrato_siguiente, 0.00)) + COALESCE(hp2.importe_contrato_pendiente, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp2.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp2.importe_ampliaciones_resto, 0.00)) + COALESCE(hp2.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp2.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp2.importe_ampliaciones_pendiente, 0.00))) - (((((((((COALESCE(hh.importe_coste_directo_anterior, 0.00) + COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + COALESCE(hp2.importe_coste_mes_1, 0.00)) + COALESCE(hp2.importe_coste_mes_2, 0.00)) + COALESCE(hp2.importe_coste_mes_3, 0.00)) + COALESCE(hp2.importe_coste_mes_4, 0.00)) + COALESCE(hp2.importe_coste_resto, 0.00)) + COALESCE(hp2.importe_coste_proximo, 0.00)) + COALESCE(hp2.importe_coste_siguiente, 0.00)) + COALESCE(hp2.importe_coste_pendiente, 0.00)))) - ((((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) - (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))))AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
   LEFT JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id)))
   	 JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) - COALESCE(hh.importe_coste_directo_anterior, 0.00)) - COALESCE(hh.importe_coste_delegacion_anterior, 0.00) - COALESCE(hh.importe_coste_central_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp.importe_coste_mes_1, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp.importe_coste_mes_2, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp.importe_coste_mes_3, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp.importe_coste_mes_4, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_resto, 0.00) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) - COALESCE(hp.importe_coste_resto, 0.00)) - (((COALESCE(hp.importe_ampliaciones_resto, 0.00) + COALESCE(hp.importe_contrato_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_resto, 0.00) + COALESCE(hp.importe_contrato_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'MargenNeto'::text AS concepto,
    ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp.importe_coste_mes_1, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp.importe_coste_mes_2, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp.importe_coste_mes_3, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp.importe_coste_mes_4, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) - COALESCE(hp.importe_coste_proximo, 0.00)) - (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) - COALESCE(hp.importe_coste_siguiente, 0.00)) - (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) - COALESCE(hp.importe_coste_pendiente, 0.00)) - (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp.importe_coste_mes_1, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp.importe_coste_mes_2, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp.importe_coste_mes_3, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp.importe_coste_mes_4, 0.00)) - (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) - COALESCE(hp.importe_coste_proximo, 0.00)) - (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) - COALESCE(hp.importe_coste_siguiente, 0.00)) - (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) - COALESCE(hp.importe_coste_pendiente, 0.00)) - (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) - (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'MargenNeto'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00))) - (((((((((COALESCE(hh.importe_coste_directo_anterior, 0.00) + COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + COALESCE(hp.importe_coste_mes_1, 0.00)) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00)) + COALESCE(hp.importe_coste_proximo, 0.00)) + COALESCE(hp.importe_coste_siguiente, 0.00)) + COALESCE(hp.importe_coste_pendiente, 0.00))) - ((COALESCE(hh.importe_coste_delegacion_anterior, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric))) - ((COALESCE(hh.importe_coste_central_anterior, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'MargenNeto'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) - COALESCE(hh.importe_coste_directo_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp.importe_coste_mes_1, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp.importe_coste_mes_2, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp.importe_coste_mes_3, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp.importe_coste_mes_4, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_resto, 0.00) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) - COALESCE(hp.importe_coste_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'MargenBruto'::text AS concepto,
    (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + ((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp.importe_coste_mes_1, 0.00)) + ((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp.importe_coste_mes_2, 0.00)) + ((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp.importe_coste_mes_3, 0.00)) + ((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp.importe_coste_mes_4, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) - COALESCE(hp.importe_coste_proximo, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) - COALESCE(hp.importe_coste_siguiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) - COALESCE(hp.importe_coste_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) - COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + ((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) - COALESCE(hp.importe_coste_mes_1, 0.00)) + ((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) - COALESCE(hp.importe_coste_mes_2, 0.00)) + ((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) - COALESCE(hp.importe_coste_mes_3, 0.00)) + ((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) - COALESCE(hp.importe_coste_mes_4, 0.00))) + ((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) - COALESCE(hp.importe_coste_proximo, 0.00)) + ((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) - COALESCE(hp.importe_coste_siguiente, 0.00)) + ((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) - COALESCE(hp.importe_coste_pendiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'MargenBruto'::text AS concepto,
    ((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00))) - (((((((((COALESCE(hh.importe_coste_directo_anterior, 0.00) + COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + COALESCE(hp.importe_coste_mes_1, 0.00)) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00)) + COALESCE(hp.importe_coste_proximo, 0.00)) + COALESCE(hp.importe_coste_siguiente, 0.00)) + COALESCE(hp.importe_coste_pendiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'MargenBruto'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_presente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_mes_1, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_mes_2, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_mes_3, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_mes_4, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_resto, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'Pagos'::text AS concepto,
    (((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_proximo, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_siguiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'Pagos'::text AS concepto,
    COALESCE(hp.importe_pendiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'Pagos'::text AS concepto,
    ((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)))+(COALESCE(hp.importe_proximo, 0.00))+(COALESCE(hp.importe_siguiente, 0.00))+(COALESCE(hp.importe_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'Pagos'::text AS concepto,
    (((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'Pagos'::text AS concepto,
    ((((((((((COALESCE(hh.importe_coste_directo_anterior, 0.00) + COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + COALESCE(hp2.importe_coste_mes_1, 0.00)) + COALESCE(hp2.importe_coste_mes_2, 0.00)) + COALESCE(hp2.importe_coste_mes_3, 0.00)) + COALESCE(hp2.importe_coste_mes_4, 0.00)) + COALESCE(hp2.importe_coste_resto, 0.00)) + COALESCE(hp2.importe_coste_proximo, 0.00)) + COALESCE(hp2.importe_coste_siguiente, 0.00)) + COALESCE(hp2.importe_coste_pendiente, 0.00))) - ((((((((((COALESCE(hp.importe_presente, 0.00) + COALESCE(hp.importe_mes_1, 0.00)) + COALESCE(hp.importe_mes_2, 0.00)) + COALESCE(hp.importe_mes_3, 0.00)) + COALESCE(hp.importe_mes_4, 0.00)) + COALESCE(hp.importe_resto, 0.00)) + COALESCE(hp.importe_proximo, 0.00)) + COALESCE(hp.importe_siguiente, 0.00)) + COALESCE(hp.importe_pendiente, 0.00)) + COALESCE(hp.importe_anterior, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
       LEFT JOIN hdr_hojaderutaproduccion hp2 ON ((hh.id = hp2.hoja_id)))
     JOIN hdr_hojaderutapago hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hh.importe_contrato_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hh.importe_contrato_consolidado, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_mes_1, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_mes_2, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_mes_3, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_mes_4, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_resto, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_proximo, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_siguiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    COALESCE(hp.importe_contrato_pendiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    (((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    (((((((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hh.importe_contrato_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'ProduccionCI'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hh.importe_ampliacion_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hh.importe_ampliacion_consolidado, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_mes_1, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_mes_2, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_mes_3, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_mes_4, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_resto, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    (((((COALESCE(hh.importe_ampliacion_consolidado, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_proximo, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_siguiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    COALESCE(hp.importe_ampliaciones_pendiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    (((((((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    (((((((((COALESCE(hh.importe_ampliacion_consolidado, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'ProduccionAmpl'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_resto, 0.00) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (((((((((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) + COALESCE(hp.importe_contrato_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'ProdTotal'::text AS concepto,
    (((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'ProdTotal'::text AS concepto,
    ((((((((((((((((((((COALESCE(hh.importe_contrato_anterior) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + COALESCE(hh.importe_contrato_consolidado, 0.00)) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) + COALESCE(hp.importe_contrato_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) + COALESCE(( SELECT sum(ho.venta) AS sum
           FROM hdr_objetivo ho
          WHERE (ho.hoja_id = hh.id)), 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'CtesCentral'::text AS concepto,
    COALESCE(hh.importe_coste_central_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_resto, 0.00) + COALESCE(hp.importe_contrato_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'CtesCentral'::text AS concepto,
    ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'CtesCentral'::text AS concepto,
    (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'CtesCentral'::text AS concepto,
    ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'CtesCentral'::text AS concepto,
    ((COALESCE(hh.importe_coste_central_anterior, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'CtesCentral'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'CosteTotal'::text AS concepto,
    ((COALESCE(hh.importe_coste_central_anterior, 0.00) + COALESCE(hh.importe_coste_delegacion_anterior, 0.00)) + COALESCE(hh.importe_coste_directo_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'CosteTotal'::text AS concepto,
    ((COALESCE(hh.importe_coste_directo_consolidado, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_mes_1, 0.00) + (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_mes_2, 0.00) + (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_mes_3, 0.00) + (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_mes_4, 0.00) + (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_resto, 0.00) + (((COALESCE(hp.importe_contrato_resto, 0.00) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'CosteTotal'::text AS concepto,
    ((((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric))) + (((((COALESCE(hh.importe_coste_directo_consolidado, 0.00) + COALESCE(hp.importe_coste_mes_1, 0.00)) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_proximo, 0.00) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_siguiente, 0.00) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (COALESCE(hp.importe_coste_pendiente, 0.00) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'CosteTotal'::text AS concepto,
    (((((((((COALESCE(hp.importe_coste_mes_1, 0.00) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00)) + COALESCE(hp.importe_coste_proximo, 0.00)) + COALESCE(hp.importe_coste_siguiente, 0.00)) + COALESCE(hp.importe_coste_pendiente, 0.00)) + ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric))) + ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'CosteTotal'::text AS concepto,
    ((((((((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric) + (((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_central, 0.00)) / (100)::numeric)) + ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric))) + (((((COALESCE(hh.importe_coste_directo_consolidado, 0.00) + COALESCE(hp.importe_coste_mes_1, 0.00)) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00))) + (COALESCE(hp.importe_coste_proximo, 0.00) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric))) + (COALESCE(hp.importe_coste_siguiente, 0.00) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric))) + (COALESCE(hp.importe_coste_pendiente, 0.00) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * (COALESCE(hh.gasto_delegacion, 0.00) + COALESCE(hh.gasto_central, 0.00))) / (100)::numeric))) + ((COALESCE(hh.importe_coste_central_anterior, 0.00) + COALESCE(hh.importe_coste_delegacion_anterior, 0.00)) + COALESCE(hh.importe_coste_directo_anterior, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'CosteTotal'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hh.importe_coste_directo_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hh.importe_coste_directo_consolidado, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_mes_1, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_mes_2, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_mes_3, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_mes_4, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_resto, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    (((((COALESCE(hh.importe_coste_directo_consolidado, 0.00) + COALESCE(hp.importe_coste_mes_1, 0.00)) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_proximo, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_siguiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    COALESCE(hp.importe_coste_pendiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    (((((((COALESCE(hp.importe_coste_mes_1, 0.00) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00)) + COALESCE(hp.importe_coste_proximo, 0.00)) + COALESCE(hp.importe_coste_siguiente, 0.00)) + COALESCE(hp.importe_coste_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    (((((((((COALESCE(hh.importe_coste_directo_anterior, 0.00) + COALESCE(hh.importe_coste_directo_consolidado, 0.00)) + COALESCE(hp.importe_coste_mes_1, 0.00)) + COALESCE(hp.importe_coste_mes_2, 0.00)) + COALESCE(hp.importe_coste_mes_3, 0.00)) + COALESCE(hp.importe_coste_mes_4, 0.00)) + COALESCE(hp.importe_coste_resto, 0.00)) + COALESCE(hp.importe_coste_proximo, 0.00)) + COALESCE(hp.importe_coste_siguiente, 0.00)) + COALESCE(hp.importe_coste_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'CosteDirecto'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_presente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_mes_1, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_mes_2, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_mes_3, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_mes_4, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_resto, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'Certificacion'::text AS concepto,
    (((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_proximo, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_siguiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'Certificacion'::text AS concepto,
    COALESCE(hc.importe_pendiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'Certificacion'::text AS concepto,
    ((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00))) + (COALESCE(hc.importe_proximo, 0.00))+ (COALESCE(hc.importe_siguiente, 0.00))+(COALESCE(hc.importe_pendiente, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'Certificacion'::text AS concepto,
    ((COALESCE(hc.importe_anterior, 0.00) + COALESCE(hc.importe_presente, 0.00)) + (((((((COALESCE(hc.importe_mes_1, 0.00) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'Certificacion'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_presente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_mes_1, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_mes_2, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_mes_3, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_mes_4, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_resto, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'Cobros'::text AS concepto,
    (((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_proximo, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_siguiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'Cobros'::text AS concepto,
    COALESCE(hc.importe_pendiente, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'Cobros'::text AS concepto,
    ((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_resto, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'Cobros'::text AS concepto,
    (((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'Cobros'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)))) - ((((((((((COALESCE(hc.importe_presente, 0.00) + COALESCE(hc.importe_mes_1, 0.00)) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)) + COALESCE(hc.importe_anterior, 0.00))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN hdr_hojaderutacobro hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    COALESCE(hh.importe_coste_delegacion_anterior, 0.00) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (hdr_hojaderuta hh
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_1, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_2, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_3, 0.00) + COALESCE(hp.importe_contrato_mes_3, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_mes_4, 0.00) + COALESCE(hp.importe_contrato_mes_4, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_ampliaciones_resto, 0.00) + COALESCE(hp.importe_contrato_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    ((COALESCE(hh.importe_coste_delegacion_anterior, 0.00) + (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + ((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric)) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)) * COALESCE(hh.gasto_delegacion, 0.00)) / (100)::numeric))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'CtesDeleg'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00))) - (COALESCE(hc.importe_anterior, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) - (COALESCE(hc.importe_presente, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00))) - (COALESCE(hc.importe_mes_1, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00))) - (COALESCE(hc.importe_mes_2, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00))) - (COALESCE(hc.importe_mes_3, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00))) - (COALESCE(hc.importe_mes_4, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_resto, 0.00) + COALESCE(hp.importe_ampliaciones_resto, 0.00))) - (COALESCE(hc.importe_resto, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    ((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) - (COALESCE(hc.importe_presente, 0.00))) + (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00))) - (COALESCE(hc.importe_mes_1, 0.00))) + (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00))) - (COALESCE(hc.importe_mes_2, 0.00))) + (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00))) - (COALESCE(hc.importe_mes_3, 0.00))) + (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00))) - (COALESCE(hc.importe_mes_4, 0.00))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00))) - (COALESCE(hc.importe_proximo, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00))) - (COALESCE(hc.importe_siguiente, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00))) - (COALESCE(hc.importe_pendiente, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) - (COALESCE(hc.importe_presente, 0.00))) + (((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00))) - (COALESCE(hc.importe_mes_1, 0.00))) + (((COALESCE(hp.importe_contrato_mes_2, 0.00) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00))) - (COALESCE(hc.importe_mes_2, 0.00))) + (((COALESCE(hp.importe_contrato_mes_3, 0.00) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00))) - (COALESCE(hc.importe_mes_3, 0.00))) + (((COALESCE(hp.importe_contrato_mes_4, 0.00) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00))) - (COALESCE(hc.importe_mes_4, 0.00)))) + (((COALESCE(hp.importe_contrato_proximo, 0.00) + COALESCE(hp.importe_ampliaciones_proximo, 0.00))) - (COALESCE(hc.importe_proximo, 0.00))) + (((COALESCE(hp.importe_contrato_siguiente, 0.00) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00))) - (COALESCE(hc.importe_siguiente, 0.00))) + (((COALESCE(hp.importe_contrato_pendiente, 0.00) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00))) - (COALESCE(hc.importe_pendiente, 0.00))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    (((((COALESCE(hh.importe_contrato_anterior, 0.00) + COALESCE(hh.importe_ampliacion_anterior, 0.00)) + (COALESCE(hh.importe_contrato_consolidado, 0.00) + COALESCE(hh.importe_ampliacion_consolidado, 0.00))) + (((((((((((((((COALESCE(hp.importe_contrato_mes_1, 0.00) + COALESCE(hp.importe_contrato_mes_2, 0.00)) + COALESCE(hp.importe_contrato_mes_3, 0.00)) + COALESCE(hp.importe_contrato_mes_4, 0.00)) + COALESCE(hp.importe_contrato_resto, 0.00)) + COALESCE(hp.importe_contrato_proximo, 0.00)) + COALESCE(hp.importe_contrato_siguiente, 0.00)) + COALESCE(hp.importe_contrato_pendiente, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_1, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_2, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_3, 0.00)) + COALESCE(hp.importe_ampliaciones_mes_4, 0.00)) + COALESCE(hp.importe_ampliaciones_resto, 0.00)) + COALESCE(hp.importe_ampliaciones_proximo, 0.00)) + COALESCE(hp.importe_ampliaciones_siguiente, 0.00)) + COALESCE(hp.importe_ampliaciones_pendiente, 0.00)))) - (((COALESCE(hc.importe_anterior, 0.00) + COALESCE(hc.importe_presente, 0.00)) + (((((((COALESCE(hc.importe_mes_1, 0.00) + COALESCE(hc.importe_mes_2, 0.00)) + COALESCE(hc.importe_mes_3, 0.00)) + COALESCE(hc.importe_mes_4, 0.00)) + COALESCE(hc.importe_resto, 0.00)) + COALESCE(hc.importe_proximo, 0.00)) + COALESCE(hc.importe_siguiente, 0.00)) + COALESCE(hc.importe_pendiente, 0.00)))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'ProducCertificOrigen'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((hdr_hojaderuta hh
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id)))  
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Anterior'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_anterior, 0.00)) - (COALESCE(hcobro.importe_anterior, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Consolidado'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_presente, 0.00)) - (COALESCE(hcobro.importe_presente, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes1'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_mes_1, 0.00)) - (COALESCE(hcobro.importe_mes_1, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes2'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_mes_2, 0.00)) - (COALESCE(hcobro.importe_mes_2, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes3'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_mes_3, 0.00)) - (COALESCE(hcobro.importe_mes_3, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Mes4'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_mes_4, 0.00)) - (COALESCE(hcobro.importe_mes_4, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Pendiente'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_resto, 0.00)) - (COALESCE(hcobro.importe_resto, 0.00)))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'ejercicioActual'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    (((COALESCE(hc.importe_presente, 0.00)) - (COALESCE(hcobro.importe_presente, 0.00))) + ((COALESCE(hc.importe_mes_1, 0.00)) - (COALESCE(hcobro.importe_mes_1, 0.00))) + ((COALESCE(hc.importe_mes_2, 0.00)) - (COALESCE(hcobro.importe_mes_2, 0.00))) + ((COALESCE(hc.importe_mes_3, 0.00)) - (COALESCE(hcobro.importe_mes_3, 0.00))) + ((COALESCE(hc.importe_mes_4, 0.00)) - (COALESCE(hcobro.importe_mes_4, 0.00))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Proximo'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_proximo, 0.00)) - (COALESCE(hcobro.importe_proximo, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Siguiente'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_siguiente, 0.00)) - (COALESCE(hcobro.importe_siguiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Resto'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((COALESCE(hc.importe_pendiente, 0.00)) - (COALESCE(hcobro.importe_pendiente, 0.00))) AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM (((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'TotalPrevision'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((((COALESCE(hc.importe_presente, 0.00)) - (COALESCE(hcobro.importe_presente, 0.00))) + ((COALESCE(hc.importe_mes_1, 0.00)) - (COALESCE(hcobro.importe_mes_1, 0.00))) + ((COALESCE(hc.importe_mes_2, 0.00)) - (COALESCE(hcobro.importe_mes_2, 0.00))) + ((COALESCE(hc.importe_mes_3, 0.00)) - (COALESCE(hcobro.importe_mes_3, 0.00))) + ((COALESCE(hc.importe_mes_4, 0.00)) - (COALESCE(hcobro.importe_mes_4, 0.00)))) + ((COALESCE(hc.importe_proximo, 0.00)) - (COALESCE(hcobro.importe_proximo, 0.00))) + ((COALESCE(hc.importe_siguiente, 0.00)) - (COALESCE(hcobro.importe_siguiente, 0.00))) + ((COALESCE(hc.importe_pendiente, 0.00)) - (COALESCE(hcobro.importe_pendiente, 0.00))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'FinObra'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    ((((COALESCE(hc.importe_anterior, 0.00)) - (COALESCE(hcobro.importe_anterior, 0.00)))) + (((((COALESCE(hc.importe_presente, 0.00)) - (COALESCE(hcobro.importe_presente, 0.00))) + ((COALESCE(hc.importe_mes_1, 0.00)) - (COALESCE(hcobro.importe_mes_1, 0.00))) + ((COALESCE(hc.importe_mes_2, 0.00)) - (COALESCE(hcobro.importe_mes_2, 0.00))) + ((COALESCE(hc.importe_mes_3, 0.00)) - (COALESCE(hcobro.importe_mes_3, 0.00))) + ((COALESCE(hc.importe_mes_4, 0.00)) - (COALESCE(hcobro.importe_mes_4, 0.00)))) + ((COALESCE(hc.importe_proximo, 0.00)) - (COALESCE(hcobro.importe_proximo, 0.00))) + ((COALESCE(hc.importe_siguiente, 0.00)) - (COALESCE(hcobro.importe_siguiente, 0.00))) + ((COALESCE(hc.importe_pendiente, 0.00)) - (COALESCE(hcobro.importe_pendiente, 0.00))))))
    AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
UNION
 SELECT go2.empresa_id AS empresa,
    go2.id AS id_obra,
    go2.codigo AS obra,
    hh.year AS ejercicio,
    hh.cuarto,
    'Objetivos'::text AS periodo,
    'CertificCobroOrigen'::text AS concepto,
    0 AS importe,
    go2.participacion_licuas,
    COALESCE(( SELECT gc.importe
           FROM general_cambiodivisa gc
          WHERE ((go2.divisa_id = gc.divisa_id) AND (gc.year = hh.year) AND (gc.cuarto = hh.cuarto))), 0.00) AS conversion_euros
   FROM ((((hdr_hojaderuta hh
     JOIN hdr_hojaderutacobro hcobro ON ((hh.id = hcobro.hoja_id)))
     LEFT JOIN hdr_hojaderutaproduccion hp ON ((hh.id = hp.hoja_id)))
     LEFT JOIN hdr_hojaderutacertificacion hc ON ((hh.id = hc.hoja_id)))
     JOIN general_obra go2 ON ((hh.obra_id = go2.id))) 
  ORDER BY 1, 3, 6, 7, 4, 5;