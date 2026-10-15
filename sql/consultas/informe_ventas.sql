USE Venta_Computadoras;
GO

SELECT u.id_usuario, u.nombre, u.apellido,
    COUNT(cf.id_cabecera_factura) AS Cantidad_Ventas,
    SUM(cf.total) AS total_Vendido
FROM Usuario u
INNER JOIN Cabecera_Factura cf ON u.id_usuario = cf.id_usuario
WHERE cf.fecha BETWEEN '2026-09-01' AND GETDATE()
GROUP BY u.id_usuario, u.nombre, u.apellido
ORDER BY total_Vendido DESC;