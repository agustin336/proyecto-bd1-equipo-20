/*
    ===============================================================================
    PRUEBA 3 - ERROR INTENCIONAL provocado luego de los INSERT (consigna)
    Se lanza un error con THROW despues de los dos INSERT y antes del UPDATE.
    Esperado : ROLLBACK (error 50001). No queda ningun INSERT y el stock no cambia.
               El estado DESPUES es igual al ANTES.
    ===============================================================================
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

PRINT '=== PRUEBA 3: error intencional despues de los INSERT ===';

DECLARE @id_computadora INT = 1,
        @id_cliente     INT = 1,
        @id_usuario     INT = 2,
        @id_tipo_pago   INT = 1,
        @cantidad       INT = 1,
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

    -- Error provocado a proposito: el UPDATE de abajo nunca se ejecuta
    THROW 50001, 'Error intencional provocado despues de los INSERT.', 1;

    UPDATE Computadora
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