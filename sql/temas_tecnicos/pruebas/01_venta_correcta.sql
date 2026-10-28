/* ============================================================================
   PRUEBA 1 - CASO CORRECTO: venta con stock suficiente
   Precondicion : base en estado inicial (facturas 8, detalles 8, stock_comp_1 5)
   Esperado     : COMMIT. facturas 8->9, detalles 8->9, stock_comp_1 5->3
   ============================================================================ */
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

PRINT '=== PRUEBA 1: venta correcta ===';

DECLARE @id_computadora INT = 1,
        @id_cliente     INT = 1,
        @id_usuario     INT = 2,
        @id_tipo_pago   INT = 1,
        @cantidad       INT = 2,
        @precio_unit    DECIMAL(10,2) = 3000000,
        @total          DECIMAL(10,2),
        @id_factura     INT;

SET @total = @cantidad * @precio_unit;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Paso 1: cabecera de la venta
    INSERT INTO Cabecera_Factura (fecha, total, id_cliente, id_tipo_pago, id_usuario)
    VALUES (CAST(GETDATE() AS DATE), @total, @id_cliente, @id_tipo_pago, @id_usuario);

    SET @id_factura = SCOPE_IDENTITY();

    -- Paso 2: detalle de la venta
    INSERT INTO Detalle_Venta (cantidad, subtotal, id_cabecera_factura, id_computadora)
    VALUES (@cantidad, @total, @id_factura, @id_computadora);

    -- Paso 3: descontar stock
    UPDATE Computadora
    SET stock = stock - @cantidad
    WHERE id_computadora = @id_computadora;

    COMMIT TRANSACTION;
    PRINT 'RESULTADO: COMMIT. Venta confirmada (factura '
          + CAST(@id_factura AS VARCHAR(10)) + ').';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'RESULTADO: ROLLBACK. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10))
          + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES ---';
SELECT (SELECT COUNT(*) FROM Cabecera_Factura)                    AS facturas,
       (SELECT COUNT(*) FROM Detalle_Venta)                       AS detalles,
       (SELECT stock FROM Computadora WHERE id_computadora = 1)   AS stock_comp_1,
       (SELECT stock FROM Computadora WHERE id_computadora = 2)   AS stock_comp_2;
GO