/*
    =============================================================================
    TRANSACCION DE VENTA (implementacion)
    Registra una venta de forma atomica: cabecera + detalle + descuento de stock.
    USO: editar solo el bloque PARAMETROS y ejecutar.
    Los casos de prueba estan en la carpeta pruebas/.
    =============================================================================
*/

USE Venta_Computadoras;
GO

SET XACT_ABORT ON;
GO

-- ------------------------------ PARAMETROS ---------------------------------
DECLARE @id_cliente     INT           = 1,
        @id_usuario     INT           = 2,
        @id_tipo_pago   INT           = 1,
        @id_computadora INT           = 1,
        @cantidad       INT           = 2,
        @precio_unit    DECIMAL(10,2) = 3000000;
-- ---------------------------------------------------------------------------

DECLARE @total      DECIMAL(10,2),
        @id_factura INT;

-- CHK_total exige total > 0
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

    -- Paso 3: descontar stock (CHK_stock impide dejarlo negativo)
    UPDATE Computadora
    SET stock = stock - @cantidad
    WHERE id_computadora = @id_computadora;

    COMMIT TRANSACTION;
    PRINT 'COMMIT. Venta confirmada (factura ' + CAST(@id_factura AS VARCHAR(10)) + ').';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'ROLLBACK. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO