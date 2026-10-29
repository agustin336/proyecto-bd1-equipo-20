USE Venta_Computadoras;
GO

---------------------------------------------------------
-- 1. TIPO_USUARIO (3 Inserts, 2 Updates, Delete de los 3)
---------------------------------------------------------
INSERT INTO Tipo_Usuario (nombre_rol) VALUES ('RolTest1'), ('RolTest2'), ('RolTest3');

UPDATE Tipo_Usuario SET nombre_rol = 'RolTest1_Mod' WHERE nombre_rol = 'RolTest1';
UPDATE Tipo_Usuario SET nombre_rol = 'RolTest2_Mod' WHERE nombre_rol = 'RolTest2';

DELETE FROM Tipo_Usuario WHERE nombre_rol LIKE '%RolTest%';
GO


---------------------------------------------------------
-- 2. TIPO_PAGO (3 Inserts, 2 Updates, Delete de los 3)
---------------------------------------------------------
INSERT INTO Tipo_Pago (tipo) VALUES ('PagoTest1'), ('PagoTest2'), ('PagoTest3');

UPDATE Tipo_Pago SET tipo = 'PagoTest1_Mod' WHERE tipo = 'PagoTest1';
UPDATE Tipo_Pago SET tipo = 'PagoTest2_Mod' WHERE tipo = 'PagoTest2';

DELETE FROM Tipo_Pago WHERE tipo LIKE '%PagoTest%';
GO


---------------------------------------------------------
-- 3. USUARIO (3 Inserts, 2 Updates, Delete de los 3)
---------------------------------------------------------
-- Insertamos un rol temporal para el usuario
INSERT INTO Tipo_Usuario (nombre_rol) VALUES ('RolTempUser');

INSERT INTO Usuario (dni, nombre_usuario, contrasena, email, nombre, apellido, telefono_contacto, id_tipo_usuario) 
VALUES ('99999901', 'user1test', '1234', 'user1@test.com', 'Test1', 'User1', '3794111111', (SELECT TOP 1 id_tipo_usuario FROM Tipo_Usuario WHERE nombre_rol = 'RolTempUser')),
       ('99999902', 'user2test', '1234', 'user2@test.com', 'Test2', 'User2', '3794222222', (SELECT TOP 1 id_tipo_usuario FROM Tipo_Usuario WHERE nombre_rol = 'RolTempUser')),
       ('99999903', 'user3test', '1234', 'user3@test.com', 'Test3', 'User3', '3794333333', (SELECT TOP 1 id_tipo_usuario FROM Tipo_Usuario WHERE nombre_rol = 'RolTempUser'));

UPDATE Usuario SET nombre = 'Test1_Mod' WHERE dni = '99999901';
UPDATE Usuario SET nombre = 'Test2_Mod' WHERE dni = '99999902';

DELETE FROM Usuario WHERE dni LIKE '9999990%';
DELETE FROM Tipo_Usuario WHERE nombre_rol = 'RolTempUser';
GO


---------------------------------------------------------
-- 4. CLIENTE (3 Inserts, 2 Updates, Delete de los 3)
---------------------------------------------------------
INSERT INTO Cliente (email, nombre, apellido, dni, telefono_contacto) VALUES ('cli1@test.com', 'Cliente1', 'Test', '88888801', '3794444441');
INSERT INTO Cliente (email, nombre, apellido, dni, telefono_contacto) VALUES ('cli2@test.com', 'Cliente2', 'Test', '88888802', '3794444442');
INSERT INTO Cliente (email, nombre, apellido, dni, telefono_contacto) VALUES ('cli3@test.com', 'Cliente3', 'Test', '88888803', '3794444443');

UPDATE Cliente SET apellido = 'Test_Mod' WHERE dni = '88888801';
UPDATE Cliente SET apellido = 'Test_Mod' WHERE dni = '88888802';

DELETE FROM Cliente WHERE dni LIKE '8888880%';
GO


---------------------------------------------------------
-- 5. COMPUTADORA (3 Inserts, 2 Updates, Delete de los 3)
---------------------------------------------------------
-- Componentes base para la computadora
INSERT INTO Gabinete (altura, ancho, marca, modelo, RGB) VALUES (45.0, 20.0, 'TempC', 'G', 'Si');
INSERT INTO Almacenamiento (marca, velocidad_lectura, tamano_gb, tipo, modelo) VALUES ('TempC', 3500, 500, 'NVMe', 'S');
INSERT INTO RAM (tipo, cantidad_memoria, frecuencia, marca, RGB) VALUES ('DDR4', 16, 3200.0, 'TempC', 'Si');
INSERT INTO Procesador (marca, modelo, generacion, nucleos, velocidad) VALUES ('TempC', 'P', 12, 6, 3.50);
INSERT INTO Placa_Madre (modelo, RGB, marca) VALUES ('M', 'Si', 'TempC');
INSERT INTO Placa_Video (Cantidad_VRAM, Tipo_VRAM, Frecuencia_VRAM, Marca, Modelo, Anio) VALUES (16, 'GDDR7', 28.0, 'TempC', 'RTX 5070 Ti', 2025);
INSERT INTO Fuente_Poder (Modelo, Marca, potencia_W, RGB) VALUES (' MWE Gold V3', 'TempC', 750, 'No');

INSERT INTO Computadora (nombre, marca, tasa_refresco, refrigeracion, stock, id_gabinete, id_almacenamiento, id_RAM, id_procesador, id_placa_madre)
VALUES ('PcTest1', 'MarcaTest', 144.0, 'Liquida', 10, 
        (SELECT TOP 1 id_gabinete FROM Gabinete WHERE marca = 'TempC'),
        (SELECT TOP 1 id_almacenamiento FROM Almacenamiento WHERE marca = 'TempC'),
        (SELECT TOP 1 id_RAM FROM RAM WHERE marca = 'TempC'),
        (SELECT TOP 1 id_procesador FROM Procesador WHERE marca = 'TempC'),
        (SELECT TOP 1 id_placa_madre FROM Placa_Madre WHERE marca = 'TempC'));

INSERT INTO Computadora (nombre, marca, tasa_refresco, refrigeracion, stock, id_gabinete, id_almacenamiento, id_RAM, id_procesador, id_placa_madre)
VALUES ('PcTest2', 'MarcaTest', 60.0, 'Aire', 5, 
        (SELECT TOP 1 id_gabinete FROM Gabinete WHERE marca = 'TempC'),
        (SELECT TOP 1 id_almacenamiento FROM Almacenamiento WHERE marca = 'TempC'),
        (SELECT TOP 1 id_RAM FROM RAM WHERE marca = 'TempC'),
        (SELECT TOP 1 id_procesador FROM Procesador WHERE marca = 'TempC'),
        (SELECT TOP 1 id_placa_madre FROM Placa_Madre WHERE marca = 'TempC'));

INSERT INTO Computadora (nombre, marca, tasa_refresco, refrigeracion, stock, id_gabinete, id_almacenamiento, id_RAM, id_procesador, id_placa_madre)
VALUES ('PcTest3', 'MarcaTest', 240.0, 'Liquida', 2, 
        (SELECT TOP 1 id_gabinete FROM Gabinete WHERE marca = 'TempC'),
        (SELECT TOP 1 id_almacenamiento FROM Almacenamiento WHERE marca = 'TempC'),
        (SELECT TOP 1 id_RAM FROM RAM WHERE marca = 'TempC'),
        (SELECT TOP 1 id_procesador FROM Procesador WHERE marca = 'TempC'),
        (SELECT TOP 1 id_placa_madre FROM Placa_Madre WHERE marca = 'TempC'));

UPDATE Computadora SET stock = 15 WHERE nombre = 'PcTest1';
UPDATE Computadora SET stock = 8 WHERE nombre = 'PcTest2';

DELETE FROM Computadora WHERE marca = 'MarcaTest';
DELETE FROM Gabinete WHERE marca = 'TempC';
DELETE FROM Almacenamiento WHERE marca = 'TempC';
DELETE FROM RAM WHERE marca = 'TempC';
DELETE FROM Procesador WHERE marca = 'TempC';
DELETE FROM Placa_Madre WHERE marca = 'TempC';
DELETE FROM Placa_Video WHERE marca = 'TempC';
DELETE FROM Fuente_Poder WHERE marca = 'TempC';
GO

---------------------------------------------------------
-- 6. CABECERA DE VENTAS
---------------------------------------------------------
INSERT INTO Cabecera_Factura (fecha, total, id_cliente, id_tipo_pago, id_usuario)
VALUES ('2026-09-01', 1.00, 1, 1, 2);

UPDATE Cabecera_Factura SET total = 2.00 WHERE total = 1.00;

DELETE FROM Cabecera_Factura WHERE total = 2.00;
GO

---------------------------------------------------------
-- 7. DETALLES DE VENTA
---------------------------------------------------------
INSERT INTO Detalle_Venta (Cantidad, Subtotal, id_computadora, id_cabecera_factura)
VALUES (1, 1.00, 1, 1);

UPDATE Detalle_Venta SET subtotal = 2.00 WHERE subtotal = 1.00;

DELETE FROM Detalle_Venta WHERE subtotal = 2.00;
GO


---------------------------------------------------------
-- Tablas para ver el Funcionamiento de Triggers
---------------------------------------------------------
SELECT *
FROM tipo_usuario_auditoria;

SELECT * 
FROM usuario_auditoria;

SELECT * 
FROM cliente_auditoria;

SELECT * 
FROM tipo_pago_auditoria;

SELECT * 
FROM computadora_auditoria;

SELECT * 
FROM cabecera_factura_auditoria;

SELECT * 
FROM detalle_venta_auditoria;

SELECT * 
FROM gabinete_auditoria;

SELECT * 
FROM placa_video_auditoria;

SELECT * 
FROM almacenamiento_auditoria;

SELECT * 
FROM ram_auditoria;

SELECT * 
FROM fuente_poder_auditoria;

SELECT * 
FROM procesador_auditoria;

SELECT * 
FROM placa_madre_auditoria;
GO


