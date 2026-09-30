USE Venta_Computadoras;
GO
-- ------------------------------------------------------------
-- Tipo_usuario
-- ------------------------------------------------------------

INSERT INTO Tipo_Usuario (nombre_rol)
VALUES
('Administrador'),
('Vendedor'),
('Supervisor');
-- ------------------------------------------------------------
-- USUARIO
-- ------------------------------------------------------------

INSERT INTO Usuario (dni, nombre_usuario, contrasena, Email, Nombre, Apellido, telefono_contacto, id_tipo_usuario)
VALUES
    ('40111222','admin1','A342k34f3','admin01@empresa.com','Juan','Perez','3794945433',1),
    ('40222333','vendedor1','Da44e02','vendedor01@empresa.com','Carlos','Torrez','3795064702',2),
    ('40333444','vendedor2','Cl4v303','vendedor2@empresa.com','Carlos','Lopez','3794106663',2),
    ('40444555','vendedor3','Glgve04','vendedor03@empresa.com','Lusiana','Diaz','3794604734',2),
    ('40555666','vendedor4','cBlaRe05','vendedor04@empresa.com','Lucas','Ruiz','3794107055',2),
    ('40666777','supervisor1','c4avh06','supervisor01@empresa.com','Sofia','Torres','3795250406',3),
    ('40777888','supervisor2','\lawg07','supervisor02@empresa.com','Diego','Sosa','3794756047',3),
    ('40888999','supervisor3','cDavf08','supervisor301@empresa.com','Laura','Acosta','3795604052',3);


-- ------------------------------------------------------------
-- CLIENTE
-- ------------------------------------------------------------

INSERT INTO Cliente (Email, Nombre, Apellido, DNI, Telefono_Contacto)
VALUES
('martingarcia65@gmail.com', 'Martin', 'Garcia', '30151222', '3794905411'),
('soledadfernandez564@gmail.com', 'Soledad', 'Fernandez', '45222333', '3795060702'),
('facundomart65@gmail.com', 'Facundo', 'Martinez', '31333444', '3794106703'),
('valentinaromero12@outlook.com', 'Valentina', 'Romero', '35444555', '3794604704'),
('nicolassanchez666@outlook.com', 'Nicolas', 'Sanchez', '32555666', '3794107005'),
('camilaalvarez545@gmail.com', 'Camila', 'Alvarez', '46666777', '3795250006'),
('agustinruiz758@outlook.com', 'Agustin', 'Ruiz', '25777888', '3794706007'),
('florencia765@outlook.com', 'Florencia', 'Acosta', '45888999', '3795603008');


-- ------------------------------------------------------------
-- GABINETE
-- ------------------------------------------------------------

INSERT INTO Gabinete (Altura, Ancho, Marca, Modelo, RGB)
VALUES
(45.0, 20.0, 'Corsair', '4000D', 'Si'),
(25.0, 59.0, 'Asus', 'GX601S', 'Si'),
(43.0, 20.0, 'Cooler Master', 'TD500', 'Si'),
(46.0, 21.0, 'Thermaltake', 'View 270', 'Si'),
(44.0, 20.0, 'DeepCool', 'CC560', 'No'),
(47.0, 22.0, 'Lian Li', 'Lancool 216', 'Si'),
(42.0, 19.0, 'MSI', 'MAG Forge', 'Si'),
(45.0, 21.0, 'HYTE', 'Y70', 'Si');

-- ------------------------------------------------------------
-- PLACA_VIDEO
-- ------------------------------------------------------------

INSERT INTO Placa_Video (Cantidad_VRAM, Tipo_VRAM, Frecuencia_VRAM, Marca, Modelo, Anio)
VALUES
(16, 'GDDR7', 28.0, 'NVIDIA', 'RTX 5070 Ti', 2025),
(12, 'GDDR7', 28.0, 'NVIDIA', 'RTX 5070', 2025),
(16, 'GDDR6', 20.0, 'AMD', 'RX 9070 XT', 2025),
(16, 'GDDR6', 20.0, 'AMD', 'RX 9070', 2025),
(32, 'GDDR7', 21.0, 'NVIDIA', 'RTX 5090', 2025),
(12, 'GDDR6X', 21.0, 'NVIDIA', 'RTX 4070 Super', 2024),
(16, 'GDDR6', 19.5, 'AMD', 'RX 7800 XT', 2023),
(12, 'GDDR6', 18.0, 'AMD', 'RX 7700 XT', 2023);

-- ------------------------------------------------------------
-- ALMACENAMIENTO
-- ------------------------------------------------------------

INSERT INTO Almacenamiento (Marca, Velocidad_Lectura, tamano_gb, Tipo, Modelo)
VALUES
('Samsung', 7450, 1000, 'SSD NVMe', '990 Pro'),
('Adata', 7400, 2000, 'SSD NVMe', 'Legend 900 PRO'),
('Kingston', 6000, 1000, 'SSD NVMe', 'NV3'),
('Crucial', 5000, 1000, 'SSD NVMe', 'P3 Plus'),
('Samsung', 7450, 2000, 'SSD NVMe', '990 Pro'),
('Western Digital', 5150, 2000, 'SSD NVMe', 'Blue SN580'),
('Kingston', 3500, 2000, 'SSD NVMe', 'NV2'),
('Crucial', 560, 1000, 'SSD SATA', 'MX500');

-- ------------------------------------------------------------
-- PROCESADOR
-- ------------------------------------------------------------

INSERT INTO Procesador (Marca, Modelo, Generacion, nucleos, Velocidad)
VALUES
('AMD', 'Ryzen 3 3200G', 3, 4, 3.6),
('AMD', 'Ryzen 5 9600X', 9, 6, 3.9),
('AMD', 'Ryzen 9 9900X', 9, 12, 4.4),
('Intel', 'Core i7-14700K', 14, 20, 3.4),
('Intel', 'Core i5-14600K', 14, 14, 3.5),
('Intel', 'Core i9-14900K', 14, 24, 3.2),
('AMD', 'Ryzen 7 7800X3D', 7, 8, 4.2),
('AMD', 'Ryzen 5 40', 7, 4, 4.3);


-- ------------------------------------------------------------
-- FUENTE_PODER
-- ------------------------------------------------------------

INSERT INTO Fuente_Poder (Modelo, Marca, potencia_W, RGB)
VALUES
(' MWE Gold V3', 'Cooler Master', 750, 'No'),
('RM1000e', 'Corsair', 1000, 'No'),
('ROG Thor 3 Titanium III ', 'ASUS', 1600, 'No'),
('Gold Steel Legend', 'Asrock', 750, 'No'),
('MAG A850GL', 'MSI', 850, 'No'),
('MAG A1000GL', 'MSI', 1000, 'No'),
('Cybenetics Gold RM750e', 'Corsair ', 750, 'No'),
('Straight Power 12 1000W', 'Be Quiet', 1000, 'No');


-- ------------------------------------------------------------
-- PLACA_MADRE
-- ------------------------------------------------------------

INSERT INTO Placa_Madre (Modelo, Marca, RGB)
VALUES
('B650 Tomahawk', 'MSI', 'Si'),
('X670E Aorus Elite', 'Gigabyte', 'Si'),
('B650 Gaming X AX', 'Gigabyte', 'Si'),
('ROG Strix B650E-F', 'ASUS', 'Si'),
('MAG B650M Mortar', 'MSI', 'Si'),
('TUF Gaming B650-Plus', 'ASUS', 'Si'),
('B650 Steel Legend', 'ASRock', 'Si'),
('X870 Gaming Plus', 'MSI', 'Si'),
('Placa madre integrada', 'Fabricante', 'No');


-- ------------------------------------------------------------
-- RAM
-- ------------------------------------------------------------

INSERT INTO RAM (Tipo, Cantidad_Memoria, Frecuencia, Marca, RGB)
VALUES
('DDR5', 16, 6000, 'Patriot', 'No'),
('DDR4', 32, 3200, 'Team', 'No'),
('DDR5', 64, 6000, 'G.Skill', 'Si'),
('DDR5', 32, 5600, 'Crucial', 'No'),
('DDR4', 32, 3200, 'Corsair', 'No'),
('DDR5', 32, 6400, 'G.Skill', 'Si'),
('DDR5', 64, 6000, 'Kingston', 'Si'),
('DDR4', 32, 3200, 'ADATA', 'Si');

-- ------------------------------------------------------------
-- TIPO_PAGO
-- ------------------------------------------------------------

INSERT INTO Tipo_Pago (Tipo)
VALUES
('Efectivo'),
('Tarjeta de Debito'),
('Tarjeta de Credito'),
('Transferencia'),
('Deposito'),
('Uala'),
('Mercado Pago'),
('ARQ');

-- ------------------------------------------------------------
-- COMPUTADORA
-- ------------------------------------------------------------

INSERT INTO Computadora (Nombre, Marca, tasa_refresco, Refrigeracion, Stock, id_gabinete, id_placa_video, id_almacenamiento, id_RAM, id_fuente_poder, id_procesador, id_placa_madre)
VALUES
    ('GP162', 'Armada', 60, 'Liquida', 5, 1, 1, 1, 1, 1, 1, 1),
    ('Notebook Omnibook 3', 'HP', 60, 'Aire', 14,NULL,NULL, 2,2,NULL, 2, 9),
    ('HP All In One 24', 'HP', 100 , 'Aire', 22, NULL, NULL, 3, 3, NULL, 8, 9),
    ('GP607', 'Armada', 144, 'Aire', 10, 4, 4, 4, 4, 3, 4, 4),
    ('GP608', 'Armada', 144, 'Aire', 7,  5, 5, 5, 5, 4, 5, 5),
    ('GP632', 'Armada', 180, 'Liquida', 9, 6, 6, 6, 6, 4, 6, 6),
    ('GP695', 'Armada', 144, 'Aire', 8, 7, 7, 7, 7, 5, 7, 7),
    ('GP697', 'Armada', 144, 'Liquida', 15, 8, 8, 8, 8, 6, 8, 8);

-- ------------------------------------------------------------
-- CABECERA_VENTA
-- ------------------------------------------------------------

INSERT INTO Cabecera_Factura (fecha, total, id_cliente, id_tipo_pago, id_usuario)
VALUES
    ('2026-09-01', 3240670.00, 1, 1, 2),
    ('2026-09-03', 2530450.00, 2, 2, 2),
    ('2026-09-05', 3100600.00, 3, 3, 3),
    ('2026-09-08', 2700500.00, 4, 4, 4),
    ('2026-09-10', 2900050.00, 5, 5, 2),
    ('2026-09-12', 2407060.00, 6, 1, 5),
    ('2026-09-17', 2307030.00, 7, 6, 3),
    ('2026-09-22', 2205060.00, 8, 3, 2);


-- ------------------------------------------------------------
-- DETALLE_VENTA
-- ------------------------------------------------------------

INSERT INTO Detalle_Venta (Cantidad, Subtotal, id_computadora, id_cabecera_factura)
VALUES
    (1, 3240670.00, 1, 1),
    (1, 2530450.00, 2, 2),
    (1, 3100600.00, 3, 3),
    (1, 2700500.00, 4, 4),
    (1, 2900050.00, 5, 5),
    (1, 2407060.00, 6, 6),
    (1, 2307030.00, 7, 7),
    (1, 2205060.00, 8, 8);