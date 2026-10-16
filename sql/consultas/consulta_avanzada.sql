USE Venta_Computadoras;
GO

-- ==========
-- CONSULTA 1
-- ==========
-- Ventas por encima del ticket promedio.

SELECT cf.id_cabecera_factura, cf.fecha,
	   cl.nombre + ' ' + cl.apellido AS cliente,
	   comp.nombre AS equipo,
	   pr.modelo AS procesador,
	   COALESCE (pv.modelo, 'Integrada') AS placa_video,
	   cf.total
FROM Detalle_Venta dv
JOIN Cabecera_Factura cf ON cf.id_cabecera_factura = dv.id_cabecera_factura
JOIN Cliente cl ON cl.id_cliente = cf.id_cliente
JOIN Computadora comp ON comp.id_computadora = dv.id_computadora
JOIN Procesador pr ON pr.id_procesador = comp.id_procesador
LEFT JOIN Placa_Video pv ON pv.id_placa_video = comp.id_placa_video
WHERE cf.total > (SELECT AVG(total) FROM Cabecera_Factura)
ORDER BY cf.total DESC;


-- ==========
-- CONSULTA 2
-- ==========
-- Medios de pago cuyo ticket premedio supera el promedio general. 

-- Variable para filtrar los últimos 30 días a partir de la fecha actual
DECLARE @desde DATE = DATEADD(DAY, -30, CAST(GETDATE() AS DATE));

SELECT tp.tipo AS medio_pago,
	   COUNT(DISTINCT cf.id_cabecera_factura) AS cantidad_facturas,
	   SUM(dv.subtotal) AS monto_total,
	   AVG(dv.subtotal) AS ticket_promedio
FROM Tipo_Pago tp
JOIN Cabecera_Factura cf ON cf.id_tipo_pago = tp.id_tipo_pago
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
WHERE cf.fecha >= @desde
GROUP BY tp.tipo
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
--  Clientes que más gastaron (ranking, hardware y porcentaje)

-- CTE 1: Calcula el gasto promedio por cliente y el total general de la empresa
WITH referencia AS (
	SELECT AVG(t.monto_cliente) AS promedio_cliente,
		   SUM(t.monto_cliente) AS total_general
	FROM (
		SELECT cf.id_cliente, SUM(dv.subtotal) AS monto_cliente
		FROM Cabecera_Factura cf
		JOIN Detalle_venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
		GROUP BY  cf.id_cliente
	) AS t
),
-- CTE 2: Agrupa por cliente y se queda solo con los que superan el promedio
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
	DENSE_RANK() OVER (ORDER BY v.monto_total DESC) AS ranking,
	cl.nombre + ' ' + cl.apellido AS cliente,
	cf.fecha, 
	comp.nombre AS equipo,
	pr.marca + ' ' + pr.modelo AS procesador,
	r.tipo + ' ' + CAST(r.cantidad_memoria AS VARCHAR(10)) + ' GB' AS memoria_ram,
	al.tamano_gb AS almacenamiento_gb,
	COALESCE(pv.modelo, 'Integrada') AS placa_video,
	CASE
		WHEN pv.id_placa_video IS NULL THEN 'Sin placa dedicada'
		WHEN pv.cantidad_VRAM >= 16 THEN 'Gama alta'
		ELSE 'Gama media'
	END AS gama,
	dv.subtotal,
	v.monto_total AS total_cliente,
	v.monto_total - ref.promedio_cliente AS dif_vs_promedio,
	CAST(100.0 * v.monto_total / ref.total_general AS DECIMAL(5,2)) AS pct_del_total,
	tp.tipo AS medio_pago,
	u.nombre + ' ' + u.apellido AS vendedor
FROM ventas_cliente v
CROSS JOIN referencia ref
JOIN Cliente cl ON cl.id_cliente = v.id_cliente
JOIN Cabecera_Factura cf ON cf.id_cliente = v.id_cliente
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
JOIN Computadora comp ON comp.id_computadora = dv.id_computadora
JOIN Procesador pr ON pr.id_procesador = comp.id_procesador
JOIN RAM r ON r.id_RAM = comp.id_RAM
JOIN Almacenamiento al ON al.id_almacenamiento = comp.id_almacenamiento
LEFT JOIN Placa_Video pv ON pv.id_placa_video = comp.id_placa_video
JOIN Tipo_Pago tp ON tp.id_tipo_pago = cf.id_tipo_pago
JOIN Usuario u ON u.id_usuario = cf.id_usuario
ORDER BY ranking, cf.fecha;
