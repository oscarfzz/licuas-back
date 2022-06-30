--Nueva ejecucion:

SELECT cron.schedule('refrescar', '30 23 * * *', $$REFRESH MATERIALIZED VIEW public.v_datos_obras$$);
SELECT cron.schedule('truncar', '0 0 * * *', $$TRUNCATE TABLE public.t_datos_obras$$);
SELECT cron.schedule('actualizar', '1 0 * * *', $$INSERT INTO public.t_datos_obras (SELECT * FROM public.v_datos_obras)$$);

--Parar la ejecucion:

SELECT cron.unschedule('refrescar');
SELECT cron.unschedule('truncar');
SELECT cron.unschedule('actualizar');