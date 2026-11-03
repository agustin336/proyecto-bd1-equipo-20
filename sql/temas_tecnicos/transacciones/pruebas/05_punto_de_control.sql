/*
    ===========================================================================
    PRUEBA 5 - PUNTO DE CONTROL (SAVE TRANSACTION): rollback parcial
    Venta con un primer item (computadora 1). Se agrega un segundo item
    (computadora 2) y el cliente lo descarta: solo se deshace ese segundo item.
    Esperado (cambios respecto del ANTES): facturas +1, detalles +1,
    stock_comp_1 -1, stock_comp_2 SIN cambios, total de la factura = 3000000.
    ===========================================================================
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

PRINT '=== PRUEBA 5: rollback parcial con SAVE TRANSACTION ===';

DECLARE @id_factura INT;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Primer item (se conserva)
    INSERT INTO Cabecera_Factura (fecha, total, id_cliente, id_tipo_pago, id_usuario)
    VALUES (CAST(GETDATE() AS DATE), 3000000, 3, 3, 3);
    SET @id_factura = SCOPE_IDENTITY();

    INSERT INTO Detalle_Venta (cantidad, subtotal, id_cabecera_factura, id_computadora)
    VALUES (1, 3000000, @id_factura, 1);

    UPDATE Computadora SET stock = stock - 1 WHERE id_computadora = 1;

    SAVE TRANSACTION antes_segundo_item;                 -- punto de control

    -- Segundo item (se va a descartar)
    INSERT INTO Detalle_Venta (cantidad, subtotal, id_cabecera_factura, id_computadora)
    VALUES (1, 2500000, @id_factura, 2);

    UPDATE Computadora SET stock = stock - 1 WHERE id_computadora = 2;

    UPDATE Cabecera_Factura SET total = total + 2500000
    WHERE id_cabecera_factura = @id_factura;

    -- El cliente descarta el segundo equipo: se deshace solo hasta el punto de control
    ROLLBACK TRANSACTION antes_segundo_item;

    COMMIT TRANSACTION;                                  -- confirma solo el primer item
    PRINT 'RESULTADO: COMMIT parcial. Factura ' + CAST(@id_factura AS VARCHAR(10))
          + ' con un unico item.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES ---';
SELECT (SELECT COUNT(*) FROM Cabecera_Factura)                    AS facturas,
       (SELECT COUNT(*) FROM Detalle_Venta)                       AS detalles,
       (SELECT stock FROM Computadora WHERE id_computadora = 1)   AS stock_comp_1,
       (SELECT stock FROM Computadora WHERE id_computadora = 2)   AS stock_comp_2;

-- Contenido de la ultima factura (debe tener un solo item y total 3000000)
SELECT cf.id_cabecera_factura, cf.total, dv.id_computadora, dv.subtotal
FROM Cabecera_Factura cf
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
WHERE cf.id_cabecera_factura = (SELECT MAX(id_cabecera_factura) FROM Cabecera_Factura);
GO