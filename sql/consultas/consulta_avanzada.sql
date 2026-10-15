USE Venta_Computadoras;
GO

-- ==========
-- CONSULTA 1
-- ==========
-- ventas x encima del ticket promedio, con cliente, equipo, componente.
-- devuelve 4 filas con los datos que tenemos 

-- 4) aca se arman las columas de para la salida
SELECT cf.id_cabecera_factura, cf.fecha,
	   cl.nombre + ' ' + cl.apellido AS cliente, -- concatena datos cliente
	   comp.nombre AS equipo,
	   pr.modelo AS procesador,
	   -- COALESCE devuelve primer valor no null, si hay null devuelve el valor alternativo 'Integrada'
	   COALESCE (pv.modelo, 'Integrada') AS placa_video,
	   cf.total
FROM Detalle_Venta dv -- 1) tabla base que elegimos xq tiene subtotal y claves hacia factura y compu

-- 2) trameos los item q nos importan
-- ej: con dv_id_cabecera traemos Cabecera q viene con fecha, id_cliente, etc
JOIN Cabecera_Factura cf ON cf.id_cabecera_factura = dv.id_cabecera_factura
JOIN Cliente cl ON cl.id_cliente = cf.id_cliente
JOIN Computadora comp ON comp.id_computadora = dv.id_computadora
JOIN Procesador pr ON pr.id_procesador = comp.id_procesador

-- 2.5) tuve q meter LEFT JOIN xq tenemos elementos de compu con datos null (la "HP all in one" x ej)
-- y si uso un join comun esas filas no aparecen.
LEFT JOIN Placa_Video pv ON pv.id_placa_video = comp.id_placa_video

-- 3) es una subconsulta que filtra  en base al promedio de todos los totales (si queres ver cuanto es 
-- el promedio ejecuta solo el SELECT AVG q esta entre ()).
-- WHERE descar las filas cuyo total no llegue a ese valor.
-- como de momento cada fatura tiene un solo producto daria el mismo resultado si usaramos subtotal
WHERE cf.total > (SELECT AVG(total) FROM Cabecera_Factura)
ORDER BY cf.total DESC;


-- ==========
-- CONSULTA 2
-- ==========
-- medios de pago cuyo ticket premedio supera el promedio general. 
-- con el filtro de 30 dias devuelve 1 fila con nuestros datos, sin filtro de fecha devuelve 3 filas

-- es como declarar una variable, la usamos en los ultimos 2 filtros
DECLARE @desde DATE = DATEADD(DAY, -30, CAST(GETDATE() AS DATE));
-- otras opciones de filtrado:
-- mes en curso:
-- DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
-- mes calendario anterior:
-- DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) AND cf.fecha <  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)

-- para cada grupo se calcula:
SELECT tp.tipo AS medio_pago,
	   -- cuenta las facturas, DISTINCT es necesario xq si una factura tiene tres lineas, 
	   -- join repite su cabecera 3 veces
	   COUNT(DISTINCT cf.id_cabecera_factura) AS cantidad_facturas,
	   -- suma el monto vendido
	   SUM(dv.subtotal) AS monto_total,
	   -- promedio x linea (tickect propmedio)
	   AVG(dv.subtotal) AS ticket_promedio
FROM Tipo_Pago tp
JOIN Cabecera_Factura cf ON cf.id_tipo_pago = tp.id_tipo_pago
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura

-- aca fitra por los ultimos 30 dias
WHERE cf.fecha >= @desde

-- Agrupa filas x medio de pago
GROUP BY tp.tipo
-- aca filtra los grupos, conserva los medios de pago que superen el AVG
HAVING AVG(dv.subtotal) > (
	SELECT AVG(dv2.subtotal) 
	FROM Detalle_Venta dv2
	JOIN Cabecera_Factura cf2 ON cf2.id_cabecera_factura = dv2.id_cabecera_factura
	WHERE cf2.fecha >= @desde
)
ORDER BY ticket_promedio DESC;


-- ==========
-- COLSULTA 3
-- ==========
-- clientes q gastaron mas que el promedio, q compraron, como pagaron y quien se lo vendio
-- devuelve 4 filas

-- esto es un CTE (common table exprsion), es un resultado temporal nombrado q se usa dentro de una consulta
-- el cte existe solo mientras dure la instrucicon
-- este cte calcula el promedio del monto x cliente y el total  general
WITH referencia AS (
	-- valores de comparacion: gasto promedio por cliente y ventas totales
	SELECT AVG(t.monto_cliente) AS promedio_cliente,
		   SUM(t.monto_cliente) AS total_general
	FROM (
		SELECT cf.id_cliente, SUM(dv.subtotal) AS monto_cliente
		FROM Cabecera_Factura cf
		JOIN Detalle_venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
		GROUP BY  cf.id_cliente
	) AS t
),
-- este cte calcula el acumulado por cliente, quedandose solo con los que superan el promedio
-- calculado por el cte anterior
ventas_cliente AS (
	SELECT cf.id_cliente,
		COUNT(DISTINCT cf.id_cabecera_factura) AS cantidad_compras,
		SUM(dv.subtotal) AS monto_total
	FROM Cabecera_Factura cf
	JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
	GROUP BY cf.id_cliente
	HAVING SUM(dv.subtotal) > (SELECT promedio_cliente FROM referencia)
)
SELECT
	-- funcion de ventana q numera las filas segun el gasto del cliente, sin colapsar 
	-- las filas como lo haria gruop by
	-- se usa DENSE_RANK y no RANK xq puede haber clientes q empaten
	DENSE_RANK() OVER (ORDER BY v.monto_total DESC) AS ranking,
	cl.nombre + ' ' + cl.apellido AS cliente,
	cf.fecha, 
	comp.nombre AS equipo,
	pr.marca + ' ' + pr.modelo AS procesador,
	r.tipo + ' ' + CAST(r.cantidad_memoria AS VARCHAR(10)) + ' GB' AS memoria_ram,
	al.tamano_gb AS almacenamiento_gb,
	COALESCE(pv.modelo, 'Integrada') AS placa_video,
	-- aca clasifica el equipio segun la placa de video, 
	CASE
		WHEN pv.id_placa_video IS NULL THEN 'Sin placa dedicada'
		WHEN pv.cantidad_VRAM >= 16 THEN 'Gama alta'
		ELSE 'Gama media'
	END AS gama,
	dv.subtotal,
	v.monto_total AS total_cliente,
	v.monto_total - ref.promedio_cliente AS dif_vs_promedio,
	-- porcentaje de la ventas totales q representa el cliente
	CAST(100.0 * v.monto_total / ref.total_general AS DECIMAL(5,2)) AS pct_del_total,
	tp.tipo AS medio_pago,
	u.nombre + ' ' + u.apellido AS vendedor
FROM ventas_cliente v
-- cross join conbina cada fila con todas las de la otra tabla
CROSS JOIN referencia ref
JOIN Cliente cl ON cl.id_cliente = v.id_cliente
JOIN Cabecera_Factura cf ON cf.id_cliente = v.id_cliente
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
JOIN Computadora comp ON comp.id_computadora = dv.id_computadora
JOIN Procesador pr ON pr.id_procesador = comp.id_procesador
JOIN RAM r ON r.id_RAM = comp.id_RAM
JOIN Almacenamiento al ON al.id_almacenamiento = comp.id_almacenamiento
-- placa LEFT JOIN x el tema de los null
LEFT JOIN Placa_Video pv ON pv.id_placa_video = comp.id_placa_video
JOIN Tipo_Pago tp ON tp.id_tipo_pago = cf.id_tipo_pago
JOIN Usuario u ON u.id_usuario = cf.id_usuario
ORDER BY ranking, cf.fecha;