USE Venta_Computadoras;
GO

DECLARE @id_factura INT = 1;

SELECT  
    cf.id_cabecera_factura, cf.fecha, c.nombre AS 'Nombre Cliente', u.nombre AS 'Nombre Usuario', tp.tipo AS 'Tipo de Pago', dv.id_detalle_venta, dv.id_computadora, cm.nombre AS 'Nombre Computadora',dv.cantidad, dv.subtotal/dv.cantidad AS 'Precio Unitario', dv.subtotal, 
    
    SUM(dv.subtotal) OVER (
        ORDER BY dv.id_detalle_venta 
        ROWS UNBOUNDED PRECEDING ) AS 'Total Acumulado'

FROM Cabecera_Factura cf

INNER JOIN Detalle_Venta dv ON cf.id_cabecera_factura = dv.id_cabecera_factura
INNER JOIN Cliente c ON cf.id_cliente = c.id_cliente
INNER JOIN Usuario u ON cf.id_usuario = u.id_usuario
INNER JOIN Tipo_Pago tp ON cf.id_tipo_pago = tp.id_tipo_pago
INNER JOIN Computadora cm ON dv.id_computadora = cm.id_computadora

WHERE cf.id_cabecera_factura = @id_factura;
GO
