/*
    ================================================================
    PRUEBA 4 - TRANSACCION ANIDADA: el ROLLBACK externo deshace todo
    El COMMIT interno solo baja @@TRANCOUNT; no confirma nada.
    Esperado en Messages: @@TRANCOUNT = 1, 2, 1 y 0.
    Esperado en datos   : el estado DESPUES es igual al ANTES.
    ================================================================
*/

USE Venta_Computadoras;
GO

SET XACT_ABORT ON;
GO

PRINT '--- Estado ANTES ---';
SELECT (SELECT COUNT(*) FROM Cabecera_Factura)                    AS facturas,
       (SELECT COUNT(*) FROM Detalle_Venta)                       AS detalles,
       (SELECT stock FROM Computadora WHERE id_computadora = 1)   AS stock_comp_1,
       (SELECT stock FROM Computadora WHERE id_computadora = 2)   AS stock_comp_2;
GO

PRINT '=== PRUEBA 4: transaccion anidada con ROLLBACK externo ===';

DECLARE @id_factura INT;

BEGIN TRY
    BEGIN TRANSACTION;                                   -- nivel 1
    PRINT 'Despues del BEGIN externo  : @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5));

    INSERT INTO Cabecera_Factura (fecha, total, id_cliente, id_tipo_pago, id_usuario)
    VALUES (CAST(GETDATE() AS DATE), 3000000, 1, 1, 2);
    SET @id_factura = SCOPE_IDENTITY();

    BEGIN TRANSACTION;                                   -- nivel 2 (anidada)
    PRINT 'Despues del BEGIN interno  : @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5));

    INSERT INTO Detalle_Venta (cantidad, subtotal, id_cabecera_factura, id_computadora)
    VALUES (1, 3000000, @id_factura, 1);

    COMMIT TRANSACTION;                                  -- baja a 1, NO confirma
    PRINT 'Despues del COMMIT interno : @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5));

    ROLLBACK TRANSACTION;                                -- deshace TODO
    PRINT 'Despues del ROLLBACK       : @@TRANCOUNT = ' + CAST(@@TRANCOUNT AS VARCHAR(5));
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (debe ser igual al ANTES) ---';
SELECT (SELECT COUNT(*) FROM Cabecera_Factura)                    AS facturas,
       (SELECT COUNT(*) FROM Detalle_Venta)                       AS detalles,
       (SELECT stock FROM Computadora WHERE id_computadora = 1)   AS stock_comp_1,
       (SELECT stock FROM Computadora WHERE id_computadora = 2)   AS stock_comp_2;
GO