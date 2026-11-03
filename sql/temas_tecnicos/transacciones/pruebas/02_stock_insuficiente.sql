/*
    ============================================================================
    PRUEBA 2 - CASO CON ERROR: stock insuficiente
    Se piden 10 unidades y hay menos. El error ocurre en el UPDATE, DESPUES de
    los dos INSERT, por la restriccion CHK_stock (stock >= 0).
    Precondicion : haber ejecutado la prueba 1 (stock_comp_1 = 3). Si no se
                   ejecuto, igual falla (5 - 10 < 0).
    Esperado     : ROLLBACK (error 547). El estado DESPUES es igual al ANTES.
    ============================================================================
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

PRINT '=== PRUEBA 2: stock insuficiente ===';

DECLARE @id_computadora INT = 1,
        @id_cliente     INT = 1,
        @id_usuario     INT = 2,
        @id_tipo_pago   INT = 1,
        @cantidad       INT = 10,
        @precio_unit    DECIMAL(10,2) = 3000000,
        @total          DECIMAL(10,2),
        @id_factura     INT;

SET @total = @cantidad * @precio_unit;

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Cabecera_Factura (fecha, total, id_cliente, id_tipo_pago, id_usuario)
    VALUES (CAST(GETDATE() AS DATE), @total, @id_cliente, @id_tipo_pago, @id_usuario);

    SET @id_factura = SCOPE_IDENTITY();

    INSERT INTO Detalle_Venta (cantidad, subtotal, id_cabecera_factura, id_computadora)
    VALUES (@cantidad, @total, @id_factura, @id_computadora);

    UPDATE Computadora                       -- el stock quedaria negativo: viola CHK_stock
    SET stock = stock - @cantidad
    WHERE id_computadora = @id_computadora;

    COMMIT TRANSACTION;
    PRINT 'RESULTADO: COMMIT. Venta confirmada.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'RESULTADO: ROLLBACK. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10))
          + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (debe ser igual al ANTES) ---';
SELECT (SELECT COUNT(*) FROM Cabecera_Factura)                    AS facturas,
       (SELECT COUNT(*) FROM Detalle_Venta)                       AS detalles,
       (SELECT stock FROM Computadora WHERE id_computadora = 1)   AS stock_comp_1,
       (SELECT stock FROM Computadora WHERE id_computadora = 2)   AS stock_comp_2;
GO