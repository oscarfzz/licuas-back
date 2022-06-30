
-- ProduccionCI --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'ProduccionCI' as concepto,
	    Coalesce(importe_contrato_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'ProduccionCI' concepto,
       		Coalesce(importe_contrato_consolidado, 0.00)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'ProduccionCI' concepto,
       		Coalesce(hp.importe_contrato_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'ProduccionCI' concepto,
       		Coalesce(hp.importe_contrato_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'ProduccionCI' concepto,
       		Coalesce(hp.importe_contrato_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'ProduccionCI' concepto,
       		Coalesce(hp.importe_contrato_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'ProduccionCI' concepto,
       		Coalesce(hp.importe_contrato_resto, 0.00)
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' as periodo,
       'ProduccionCI' as concepto,
       
	    coalesce(importe_contrato_consolidado, 0.00) + 
	    coalesce(hp.importe_contrato_mes_1, 0.00) + 
	    coalesce(hp.importe_contrato_mes_2, 0.00) + 
	    coalesce(hp.importe_contrato_mes_3, 0.00) + 
	    coalesce(hp.importe_contrato_mes_4, 0.00) + 
	    coalesce(hp.importe_contrato_resto, 0.00)
	    
		as importe, -- presente
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union


Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'ProduccionCI' concepto,
       		Coalesce(hp.importe_contrato_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'ProduccionCI' concepto,
       		Coalesce(importe_contrato_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'ProduccionCI' concepto,
       		Coalesce(importe_contrato_pendiente, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'ProduccionCI' concepto,
       		coalesce(hp.importe_contrato_mes_1, 0.00) + 
		    coalesce(hp.importe_contrato_mes_2, 0.00) + 
		    coalesce(hp.importe_contrato_mes_3, 0.00) + 
		    coalesce(hp.importe_contrato_mes_4, 0.00) + 
			coalesce(hp.importe_contrato_resto, 0.00) + 
			
			coalesce(importe_contrato_proximo, 0.00) + 
			coalesce(importe_contrato_siguiente, 0.00) + 
			coalesce(importe_contrato_pendiente, 0.00)

			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'ProduccionCI' concepto,
       
       		coalesce(importe_contrato_consolidado, 0.00) + 
		    coalesce(hp.importe_contrato_mes_1, 0.00) + 
		    coalesce(hp.importe_contrato_mes_2, 0.00) + 
		    coalesce(hp.importe_contrato_mes_3, 0.00) + 
		    coalesce(hp.importe_contrato_mes_4, 0.00) + 
		    coalesce(hp.importe_contrato_resto, 0.00) +
		    
		    coalesce(importe_contrato_proximo, 0.00) + 
			coalesce(importe_contrato_siguiente, 0.00) + 
			coalesce(importe_contrato_pendiente, 0.00) + 
			
			Coalesce(importe_contrato_anterior, 0.00)
       
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'ProduccionCI' concepto,
       		
			coalesce(importe_contrato_consolidado, 0.00) + 
		    coalesce(hp.importe_contrato_mes_1, 0.00) + 
		    coalesce(hp.importe_contrato_mes_2, 0.00) + 
		    coalesce(hp.importe_contrato_mes_3, 0.00) + 
		    coalesce(hp.importe_contrato_mes_4, 0.00) + 
		    coalesce(hp.importe_contrato_resto, 0.00) +
		    
		    coalesce(importe_contrato_proximo, 0.00) + 
			coalesce(importe_contrato_siguiente, 0.00) + 
			coalesce(importe_contrato_pendiente, 0.00) + 
			
			Coalesce(importe_contrato_anterior, 0.00) +
       
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union

-- Resultado --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'Resultado' as concepto,
       
	    (Coalesce(importe_contrato_anterior, 0.00) + Coalesce(importe_ampliacion_anterior, 0.00)) - 
	    
	    (Coalesce((importe_coste_central_anterior), 0.00) +
        Coalesce((importe_coste_delegacion_anterior), 0.00) +
        Coalesce((importe_coste_directo_anterior), 0.00))
	    
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)
union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'Resultado' concepto,
       		
			0 -- (produccion['realizado'] - coste['realizado'] )
       
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'Resultado' concepto,
       		(
       			Coalesce(importe_contrato_mes_1, 0.00) + Coalesce(importe_ampliaciones_mes_1, 0.00)
			) - Coalesce(hc.importe_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'Resultado' concepto,
       		(
       			Coalesce(importe_contrato_mes_2, 0.00) + Coalesce(importe_ampliaciones_mes_2, 0.00)
			) - Coalesce(hc.importe_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'Resultado' concepto,
       		(
       			Coalesce(importe_contrato_mes_3, 0.00) + Coalesce(importe_ampliaciones_mes_3, 0.00)
			) - Coalesce(hc.importe_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'Resultado' concepto,
       		(
       			Coalesce(importe_contrato_mes_4, 0.00) + Coalesce(importe_ampliaciones_mes_4, 0.00)
			) - Coalesce(hc.importe_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'Resultado' concepto,
       		
			((
				(Coalesce((importe_contrato_pendiente), 0.00) +
                    Coalesce((importe_ampliaciones_pendiente), 0.00))
			)-(
				(Coalesce((importe_coste_pendiente), 0.00) + (Coalesce((importe_contrato_pendiente), 0.00) +
                Coalesce((importe_ampliaciones_pendiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
			))

			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' periodo,
       'Resultado' concepto,

            (Coalesce((importe_contrato_consolidado), 0.00)+
               Coalesce((importe_ampliacion_consolidado), 0.00)+
               Coalesce((importe_contrato_mes_1), 0.00)+
               Coalesce((importe_contrato_mes_2), 0.00)+
               Coalesce((importe_contrato_mes_3), 0.00)+
               Coalesce((importe_contrato_mes_4), 0.00)+
                   Coalesce((importe_contrato_resto), 0.00)+
                   Coalesce((importe_ampliaciones_mes_1), 0.00)+
                   Coalesce((importe_ampliaciones_mes_2), 0.00)
                   +Coalesce((importe_ampliaciones_mes_3), 0.00)+
                   Coalesce((importe_ampliaciones_mes_4), 0.00)
                   +Coalesce((importe_ampliaciones_resto), 0.00))-
            ((
                (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_central), 0.00)) / 100) +

                (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
                Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100
            )
            +
            (
                (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_delegacion), 0.00)) / 100) +

                (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
                Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
            )
            +
            (
                Coalesce((importe_coste_directo_consolidado), 0.00) +
                Coalesce((importe_coste_mes_1), 0.00) + Coalesce((importe_coste_mes_2), 0.00) +
                Coalesce((importe_coste_mes_3), 0.00) +
                Coalesce((importe_coste_mes_4), 0.00) +
                Coalesce((importe_coste_resto), 0.00)
            ))
       		
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'Resultado' concepto,
       		
			(Coalesce((importe_contrato_proximo), 0.00) +
            Coalesce((importe_ampliaciones_proximo), 0.00)-
            (Coalesce((importe_coste_proximo), 0.00) + (Coalesce((importe_contrato_proximo), 0.00) +
            Coalesce((importe_ampliaciones_proximo), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
            )
                    
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)
 
union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'Resultado' concepto,

       		(Coalesce((importe_contrato_siguiente), 0.00) + Coalesce((importe_ampliaciones_siguiente), 0.00))-
            (Coalesce((importe_coste_siguiente), 0.00) + (Coalesce((importe_contrato_siguiente), 0.00) +
            Coalesce((importe_ampliaciones_siguiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                                                
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'Resultado' concepto,

       		(Coalesce((importe_contrato_pendiente), 0.00) +
            Coalesce((importe_ampliaciones_pendiente), 0.00))
                    
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
--Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'Resultado' concepto,
       		
   			(Coalesce((importe_contrato_mes_1), 0.00)+
            Coalesce((importe_contrato_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00)+
            Coalesce((importe_contrato_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00)+
            Coalesce((importe_contrato_proximo), 0.00)+Coalesce((importe_contrato_siguiente), 0.00) +
            Coalesce((importe_contrato_pendiente), 0.00)+Coalesce((importe_ampliaciones_mes_1), 0.00)+
            Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_ampliaciones_mes_3), 0.00)+
            Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_ampliaciones_resto), 0.00)+
            Coalesce((importe_ampliaciones_proximo), 0.00)+
            Coalesce((importe_ampliaciones_siguiente), 0.00)+Coalesce((importe_ampliaciones_pendiente), 0.00)-
            ((
	            Coalesce((importe_coste_mes_1), 0.00) + Coalesce((importe_coste_mes_2), 0.00) +
		        Coalesce((importe_coste_mes_3), 0.00) +
		        Coalesce((importe_coste_mes_4), 0.00) +
		        Coalesce((importe_coste_resto), 0.00) + Coalesce((importe_coste_proximo), 0.00) +
		        Coalesce((importe_coste_siguiente), 0.00) +
		        Coalesce((importe_coste_pendiente), 0.00)
            ) + (
				(Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
                Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100 + (Coalesce((importe_contrato_proximo), 0.00) +
                Coalesce((importe_ampliaciones_proximo), 0.00))*Coalesce((gasto_delegacion), 0.00)/100+(Coalesce((importe_contrato_siguiente), 0.00) +
                Coalesce((importe_ampliaciones_siguiente), 0.00))*Coalesce((gasto_delegacion), 0.00)/100+(Coalesce((importe_contrato_pendiente), 0.00) +
                Coalesce((importe_ampliaciones_pendiente), 0.00))*Coalesce((gasto_delegacion), 0.00)/100
            )+(
            	(Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
                Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100 + (Coalesce((importe_contrato_proximo), 0.00) +
                Coalesce((importe_ampliaciones_proximo), 0.00))*Coalesce((gasto_central), 0.00)/100 + (Coalesce((importe_contrato_siguiente), 0.00) +
                Coalesce((importe_ampliaciones_siguiente), 0.00))*coalesce((gasto_central), 0.00)/100 + (Coalesce((importe_contrato_pendiente), 0.00) +
				Coalesce((importe_ampliaciones_pendiente), 0.00))*Coalesce((gasto_central), 0.00)/100
            ))
            )
       
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'Resultado' concepto,
       		(
				Coalesce(importe_contrato_anterior) + Coalesce(importe_ampliacion_anterior, 0.00) +
				Coalesce(importe_contrato_consolidado, 0.00) +
				Coalesce(importe_ampliacion_consolidado, 0.00) +
				Coalesce(importe_contrato_mes_1, 0.00) +
				Coalesce(importe_contrato_mes_2, 0.00) +
				Coalesce(importe_contrato_mes_3, 0.00) +
				Coalesce(importe_contrato_mes_4, 0.00) +
				Coalesce(importe_contrato_resto, 0.00) +
				Coalesce(importe_ampliaciones_mes_1, 0.00) +
				Coalesce(importe_ampliaciones_mes_2, 0.00) +
				Coalesce(importe_ampliaciones_mes_3, 0.00) +
				Coalesce(importe_ampliaciones_mes_4, 0.00) +
				Coalesce(importe_ampliaciones_resto, 0.00) +
				Coalesce(importe_contrato_proximo, 0.00) +
				Coalesce(importe_ampliaciones_proximo, 0.00) +
				Coalesce(importe_contrato_siguiente, 0.00) +
				Coalesce(importe_ampliaciones_siguiente, 0.00) +
				Coalesce(importe_contrato_pendiente, 0.00) +
				Coalesce(importe_ampliaciones_pendiente, 0.00)
       		) - (
				
   				((
       		((
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_central), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100
        )
        +
        (
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_delegacion), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
        )
        +
        (
            Coalesce((importe_coste_directo_consolidado), 0.00) +
            Coalesce((importe_coste_mes_1), 0.00) + Coalesce((importe_coste_mes_2), 0.00) +
            Coalesce((importe_coste_mes_3), 0.00) +
            Coalesce((importe_coste_mes_4), 0.00) +
            Coalesce((importe_coste_resto), 0.00)
        ))
       		) +
       		(
	       		(Coalesce((importe_coste_proximo), 0.00) + (Coalesce((importe_contrato_proximo), 0.00) +
	    		Coalesce((importe_ampliaciones_proximo), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
	        ) +
       		(
	       		(Coalesce((importe_coste_siguiente), 0.00) + (Coalesce((importe_contrato_siguiente), 0.00) +
	            Coalesce((importe_ampliaciones_siguiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
        	) +
			(
				(Coalesce((importe_coste_pendiente), 0.00) + (Coalesce((importe_contrato_pendiente), 0.00) +
		        Coalesce((importe_ampliaciones_pendiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)       
	        ) +
			(
				(coalesce((importe_coste_central_anterior), 0.00) +
		        Coalesce((importe_coste_delegacion_anterior), 0.00) +
		        Coalesce((importe_coste_directo_anterior), 0.00))
			))
	
       		)
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'Resultado' concepto,
       		
			(
				Coalesce(importe_contrato_anterior) + Coalesce(importe_ampliacion_anterior, 0.00) +
				Coalesce(importe_contrato_consolidado, 0.00) +
				Coalesce(importe_ampliacion_consolidado, 0.00) +
				Coalesce(importe_contrato_mes_1, 0.00) +
				Coalesce(importe_contrato_mes_2, 0.00) +
				Coalesce(importe_contrato_mes_3, 0.00) +
				Coalesce(importe_contrato_mes_4, 0.00) +
				Coalesce(importe_contrato_resto, 0.00) +
				Coalesce(importe_ampliaciones_mes_1, 0.00) +
				Coalesce(importe_ampliaciones_mes_2, 0.00) +
				Coalesce(importe_ampliaciones_mes_3, 0.00) +
				Coalesce(importe_ampliaciones_mes_4, 0.00) +
				Coalesce(importe_ampliaciones_resto, 0.00) +
				Coalesce(importe_contrato_proximo, 0.00) +
				Coalesce(importe_ampliaciones_proximo, 0.00) +
				Coalesce(importe_contrato_siguiente, 0.00) +
				Coalesce(importe_ampliaciones_siguiente, 0.00) +
				Coalesce(importe_contrato_pendiente, 0.00) +
				Coalesce(importe_ampliaciones_pendiente, 0.00)
       		) - (
				Coalesce(importe_presente, 0.00) +
				Coalesce(importe_proximo, 0.00) +
				Coalesce(importe_siguiente, 0.00) +
				Coalesce(importe_resto, 0.00) +
				Coalesce(importe_anterior, 0.00)
       		)
       		
       		+
       		
       		Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
       		
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

-- ProduccionAmpl --


Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'ProduccionAmpl' as concepto,
	    Coalesce(importe_ampliacion_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(importe_ampliacion_consolidado, 0.00)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(hp.importe_ampliaciones_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(hp.importe_ampliaciones_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(hp.importe_ampliaciones_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(hp.importe_ampliaciones_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(hp.importe_ampliaciones_resto, 0.00)
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' as periodo,
       'ProduccionAmpl' as concepto,
       
	    coalesce(importe_ampliacion_consolidado, 0.00) + 
	    coalesce(hp.importe_ampliaciones_mes_1, 0.00) + 
	    coalesce(hp.importe_ampliaciones_mes_2, 0.00) + 
	    coalesce(hp.importe_ampliaciones_mes_3, 0.00) + 
	    coalesce(hp.importe_ampliaciones_mes_4, 0.00) + 
	    coalesce(hp.importe_ampliaciones_resto, 0.00)
	    
		as importe, -- presente
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union


Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(hp.importe_ampliaciones_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(importe_ampliaciones_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'ProduccionAmpl' concepto,
       		Coalesce(importe_ampliaciones_pendiente, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'ProduccionAmpl' concepto,
       		coalesce(hp.importe_ampliaciones_mes_1, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_2, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_3, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_4, 0.00) + 
			coalesce(hp.importe_ampliaciones_resto, 0.00) + 
			
			coalesce(importe_ampliaciones_proximo, 0.00) + 
			coalesce(importe_ampliaciones_siguiente, 0.00) + 
			coalesce(importe_ampliaciones_pendiente, 0.00)

			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'ProduccionAmpl' concepto,
       
       		coalesce(importe_ampliacion_consolidado, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_1, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_2, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_3, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_4, 0.00) + 
		    coalesce(hp.importe_ampliaciones_resto, 0.00) +
		    
		    coalesce(importe_ampliaciones_proximo, 0.00) + 
			coalesce(importe_ampliaciones_siguiente, 0.00) + 
			coalesce(importe_ampliaciones_pendiente, 0.00) + 
			
			Coalesce(importe_ampliacion_anterior, 0.00)
       
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'ProduccionAmpl' concepto,
       		
			coalesce(importe_ampliacion_consolidado, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_1, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_2, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_3, 0.00) + 
		    coalesce(hp.importe_ampliaciones_mes_4, 0.00) + 
		    coalesce(hp.importe_ampliaciones_resto, 0.00) +
		    
		    coalesce(importe_ampliaciones_proximo, 0.00) + 
			coalesce(importe_ampliaciones_siguiente, 0.00) + 
			coalesce(importe_ampliaciones_pendiente, 0.00) + 
			
			Coalesce(importe_ampliacion_anterior, 0.00) +
       
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union


-- PRODUCCION - Producciñn ejecutada --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'ProdTotal' as concepto,
	    Coalesce(importe_contrato_anterior, 0.00) + Coalesce(importe_ampliacion_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_consolidado, 0.00) + Coalesce(importe_ampliacion_consolidado, 0.00)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union


Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_1, 0.00) + Coalesce(importe_ampliaciones_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_2, 0.00) + Coalesce(importe_ampliaciones_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_3, 0.00) + Coalesce(importe_ampliaciones_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_4, 0.00) + Coalesce(importe_ampliaciones_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_resto, 0.00) + Coalesce(importe_ampliaciones_resto, 0.00)
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Presente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_consolidado, 0.00) +
			Coalesce(importe_ampliacion_consolidado, 0.00) +
			Coalesce(importe_contrato_mes_1, 0.00) +
			Coalesce(importe_contrato_mes_2, 0.00) +
			Coalesce(importe_contrato_mes_3, 0.00) +
			Coalesce(importe_contrato_mes_4, 0.00) +
			Coalesce(importe_contrato_resto, 0.00) +
			Coalesce(importe_ampliaciones_mes_1, 0.00) +
			Coalesce(importe_ampliaciones_mes_2, 0.00) +
			Coalesce(importe_ampliaciones_mes_3, 0.00) +
			Coalesce(importe_ampliaciones_mes_4, 0.00) +
			Coalesce(importe_ampliaciones_resto, 0.00)
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_proximo, 0.00) + 
       		Coalesce(importe_ampliaciones_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_siguiente, 0.00) +
			coalesce(importe_ampliaciones_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_coste_pendiente, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_1, 0.00) +
			coalesce(importe_contrato_mes_2, 0.00) + 
			coalesce(importe_contrato_mes_3, 0.00) + 
			coalesce(importe_contrato_mes_4, 0.00) + 
			coalesce(importe_contrato_resto, 0.00) + 
			coalesce(importe_contrato_proximo, 0.00) + 
			coalesce(importe_contrato_siguiente, 0.00) + 
			coalesce(importe_contrato_pendiente, 0.00) + 
			coalesce(importe_ampliaciones_mes_1, 0.00) + 
			coalesce(importe_ampliaciones_mes_2, 0.00) + 
			coalesce(importe_ampliaciones_mes_3, 0.00) + 
			coalesce(importe_ampliaciones_mes_4, 0.00) + 
			coalesce(importe_ampliaciones_resto, 0.00) + 
			coalesce(importe_ampliaciones_proximo, 0.00) + 
			coalesce(importe_ampliaciones_siguiente, 0.00) + 
			coalesce(importe_ampliaciones_pendiente, 0.00)
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_anterior) + Coalesce(importe_ampliacion_anterior, 0.00) +
			Coalesce(importe_contrato_consolidado, 0.00) +
			Coalesce(importe_ampliacion_consolidado, 0.00) +
			Coalesce(importe_contrato_mes_1, 0.00) +
			Coalesce(importe_contrato_mes_2, 0.00) +
			Coalesce(importe_contrato_mes_3, 0.00) +
			Coalesce(importe_contrato_mes_4, 0.00) +
			Coalesce(importe_contrato_resto, 0.00) +
			Coalesce(importe_ampliaciones_mes_1, 0.00) +
			Coalesce(importe_ampliaciones_mes_2, 0.00) +
			Coalesce(importe_ampliaciones_mes_3, 0.00) +
			Coalesce(importe_ampliaciones_mes_4, 0.00) +
			Coalesce(importe_ampliaciones_resto, 0.00) +
			Coalesce(importe_contrato_proximo, 0.00) +
			Coalesce(importe_ampliaciones_proximo, 0.00) +
			Coalesce(importe_contrato_siguiente, 0.00) +
			Coalesce(importe_ampliaciones_siguiente, 0.00) +
			Coalesce(importe_contrato_pendiente, 0.00) +
			Coalesce(importe_ampliaciones_pendiente, 0.00)
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union


Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_anterior) + Coalesce(importe_ampliacion_anterior, 0.00) +
			Coalesce(importe_contrato_consolidado, 0.00) +
			Coalesce(importe_ampliacion_consolidado, 0.00) +
			Coalesce(importe_contrato_mes_1, 0.00) +
			Coalesce(importe_contrato_mes_2, 0.00) +
			Coalesce(importe_contrato_mes_3, 0.00) +
			Coalesce(importe_contrato_mes_4, 0.00) +
			Coalesce(importe_contrato_resto, 0.00) +
			Coalesce(importe_ampliaciones_mes_1, 0.00) +
			Coalesce(importe_ampliaciones_mes_2, 0.00) +
			Coalesce(importe_ampliaciones_mes_3, 0.00) +
			Coalesce(importe_ampliaciones_mes_4, 0.00) +
			Coalesce(importe_ampliaciones_resto, 0.00) +
			Coalesce(importe_contrato_proximo, 0.00) +
			Coalesce(importe_ampliaciones_proximo, 0.00) +
			Coalesce(importe_contrato_siguiente, 0.00) +
			Coalesce(importe_ampliaciones_siguiente, 0.00) +
			Coalesce(importe_contrato_pendiente, 0.00) +
			Coalesce(importe_ampliaciones_pendiente, 0.00) +
			
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union

-- PRODUCCION - Producciñn ejecutada --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'ProdTotal' as concepto,
	    Coalesce(importe_contrato_anterior, 0.00) + Coalesce(importe_ampliacion_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_consolidado, 0.00) + Coalesce(importe_ampliacion_consolidado, 0.00)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union


Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_1, 0.00) + Coalesce(importe_ampliaciones_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_2, 0.00) + Coalesce(importe_ampliaciones_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_3, 0.00) + Coalesce(importe_ampliaciones_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_4, 0.00) + Coalesce(importe_ampliaciones_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_resto, 0.00) + Coalesce(importe_ampliaciones_resto, 0.00)
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Presente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_consolidado, 0.00) +
			Coalesce(importe_ampliacion_consolidado, 0.00) +
			Coalesce(importe_contrato_mes_1, 0.00) +
			Coalesce(importe_contrato_mes_2, 0.00) +
			Coalesce(importe_contrato_mes_3, 0.00) +
			Coalesce(importe_contrato_mes_4, 0.00) +
			Coalesce(importe_contrato_resto, 0.00) +
			Coalesce(importe_ampliaciones_mes_1, 0.00) +
			Coalesce(importe_ampliaciones_mes_2, 0.00) +
			Coalesce(importe_ampliaciones_mes_3, 0.00) +
			Coalesce(importe_ampliaciones_mes_4, 0.00) +
			Coalesce(importe_ampliaciones_resto, 0.00)
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_proximo, 0.00) + 
       		Coalesce(importe_ampliaciones_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_siguiente, 0.00) +
			coalesce(importe_ampliaciones_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_coste_pendiente, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_mes_1, 0.00) +
			coalesce(importe_contrato_mes_2, 0.00) + 
			coalesce(importe_contrato_mes_3, 0.00) + 
			coalesce(importe_contrato_mes_4, 0.00) + 
			coalesce(importe_contrato_resto, 0.00) + 
			coalesce(importe_contrato_proximo, 0.00) + 
			coalesce(importe_contrato_siguiente, 0.00) + 
			coalesce(importe_contrato_pendiente, 0.00) + 
			coalesce(importe_ampliaciones_mes_1, 0.00) + 
			coalesce(importe_ampliaciones_mes_2, 0.00) + 
			coalesce(importe_ampliaciones_mes_3, 0.00) + 
			coalesce(importe_ampliaciones_mes_4, 0.00) + 
			coalesce(importe_ampliaciones_resto, 0.00) + 
			coalesce(importe_ampliaciones_proximo, 0.00) + 
			coalesce(importe_ampliaciones_siguiente, 0.00) + 
			coalesce(importe_ampliaciones_pendiente, 0.00)
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_anterior) + Coalesce(importe_ampliacion_anterior, 0.00) +
			Coalesce(importe_contrato_consolidado, 0.00) +
			Coalesce(importe_ampliacion_consolidado, 0.00) +
			Coalesce(importe_contrato_mes_1, 0.00) +
			Coalesce(importe_contrato_mes_2, 0.00) +
			Coalesce(importe_contrato_mes_3, 0.00) +
			Coalesce(importe_contrato_mes_4, 0.00) +
			Coalesce(importe_contrato_resto, 0.00) +
			Coalesce(importe_ampliaciones_mes_1, 0.00) +
			Coalesce(importe_ampliaciones_mes_2, 0.00) +
			Coalesce(importe_ampliaciones_mes_3, 0.00) +
			Coalesce(importe_ampliaciones_mes_4, 0.00) +
			Coalesce(importe_ampliaciones_resto, 0.00) +
			Coalesce(importe_contrato_proximo, 0.00) +
			Coalesce(importe_ampliaciones_proximo, 0.00) +
			Coalesce(importe_contrato_siguiente, 0.00) +
			Coalesce(importe_ampliaciones_siguiente, 0.00) +
			Coalesce(importe_contrato_pendiente, 0.00) +
			Coalesce(importe_ampliaciones_pendiente, 0.00)
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union


Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_contrato_anterior) + Coalesce(importe_ampliacion_anterior, 0.00) +
			Coalesce(importe_contrato_consolidado, 0.00) +
			Coalesce(importe_ampliacion_consolidado, 0.00) +
			Coalesce(importe_contrato_mes_1, 0.00) +
			Coalesce(importe_contrato_mes_2, 0.00) +
			Coalesce(importe_contrato_mes_3, 0.00) +
			Coalesce(importe_contrato_mes_4, 0.00) +
			Coalesce(importe_contrato_resto, 0.00) +
			Coalesce(importe_ampliaciones_mes_1, 0.00) +
			Coalesce(importe_ampliaciones_mes_2, 0.00) +
			Coalesce(importe_ampliaciones_mes_3, 0.00) +
			Coalesce(importe_ampliaciones_mes_4, 0.00) +
			Coalesce(importe_ampliaciones_resto, 0.00) +
			Coalesce(importe_contrato_proximo, 0.00) +
			Coalesce(importe_ampliaciones_proximo, 0.00) +
			Coalesce(importe_contrato_siguiente, 0.00) +
			Coalesce(importe_ampliaciones_siguiente, 0.00) +
			Coalesce(importe_contrato_pendiente, 0.00) +
			Coalesce(importe_ampliaciones_pendiente, 0.00) +
			
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union


-- CosteDeleg --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'CtesCentral' as concepto,
	    Coalesce(importe_coste_central_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'CtesCentral' concepto,
       		((Coalesce((importe_contrato_consolidado), 0.00) +
            Coalesce((importe_ampliacion_consolidado), 0.00)) *
            Coalesce((gasto_central), 0.00)/100)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'CtesCentral' concepto,
			((Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_1), 0.00)) *
             Coalesce((gasto_central), 0.00)/100)
             
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'CtesCentral' concepto,
			((Coalesce((importe_ampliaciones_mes_2), 0.00) + Coalesce((importe_contrato_mes_2), 0.00)) *
             Coalesce((gasto_central), 0.00)/100)
             
			as importe,-- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'CtesCentral' concepto,
			((Coalesce((importe_ampliaciones_mes_3), 0.00) + Coalesce((importe_contrato_mes_3), 0.00)) *
             Coalesce((gasto_central), 0.00)/100)
             
			as importe,-- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'CtesCentral' concepto,
			((Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_mes_4), 0.00)) *
             Coalesce((gasto_central), 0.00)/100)
             
			as importe,-- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'CtesCentral' concepto,

       	((Coalesce((importe_ampliaciones_resto), 0.00) +
            Coalesce((importe_contrato_resto), 0.00)) *
         Coalesce((gasto_central), 0.00)/100)
             
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' periodo,
       'CtesCentral' concepto,
       		
			((((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_central), 0.00)) / 100) +
                (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
                Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100)
       
       
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'CtesCentral' concepto,
       		((Coalesce((importe_contrato_proximo), 0.00) +
            Coalesce((importe_ampliaciones_proximo), 0.00)) * Coalesce((gasto_central), 0.00)/100)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'CtesCentral' concepto,
       		((Coalesce((importe_contrato_siguiente), 0.00) +
            Coalesce((importe_ampliaciones_siguiente), 0.00))*Coalesce((gasto_central), 0.00)/100)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'CtesCentral' concepto,
       		((Coalesce((importe_contrato_pendiente), 0.00) +
               Coalesce((importe_ampliaciones_pendiente), 0.00))*Coalesce((gasto_central), 0.00)/100)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'CtesCentral' concepto,
		((Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) +
		Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
       	Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+
       	Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100+
       	(
			(Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_central), 0.00)/100
       	) +
        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_central), 0.00)/100)+
        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_central), 0.00)/100))
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'CtesCentral' concepto,
			
   			Coalesce(importe_coste_central_anterior, 0.00)

		   +
       
		   	(
			   	((Coalesce((importe_contrato_consolidado), 0.00) +
	            Coalesce((importe_ampliacion_consolidado), 0.00)) *
	            Coalesce((gasto_central), 0.00)/100)
            )
	        
	        +
	   		
			(
				((Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) +
				Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
		       	Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+
		       	Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100+
		       	(
					(Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_central), 0.00)/100
		       	) +
		        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_central), 0.00)/100)+
		        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_central), 0.00)/100))
			)

			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'CtesCentral' concepto,
       		(((
       		Coalesce(importe_contrato_consolidado, 0.00) + Coalesce(importe_ampliacion_consolidado, 0.00) * Coalesce(gasto_central, 0.00) / 100
	   ) +
       
       ((
       		Coalesce(importe_contrato_mes_1, 0.00) +
       		Coalesce(importe_ampliaciones_mes_1, 0.00) +
       		Coalesce(importe_contrato_mes_2, 0.00) +
       		Coalesce(importe_ampliaciones_mes_2, 0.00) +
       		Coalesce(importe_contrato_mes_3, 0.00) +
       		Coalesce(importe_ampliaciones_mes_3, 0.00) +
       		Coalesce(importe_contrato_mes_4, 0.00) +
       		Coalesce(importe_ampliaciones_mes_4, 0.00) +
       		Coalesce(importe_contrato_resto, 0.00) +
       		Coalesce(importe_ampliaciones_resto, 0.00)
       ) * Coalesce(gasto_central, 0.00) / 100
       ))+
       	((Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_central), 0.00)/100) +
        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_central), 0.00)/100)+
        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_central), 0.00)/100) +
		(Coalesce(hh.importe_coste_central_anterior, 0.00))) + 
			
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union


-- CosteTotal --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'CosteTotal' as concepto,
	    
		(coalesce((importe_coste_central_anterior), 0.00) +
        Coalesce((importe_coste_delegacion_anterior), 0.00) +
        Coalesce((importe_coste_directo_anterior), 0.00))
                            
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'CosteTotal' concepto,
       
       		Coalesce(importe_coste_directo_consolidado , 0.00) +
       		
       		Coalesce(importe_coste_delegacion_anterior, 0.00) +
       		
       		((Coalesce((importe_contrato_consolidado), 0.00) +
            Coalesce((importe_ampliacion_consolidado), 0.00)) *
            Coalesce((gasto_central), 0.00)/100)
       		
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'CosteTotal' concepto,
       		
			(Coalesce((importe_coste_mes_1), 0.00) + (Coalesce((importe_contrato_mes_1), 0.00) +
            Coalesce((importe_ampliaciones_mes_1), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                                                
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'CosteTotal' concepto,
       		
			(Coalesce((importe_coste_mes_2), 0.00) + (Coalesce((importe_contrato_mes_2), 0.00) +
            Coalesce((importe_ampliaciones_mes_2), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                  
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'CosteTotal' concepto,
       		
			(Coalesce((importe_coste_mes_3), 0.00) + (Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                  
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'CosteTotal' concepto,
       		
			(Coalesce((importe_coste_mes_4), 0.00) + (Coalesce((importe_contrato_mes_4), 0.00) +
            Coalesce((importe_ampliaciones_mes_4), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                  
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' as periodo,
       'CosteTotal' as concepto,
	    
		(Coalesce((importe_coste_resto), 0.00) + (Coalesce((importe_contrato_resto), 0.00) +
		Coalesce((importe_ampliaciones_resto), 0.00))*(Coalesce((gasto_delegacion), 0.00)
		+Coalesce((gasto_central), 0.00))/100)

		as importe, -- presente_resto
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' as periodo,
       'CosteTotal' as concepto,
	    
       	((
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_central), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100
        )
        +
        (
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_delegacion), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
        )
        +
        (
            Coalesce((importe_coste_directo_consolidado), 0.00) +
            Coalesce((importe_coste_mes_1), 0.00) + Coalesce((importe_coste_mes_2), 0.00) +
            Coalesce((importe_coste_mes_3), 0.00) +
            Coalesce((importe_coste_mes_4), 0.00) +
            Coalesce((importe_coste_resto), 0.00)
        ))
       
		as importe, -- importe_presente
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'CosteTotal' concepto,
       		
		(Coalesce((importe_coste_proximo), 0.00) + (Coalesce((importe_contrato_proximo), 0.00) +
    	Coalesce((importe_ampliaciones_proximo), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                                                
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'CosteTotal' concepto,
			
       		(Coalesce((importe_coste_siguiente), 0.00) + (Coalesce((importe_contrato_siguiente), 0.00) +
            Coalesce((importe_ampliaciones_siguiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
        
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'CosteTotal' concepto,
       		
		(Coalesce((importe_coste_pendiente), 0.00) + (Coalesce((importe_contrato_pendiente), 0.00) +
        Coalesce((importe_ampliaciones_pendiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
                                                
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'CosteTotal' concepto,
       		 ((
	       		Coalesce(importe_coste_mes_1, 0.00) +
				coalesce(importe_coste_mes_2, 0.00) + 
				coalesce(importe_coste_mes_3, 0.00) + 
				coalesce(importe_coste_mes_4, 0.00) + 
				coalesce(importe_coste_resto, 0.00) + 
				Coalesce(importe_coste_proximo, 0.00) + 
				Coalesce(importe_coste_siguiente, 0.00) + 
				Coalesce(importe_coste_pendiente, 0.00)
       		 ) +
			(
				((Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) +
				Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
		       	Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+
		       	Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100+
	       	(
				(Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
	       	) +
		        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100)+
		        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100))
	        )+
			(
				((Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) +
				Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
		       	Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+
		       	Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100+
		       	(
					(Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_central), 0.00)/100
		       	) +
		        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_central), 0.00)/100)+
	        	((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_central), 0.00)/100))
			))
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'CosteTotal' concepto,
			
       		((
       		((
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_central), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100
        )
        +
        (
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_delegacion), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
        )
        +
        (
            Coalesce((importe_coste_directo_consolidado), 0.00) +
            Coalesce((importe_coste_mes_1), 0.00) + Coalesce((importe_coste_mes_2), 0.00) +
            Coalesce((importe_coste_mes_3), 0.00) +
            Coalesce((importe_coste_mes_4), 0.00) +
            Coalesce((importe_coste_resto), 0.00)
        ))
       		) +
       		(
	       		(Coalesce((importe_coste_proximo), 0.00) + (Coalesce((importe_contrato_proximo), 0.00) +
	    		Coalesce((importe_ampliaciones_proximo), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
	        ) +
       		(
	       		(Coalesce((importe_coste_siguiente), 0.00) + (Coalesce((importe_contrato_siguiente), 0.00) +
	            Coalesce((importe_ampliaciones_siguiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
        	) +
			(
				(Coalesce((importe_coste_pendiente), 0.00) + (Coalesce((importe_contrato_pendiente), 0.00) +
		        Coalesce((importe_ampliaciones_pendiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)       
	        ) +
			(
				(coalesce((importe_coste_central_anterior), 0.00) +
		        Coalesce((importe_coste_delegacion_anterior), 0.00) +
		        Coalesce((importe_coste_directo_anterior), 0.00))
			))
			
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'CosteTotal' concepto,
       		
       ((
       		((
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_central), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_central), 0.00)/100
        )
        +
        (
            (((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_delegacion), 0.00)) / 100) +

            (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
            Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
        )
        +
        (
            Coalesce((importe_coste_directo_consolidado), 0.00) +
            Coalesce((importe_coste_mes_1), 0.00) + Coalesce((importe_coste_mes_2), 0.00) +
            Coalesce((importe_coste_mes_3), 0.00) +
            Coalesce((importe_coste_mes_4), 0.00) +
            Coalesce((importe_coste_resto), 0.00)
        ))
       		) +
       		(
	       		(Coalesce((importe_coste_proximo), 0.00) + (Coalesce((importe_contrato_proximo), 0.00) +
	    		Coalesce((importe_ampliaciones_proximo), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
	        ) +
       		(
	       		(Coalesce((importe_coste_siguiente), 0.00) + (Coalesce((importe_contrato_siguiente), 0.00) +
	            Coalesce((importe_ampliaciones_siguiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)
        	) +
			(
				(Coalesce((importe_coste_pendiente), 0.00) + (Coalesce((importe_contrato_pendiente), 0.00) +
		        Coalesce((importe_ampliaciones_pendiente), 0.00))*(Coalesce((gasto_delegacion), 0.00)+Coalesce((gasto_central), 0.00))/100)       
	        ) +
			(
				(coalesce((importe_coste_central_anterior), 0.00) +
		        Coalesce((importe_coste_delegacion_anterior), 0.00) +
		        Coalesce((importe_coste_directo_anterior), 0.00))
			))
			
			+

			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union

-- CosteDirecto --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'CosteDirecto' as concepto,
	    Coalesce(importe_coste_directo_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_directo_consolidado , 0.00)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'CosteDirecto' concepto,
			Coalesce(importe_coste_resto, 0.00)
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_directo_consolidado, 0.00) +
			Coalesce(importe_coste_mes_1, 0.00) +
			Coalesce(importe_coste_mes_2, 0.00) +
			Coalesce(importe_coste_mes_3, 0.00) +
			Coalesce(importe_coste_mes_4, 0.00) +
			Coalesce(importe_coste_resto, 0.00)
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_pendiente, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_mes_1, 0.00) +
			coalesce(importe_coste_mes_2, 0.00) + 
			coalesce(importe_coste_mes_3, 0.00) + 
			coalesce(importe_coste_mes_4, 0.00) + 
			coalesce(importe_coste_resto, 0.00) + 
			Coalesce(importe_coste_proximo, 0.00) + 
			Coalesce(importe_coste_siguiente, 0.00) + 
			Coalesce(importe_coste_pendiente, 0.00)
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'CosteDirecto' concepto,
			Coalesce(importe_coste_directo_anterior, 0.00) +
			
			Coalesce(importe_coste_directo_consolidado, 0.00) +
			Coalesce(importe_coste_mes_1, 0.00) +
			Coalesce(importe_coste_mes_2, 0.00) +
			Coalesce(importe_coste_mes_3, 0.00) +
			Coalesce(importe_coste_mes_4, 0.00) +
			Coalesce(importe_coste_resto, 0.00) +
			
			Coalesce(importe_coste_proximo, 0.00) +
       
			Coalesce(importe_coste_siguiente, 0.00) +
			
			Coalesce(importe_coste_pendiente, 0.00)
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'CosteDirecto' concepto,
       		Coalesce(importe_coste_directo_anterior, 0.00) +
			
			Coalesce(importe_coste_directo_consolidado, 0.00) +
			Coalesce(importe_coste_mes_1, 0.00) +
			Coalesce(importe_coste_mes_2, 0.00) +
			Coalesce(importe_coste_mes_3, 0.00) +
			Coalesce(importe_coste_mes_4, 0.00) +
			Coalesce(importe_coste_resto, 0.00) +
			
			Coalesce(importe_coste_proximo, 0.00) +
       
			Coalesce(importe_coste_siguiente, 0.00) +
			
			Coalesce(importe_coste_pendiente, 0.00) +
			
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union


-- Certificacion --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'Certificacion' as concepto,
	    Coalesce(hc.importe_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'Certificacion' concepto,
       		coalesce(hc.importe_presente, 0.00)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'Certificacion' concepto,
       		Coalesce(importe_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'Certificacion' concepto,
       		Coalesce(importe_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'Certificacion' concepto,
       		Coalesce(importe_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'Certificacion' concepto,
       		Coalesce(importe_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'ProdTotal' concepto,
       		Coalesce(importe_resto, 0.00)
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)
union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' periodo,
       'Certificacion' concepto,
       		
			(Coalesce((importe_presente), 0.00)+Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00) +
            Coalesce((importe_resto), 0.00))
                        
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'Certificacion' concepto,
       		Coalesce(hc.importe_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'Certificacion' concepto,
       		Coalesce(hc.importe_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'Certificacion' concepto,
       		Coalesce(importe_pendiente, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'Certificacion' concepto,
       		
			(Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00)+Coalesce((importe_resto), 0.00)+
            (Coalesce(importe_proximo, 0.00)) +
            (Coalesce(importe_siguiente, 0.00)) +
            (Coalesce(importe_pendiente, 0.00)))
                        
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'Certificacion' concepto,
       		
			Coalesce((importe_anterior), 0.00)
			
			+
			
			coalesce(hc.importe_presente, 0.00)
			
			+
			
			(Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00)+Coalesce((importe_resto), 0.00)+
            (Coalesce(importe_proximo, 0.00)) +
            (Coalesce(importe_siguiente, 0.00)) +
            (Coalesce(importe_pendiente, 0.00)))

			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'Certificacion' concepto,
       		
       		(((Coalesce((importe_presente), 0.00)+Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00) +
            Coalesce((importe_resto), 0.00)))+
            
			(Coalesce(importe_proximo, 0.00)) +
			(Coalesce(importe_contrato_siguiente, 0.00) +
			
			coalesce(importe_ampliaciones_siguiente, 0.00))+
			(Coalesce(importe_pendiente, 0.00)) +
			(Coalesce(hc.importe_anterior, 0.00)))
       		
       		+
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutacertificacion hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


union


-- Cobros - (50)_COBRO (RECEP. DOCUMENTO) --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'Cobros' as concepto,
	    Coalesce(hc.importe_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' as periodo,
       'Cobros' as concepto,
	    Coalesce(hc.importe_presente, 0.00)
		as importe, -- importe_realizado
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'Cobros' concepto,
       		Coalesce(importe_mes_1, 0.00)
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'Cobros' concepto,
       		Coalesce(importe_mes_2, 0.00)
			as importe, -- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'Cobros' concepto,
       		Coalesce(importe_mes_3, 0.00)
			as importe, -- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'Cobros' concepto,
       		Coalesce(importe_mes_4, 0.00)
			as importe, -- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'Cobros' concepto,
       		Coalesce(importe_resto, 0.00)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' periodo,
       'Cobros' concepto,
       		
			(Coalesce((hc.importe_presente), 0.00)+Coalesce((hc.importe_mes_1), 0.00)+Coalesce((hc.importe_mes_2), 0.00) +
            Coalesce((hc.importe_mes_3), 0.00) +
            Coalesce((hc.importe_mes_4), 0.00) +
            Coalesce((hc.importe_resto), 0.00))
       
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'Cobros' concepto,
       		Coalesce(importe_proximo, 0.00)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'Cobros' concepto,
       		Coalesce(importe_siguiente, 0.00)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'Cobros' concepto,
			Coalesce(importe_pendiente, 0.00)
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'Cobros' concepto,
       
       		(Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00)+Coalesce((importe_resto), 0.00)+
            (Coalesce(importe_proximo, 0.00)) +
            (Coalesce(importe_siguiente, 0.00)) +
            (Coalesce(importe_pendiente, 0.00)))
       
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'Cobros' concepto,
       		
			(((Coalesce((importe_presente), 0.00)+Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00) +
            Coalesce((importe_resto), 0.00)))+
			
			(Coalesce(importe_proximo, 0.00)) + 
			
			(Coalesce(importe_siguiente, 0.00))+
			
			(Coalesce(importe_pendiente, 0.00)) +
			
			(Coalesce(hc.importe_anterior, 0.00)))

			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'Cobros' concepto,
       		
       		(((Coalesce((importe_presente), 0.00)+Coalesce((importe_mes_1), 0.00)+Coalesce((importe_mes_2), 0.00) +
            Coalesce((importe_mes_3), 0.00) +
            Coalesce((importe_mes_4), 0.00) +
            Coalesce((importe_resto), 0.00)))+
			
			(Coalesce(importe_proximo, 0.00)) + 
			
			(Coalesce(importe_siguiente, 0.00))+
			
			(Coalesce(importe_pendiente, 0.00)) +
			
			(Coalesce(hc.importe_anterior, 0.00)))
       		
       		+
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join hdr_hojaderutaCobro hc On (hh.id = hc.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)



union


-- CosteDeleg --

Select go2.empresa_id as empresa,
       --go2.id as obra_id,
       --go2.codigo as codigo,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Anterior' as periodo,
       'CtesDeleg' as concepto,
	    Coalesce(importe_coste_delegacion_anterior, 0.00)
		as importe, -- importe_anterior
       participacion_licuas,
	   Coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Consolidado' periodo,
       'CtesDeleg' concepto,
       		((Coalesce((importe_contrato_consolidado), 0.00) +
            Coalesce((importe_ampliacion_consolidado), 0.00)) *
            Coalesce((gasto_delegacion), 0.00)/100)
			as importe, -- importe_realizado
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes1' periodo,
       'CtesDeleg' concepto,
			((Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_1), 0.00)) *
             Coalesce((gasto_delegacion), 0.00)/100)
             
			as importe,-- mes1
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes2' periodo,
       'CtesDeleg' concepto,
			((Coalesce((importe_ampliaciones_mes_2), 0.00) + Coalesce((importe_contrato_mes_2), 0.00)) *
             Coalesce((gasto_delegacion), 0.00)/100)
             
			as importe,-- mes2
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes3' periodo,
       'CtesDeleg' concepto,
			((Coalesce((importe_ampliaciones_mes_3), 0.00) + Coalesce((importe_contrato_mes_3), 0.00)) *
             Coalesce((gasto_delegacion), 0.00)/100)
             
			as importe,-- mes3
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Mes4' periodo,
       'CtesDeleg' concepto,
			((Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_mes_4), 0.00)) *
             Coalesce((gasto_delegacion), 0.00)/100)
             
			as importe,-- mes4
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Pendiente' periodo,
       'CtesDeleg' concepto,

       	((Coalesce((importe_ampliaciones_resto), 0.00) +
            Coalesce((importe_contrato_resto), 0.00)) *
         Coalesce((gasto_delegacion), 0.00)/100)
             
			as importe, -- presente_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'ejercicioActual' periodo,
       'CtesDeleg' concepto,
       		
			((((Coalesce((importe_contrato_consolidado), 0.00) + Coalesce((importe_ampliacion_consolidado), 0.00) ) * Coalesce((gasto_delegacion), 0.00)) / 100) +
                (Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00) + Coalesce((importe_contrato_mes_2), 0.00) + Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
                Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00) + Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100)
       
       
			as importe, -- importe_presente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Proximo' periodo,
       'CtesDeleg' concepto,
       		((Coalesce((importe_contrato_proximo), 0.00) +
            Coalesce((importe_ampliaciones_proximo), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100)
			as importe, -- importe_proximo
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Siguiente' periodo,
       'CtesDeleg' concepto,
       		((Coalesce((importe_contrato_siguiente), 0.00) +
            Coalesce((importe_ampliaciones_siguiente), 0.00))*Coalesce((gasto_delegacion), 0.00)/100)
			as importe, -- importe_siguiente
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union 

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Resto' periodo,
       'CtesDeleg' concepto,
       		((Coalesce((importe_contrato_pendiente), 0.00) +
               Coalesce((importe_ampliaciones_pendiente), 0.00))*Coalesce((gasto_delegacion), 0.00)/100)
			as importe, -- importe_resto
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'TotalPrevision' periodo,
       'CtesDeleg' concepto,
		((Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) +
		Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
       	Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+
       	Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100+
       	(
			(Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
       	) +
        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100)+
        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100))
			as importe, -- importe_prevision
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'FinObra' periodo,
       'CtesDeleg' concepto,
			
       		Coalesce(importe_coste_delegacion_anterior, 0.00)
       		
		   	+
		   	
		   	((Coalesce((importe_contrato_consolidado), 0.00) +
            Coalesce((importe_ampliacion_consolidado), 0.00)) *
            Coalesce((gasto_delegacion), 0.00)/100)
            
            +
            
	       ((Coalesce((importe_contrato_mes_1), 0.00) + Coalesce((importe_ampliaciones_mes_1), 0.00)+Coalesce((importe_contrato_mes_2), 0.00) +
			Coalesce((importe_ampliaciones_mes_2), 0.00)+Coalesce((importe_contrato_mes_3), 0.00) +
	       	Coalesce((importe_ampliaciones_mes_3), 0.00)+Coalesce((importe_contrato_mes_4), 0.00) + Coalesce((importe_ampliaciones_mes_4), 0.00)+
	       	Coalesce((importe_contrato_resto), 0.00) + Coalesce((importe_ampliaciones_resto), 0.00)) * Coalesce((gasto_delegacion), 0.00)/100+
	       	(
				(Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100
	       	) +
	        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100)+
	        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100))
		
			as importe, -- importe_fin
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)

union

Select go2.empresa_id as empresa,
	   go2.codigo as obra,
       hh."year" as ejercicio,
       hh.cuarto as cuarto,
       'Objetivos' periodo,
       'CtesDeleg' concepto,
       		(((
       		Coalesce(importe_contrato_consolidado, 0.00) + Coalesce(importe_ampliacion_consolidado, 0.00) * Coalesce(gasto_delegacion, 0.00) / 100
	   ) +
       
       ((
       		Coalesce(importe_contrato_mes_1, 0.00) +
       		Coalesce(importe_ampliaciones_mes_1, 0.00) +
       		Coalesce(importe_contrato_mes_2, 0.00) +
       		Coalesce(importe_ampliaciones_mes_2, 0.00) +
       		Coalesce(importe_contrato_mes_3, 0.00) +
       		Coalesce(importe_ampliaciones_mes_3, 0.00) +
       		Coalesce(importe_contrato_mes_4, 0.00) +
       		Coalesce(importe_ampliaciones_mes_4, 0.00) +
       		Coalesce(importe_contrato_resto, 0.00) +
       		Coalesce(importe_ampliaciones_resto, 0.00)
       ) * Coalesce(gasto_delegacion, 0.00) / 100
       ))+
       	((Coalesce(importe_contrato_proximo, 0.00) + Coalesce(importe_ampliaciones_proximo, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100) +
        ((Coalesce(importe_contrato_siguiente, 0.00) + Coalesce(importe_ampliaciones_siguiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100)+
        ((Coalesce(importe_contrato_pendiente, 0.00) + Coalesce(importe_ampliaciones_pendiente, 0.00)) * Coalesce((gasto_delegacion), 0.00)/100) +
		(Coalesce(hh.importe_coste_central_anterior, 0.00))) + 
			
			Coalesce((Select sum(venta) From hdr_objetivo ho Where hoja_id = hh.id), 0.00)
			as importe, -- importe_objetivos
       participacion_licuas,
	   coalesce((Select importe
	    From general_cambiodivisa gc
	    Where go2.divisa_id = gc.divisa_id
	       And gc.year = hh.year
	       And gc.cuarto = hh.cuarto ), 0.00) as conversion_euros
From hdr_hojaderuta hh
Join hdr_hojaderutaproduccion hp On (hh.id = hp.hoja_id)
Join general_obra go2 On (hh.obra_id = go2.id)


Order by empresa,
         obra,
         periodo,
         concepto,
         ejercicio,
         cuarto
