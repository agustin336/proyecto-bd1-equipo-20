USE Venta_Computadoras;
GO

CREATE TRIGGER trigger_evitar_borrado_usuario_mensaje
ON Usuario
INSTEAD OF DELETE -- en lugar de delete, eso significa
AS
BEGIN
    -- Evita mensajes innecesarios de conteo de filas
    SET NOCOUNT ON;

    -- este es la instruccion para generar un mensaje un mensaje, parametros (mensaje, severidad (16 es el standar), linea de error (1 es estandar))
    RAISERROR('Acción denegada: No está permitido eliminar registros de la tabla Usuario por politica de la Compañia.', 16, 1);
    
    -- Revierte/cancela cualquier intento de transacción asociada, es necesario porque el motor de base de datos toma cualquier DELETE, INSERT o UPDATE
    -- como una transaccion, esta implicita, y por ende hacemos rollback para cerrar esa transaccion y no quede basura en el motor
    ROLLBACK TRANSACTION;
END;
GO

--------------------------------------------------
--PRUEBA
--------------------------------------------------
DELETE FROM Usuario WHERE id_usuario = 1;