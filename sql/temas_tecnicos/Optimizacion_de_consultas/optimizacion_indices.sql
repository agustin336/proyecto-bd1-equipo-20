 USE Venta_Computadoras;

 
-- 1. Tabla de prueba
-- Misma estructura que Cabecera_Factura, pero sin PK ni FK.
-- Así queda sin índices y no tocamos los datos reales.
IF OBJECT_ID('dbo.Factura_Historica', 'U') IS NOT NULL
    DROP TABLE dbo.Factura_Historica;

 
CREATE TABLE dbo.Factura_Historica
(
    id_factura   BIGINT        IDENTITY(1,1) NOT NULL,
    fecha        DATE          NOT NULL,
    total        DECIMAL(10,2) NOT NULL,
    id_cliente   INT           NOT NULL,
    id_tipo_pago INT           NOT NULL,
    id_usuario   INT           NOT NULL
);

 
-- 2. Carga de 1.000.000 de filas
-- Los datos son al azar: fechas entre 2020-01-01 y 2024-12-29.
SET NOCOUNT ON;

 
WITH Numeros AS
(
    -- genera los números del 1 al 1.000.000
    SELECT TOP (1000000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_columns a
    CROSS JOIN sys.all_columns b
)
INSERT INTO dbo.Factura_Historica (fecha, total, id_cliente, id_tipo_pago, id_usuario)
SELECT
    DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 1825), CAST('2020-01-01' AS DATE)),
    CAST(100000 + ABS(CHECKSUM(NEWID()) % 900000) AS DECIMAL(10,2)),
    1 + ABS(CHECKSUM(NEWID()) % 200),
    1 + ABS(CHECKSUM(NEWID()) % 4),
    1 + ABS(CHECKSUM(NEWID()) % 10)
FROM Numeros;

 
-- Chequeo: tiene que dar 1000000
SELECT COUNT(*) AS CantidadRegistros
FROM dbo.Factura_Historica;

 
-- Espacio de la tabla sin índices
EXEC sp_spaceused 'dbo.Factura_Historica';

 
-- 3. Consulta SIN índice
-- Activar el plan de ejecución real (Ctrl+M) antes de correrla.
-- CHECKPOINT y DROPCLEANBUFFERS vacían la caché, para que cada
-- prueba arranque igual (solo usar en pruebas).
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

 
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
GO
 
SELECT id_factura, fecha, total
FROM dbo.Factura_Historica
WHERE fecha BETWEEN '2023-01-01' AND '2023-03-31';

 
-- 4. Índice agrupado sobre fecha
CREATE CLUSTERED INDEX IX_Factura_Historica_fecha
ON dbo.Factura_Historica (fecha);

 
EXEC sp_spaceused 'dbo.Factura_Historica';

 
CHECKPOINT;
DBCC DROPCLEANBUFFERS;

 
-- Misma consulta de antes
SELECT id_factura, fecha, total
FROM dbo.Factura_Historica
WHERE fecha BETWEEN '2023-01-01' AND '2023-03-31';

 
-- 5. Borrar el índice
DROP INDEX IX_Factura_Historica_fecha
ON dbo.Factura_Historica;

 
-- 6. Índice no agrupado con INCLUDE
-- La clave es fecha; id_factura y total van incluidos porque son
-- las otras dos columnas del SELECT. INCLUDE solo se puede usar
-- en índices no agrupados.
CREATE NONCLUSTERED INDEX IX_Factura_Historica_fecha_cobertura
ON dbo.Factura_Historica (fecha)
INCLUDE (id_factura, total);

 
EXEC sp_spaceused 'dbo.Factura_Historica';

 
CHECKPOINT;
DBCC DROPCLEANBUFFERS;

 
-- Misma consulta otra vez
SELECT id_factura, fecha, total
FROM dbo.Factura_Historica
WHERE fecha BETWEEN '2023-01-01' AND '2023-03-31';

 
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

 
-- Para borrar la tabla de prueba cuando terminemos:
-- DROP TABLE dbo.Factura_Historica;

 


