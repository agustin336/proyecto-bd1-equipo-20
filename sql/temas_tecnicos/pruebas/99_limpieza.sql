/* ============================================================================
   LIMPIEZA - deja la base como estaba antes de las pruebas
   Las facturas de prueba tienen id > 8. Restaura el stock de las computadoras
   1 y 2 y reinicia los IDENTITY para que no queden saltos.
   Si existe un trigger que bloquea el DELETE de facturas, desactivarlo antes
   (DISABLE TRIGGER nombre ON Cabecera_Factura) y volver a activarlo despues.
   Esperado: facturas 8, detalles 8, stock_comp_1 5, stock_comp_2 14.
   ============================================================================ */
USE Venta_Computadoras;
GO

BEGIN TRANSACTION;
    DELETE FROM Detalle_Venta    WHERE id_cabecera_factura > 8;
    DELETE FROM Cabecera_Factura WHERE id_cabecera_factura > 8;
    UPDATE Computadora SET stock = 5  WHERE id_computadora = 1;
    UPDATE Computadora SET stock = 14 WHERE id_computadora = 2;
COMMIT TRANSACTION;

DBCC CHECKIDENT ('Cabecera_Factura', RESEED, 8);
DBCC CHECKIDENT ('Detalle_Venta',    RESEED, 8);
GO

PRINT '--- Estado final (debe ser el inicial: 8, 8, 5, 14) ---';
SELECT (SELECT COUNT(*) FROM Cabecera_Factura)                    AS facturas,
       (SELECT COUNT(*) FROM Detalle_Venta)                       AS detalles,
       (SELECT stock FROM Computadora WHERE id_computadora = 1)   AS stock_comp_1,
       (SELECT stock FROM Computadora WHERE id_computadora = 2)   AS stock_comp_2;
GO