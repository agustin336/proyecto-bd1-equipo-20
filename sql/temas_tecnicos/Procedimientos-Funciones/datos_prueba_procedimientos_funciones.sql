USE Venta_Computadoras;
GO
-- Calcular el descuento de varios clientes
SELECT dbo.CalcularDescuento(1) AS Descuento;
SELECT dbo.CalcularDescuento(2) AS Descuento;
SELECT dbo.CalcularDescuento(3) AS Descuento;
GO

-- Ejecuta la función y muestra el importe total vendido.
SELECT dbo.calcularTotalVendido() AS total_Vendido;
GO

-- Ejecuta la función y muestra el stock total de las computadoras que coinciden con el parametro.
SELECT dbo.StockDisponible('1') AS StockTotal;
SELECT dbo.StockDisponible('2') AS StockTotal;
SELECT dbo.StockDisponible('3') AS StockTotal;
GO

-- Ejecutar el procedimiento almacenado para agregar una computadora.
EXEC dbo.agregarComputadora
    @Nombre = 'Notebook eden',
    @Marca = 'HP', 
    @tasa_refresco = 60,
    @Refrigeracion = 'Aire', 
    @Stock = 34, 
    @id_gabinete = NULL,
    @id_placa_video = NULL,
    @id_almacenamiento = 2,
    @id_RAM = 2,
    @id_fuente_poder = NULL,
    @id_procesador = 2,
    @id_placa_madre = 9;
GO

-- Ejecutar el procedimiento almacenado para eliminar una computadora.
EXEC dbo.quitarComputadora
    @id_computadora = 9;
GO

-- Ejecutar el procedimiento almacenado para actualizar el stock.
EXEC dbo.actualizarStock
    @id_computadora = 1,      
    @cantidad = 7;

EXEC dbo.actualizarStock
    @id_computadora = 7,      
    @cantidad = 4;
GO

-- Consultar todos los registros de la tabla Computadora y permite verificar los cambios realizados.
SELECT *FROM Computadora;
GO