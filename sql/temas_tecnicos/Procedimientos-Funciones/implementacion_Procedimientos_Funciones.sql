USE Venta_Computadoras;
GO
/* ============================================================
   FUNCION: CalcularDescuento
   Calcula un descuento según el total de las facturas acumuladas por un cliente.
   ============================================================ */

CREATE FUNCTION dbo.CalcularDescuento(@id_cliente INT)
RETURNS DECIMAL(10,2) AS BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = SUM(total)
    FROM Cabecera_Factura
    WHERE id_cliente = @id_cliente;

    IF (@total >= 3000000)
        RETURN (@total * 0.15);

    ELSE IF (@total >= 2500000)
        RETURN (@total * 0.10);

    RETURN 0;
END;
GO

/* ============================================================
   FUNCION: calcularTotalVendido
   Calcula la suma de los totales de todas las facturas.
   ============================================================ */

CREATE FUNCTION dbo.calcularTotalVendido()
RETURNS DECIMAL(10,2) AS BEGIN
    RETURN(
        SELECT SUM(total)
        FROM Cabecera_Factura
    );
END;
GO

/* ============================================================
   FUNCION: StockDisponible
   Calcula el stock total de las computadoras que coinciden con un nombre.
   ============================================================ */
   
CREATE FUNCTION dbo.StockDisponible(@id_computadora INT)
RETURNS INT AS BEGIN
    RETURN ISNULL((
    SELECT stock
    FROM Computadora
    WHERE id_computadora = @id_computadora
    ),0);
END; 
GO

/* ============================================================
   PROCEDIMIENTO: agregarComputadora
   Insertar una computadora nueva en la tabla
   Computadora y mostrar los datos del registro insertado.
   ============================================================ */

CREATE PROCEDURE dbo.agregarComputadora(@Nombre VARCHAR(100),@Marca VARCHAR(100),@tasa_refresco FLOAT,@Refrigeracion VARCHAR(100),@Stock INT,@id_gabinete INT,@id_placa_video INT,@id_almacenamiento INT,@id_RAM INT, @id_fuente_poder INT,@id_procesador INT,@id_placa_madre INT)
AS BEGIN
    -- Evita mostrar mensajes sobre la cantidad de filas afectadas.
    SET NOCOUNT ON;

    -- Configura el comportamiento ante determinados errores.
    SET XACT_ABORT ON;

    -- Variable para almacenar el ID de la computadora insertada.
    DECLARE @id_computadora INT;

    -- Validar que el stock no sea negativo.
    -- THROW genera un error y detiene la ejecución si la condición se cumple.
    IF @Stock < 0
        THROW 50001, 'El stock no puede ser negativo.', 1;

    -- Insertar la computadora con los datos recibidos por parámetros.
    INSERT INTO computadora(Nombre,Marca,tasa_refresco,Refrigeracion,Stock,id_gabinete,id_placa_video,id_almacenamiento,id_RAM, id_fuente_poder,id_procesador,id_placa_madre)
    VALUES
        (@Nombre, @Marca, @tasa_refresco, @Refrigeracion, @Stock, @id_gabinete, @id_placa_video, @id_almacenamiento, @id_RAM, @id_fuente_poder, @id_procesador, @id_placa_madre);

    -- Obtener el ID generado automáticamente por IDENTITY.
    SET @id_computadora = SCOPE_IDENTITY();

    -- Mostrar los datos de la computadora recién insertada.
    SELECT *
    FROM Computadora
    WHERE id_computadora = @id_computadora;
END;
GO


/* ============================================================
 PROCEDIMIENTO: quitarComputadora
 Eliminar una computadora a partir de su ID.
   ============================================================ */

CREATE PROCEDURE dbo.quitarComputadora(@id_computadora INT)
AS BEGIN
    -- Evita mostrar mensajes sobre la cantidad de filas afectadas.
    SET NOCOUNT ON;

    -- Comprobar si existe una computadora con el ID recibido.
    IF NOT EXISTS
    (
        SELECT 1
        FROM Computadora
        WHERE id_computadora = @id_computadora
    )
        -- Si no existe, generar un error y detener la ejecución.
        THROW 50002, 'La computadora no existe.', 1;

    -- Eliminar la computadora cuyo ID coincide con el parámetro.
    DELETE FROM Computadora
    WHERE id_computadora = @id_computadora;

    -- Mostrar un mensaje de confirmación.
    PRINT 'Computadora eliminada correctamente.';
END;
GO

/* ============================================================
 PROCEDIMIENTO: actualizarStock
 Aumentar el stock de una computadora existente.
   ============================================================ */

CREATE PROCEDURE dbo.actualizarStock(@id_computadora INT,@cantidad INT)
AS BEGIN
    -- Evita mostrar mensajes sobre la cantidad de filas afectadas.
    SET NOCOUNT ON;

    -- Configura el comportamiento ante determinados errores.
    SET XACT_ABORT ON;

    -- Validar que la cantidad que se desea agregar sea positiva.
    IF @cantidad <= 0
        THROW 50003, 'La cantidad debe ser mayor a cero.', 1;

    -- Aumentar el stock de la computadora indicada.
    UPDATE Computadora
    SET Stock = Stock + @cantidad
    WHERE id_computadora = @id_computadora;

    -- Comprobar si se modificó alguna fila.
    -- Si no se modificó ninguna, el ID no corresponde a una computadora.
    IF @@ROWCOUNT = 0
        THROW 50004, 'La computadora no existe.', 1;
    -- Informar que la operación fue exitosa.
    PRINT 'El stock se actualizó correctamente.';
END;
GO