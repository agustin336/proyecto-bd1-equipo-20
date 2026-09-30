-- Comprueba/crea la misma base de datos y separa en batches
IF DB_ID(N'Venta_Computadoras') IS NULL
BEGIN
    CREATE DATABASE Venta_Computadoras;
END
GO

USE Venta_Computadoras;
GO

CREATE TABLE Tipo_usuario
(
  id_tipo_usuario INT IDENTITY(1,1) NOT NULL,
  nombre_rol VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_tipo_usuario PRIMARY KEY (id_tipo_usuario)
);

CREATE TABLE Usuario
(
  id_usuario INT IDENTITY(1,1) NOT NULL,
  dni CHAR(8)  NOT NULL,
  nombre_usuario VARCHAR(100) NOT NULL,
  contrasena VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  telefono_contacto VARCHAR(16) NOT NULL,
  id_tipo_usuario INT NOT NULL,
  CONSTRAINT PK_id_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT FK_id_tipo_usuario FOREIGN KEY (id_tipo_usuario) REFERENCES Tipo_usuario(id_tipo_usuario),
  CONSTRAINT UQ_dni_usuario UNIQUE (dni),
  CONSTRAINT UQ_nombre_usuario UNIQUE (nombre_usuario),
  CONSTRAINT CHK_dni_usuario CHECK (LEN(dni) = 8 AND dni NOT LIKE '%[^0-9]%' )
);

CREATE TABLE Cliente
(
  id_cliente INT IDENTITY(1,1) NOT NULL,
  email VARCHAR(100) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  dni CHAR(8) NOT NULL,
  telefono_contacto VARCHAR(16) NOT NULL,
  CONSTRAINT PK_id_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT UQ_email UNIQUE (email),
  CONSTRAINT UQ_dni_cliente UNIQUE (dni),
  CONSTRAINT CHK_dni_cliente CHECK (LEN(dni) = 8 AND dni NOT LIKE '%[^0-9]%' )
);

CREATE TABLE Tipo_Pago
(
  id_tipo_pago INT IDENTITY(1,1) NOT NULL,
  tipo VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_tipo_pago PRIMARY KEY (id_tipo_pago)
);

CREATE TABLE Cabecera_Factura
(
  id_cabecera_factura INT IDENTITY(1,1) NOT NULL,
  fecha DATE NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  id_cliente INT NOT NULL,
  id_tipo_pago INT NOT NULL,
  id_usuario INT NOT NULL,
  CONSTRAINT PK_id_cabecera_factura PRIMARY KEY (id_cabecera_factura),
  CONSTRAINT FK_id_cliente FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
  CONSTRAINT FK_id_tipo_pago FOREIGN KEY (id_tipo_pago) REFERENCES Tipo_Pago(id_tipo_pago),
  CONSTRAINT FK_id_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
  CONSTRAINT CHK_total CHECK (total > 0)
);

CREATE TABLE Gabinete
(
  id_gabinete INT IDENTITY(1,1) NOT NULL,
  altura FLOAT NOT NULL,
  ancho FLOAT NOT NULL,
  marca VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  RGB VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_gabinete PRIMARY KEY (id_gabinete),
  CONSTRAINT CHK_altura CHECK (altura > 0),
  CONSTRAINT CHK_ancho CHECK (ancho > 0)
);

CREATE TABLE Placa_Video
(
  id_placa_video INT IDENTITY(1,1) NOT NULL,
  cantidad_VRAM INT NOT NULL,
  tipo_VRAM VARCHAR(100) NOT NULL,
  frecuencia_VRAM FLOAT NOT NULL,
  marca VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  anio SMALLINT NOT NULL,
  CONSTRAINT PK_id_placa_video PRIMARY KEY (id_placa_video),
  CONSTRAINT CHK_cantidad_VRAM CHECK (cantidad_VRAM > 0),
  CONSTRAINT CHK_anio CHECK (anio > 0)
);

CREATE TABLE Almacenamiento
(
  id_almacenamiento INT IDENTITY(1,1) NOT NULL,
  marca VARCHAR(100) NOT NULL,
  velocidad_lectura INT NOT NULL,
  tamano_gb INT NOT NULL,
  tipo VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_almacenamiento PRIMARY KEY (id_almacenamiento),
  CONSTRAINT CHK_velocidad_lectura CHECK (velocidad_lectura > 0)
);

CREATE TABLE RAM
(
  id_RAM INT IDENTITY(1,1) NOT NULL,
  tipo VARCHAR(100) NOT NULL,
  cantidad_memoria INT NOT NULL,
  frecuencia FLOAT NOT NULL,
  marca VARCHAR(100) NOT NULL,
  RGB VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_RAM PRIMARY KEY (id_RAM),
  CONSTRAINT CHK_cantidad_memoria CHECK (cantidad_memoria > 0),
  CONSTRAINT CHK_frecuencia CHECK (frecuencia > 0)
);

CREATE TABLE Fuente_Poder
(
  id_fuente_poder INT IDENTITY(1,1) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  frecuencia_W FLOAT NOT NULL,
  RGB VARCHAR(100) NOT NULL,
  marca VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_fuente_poder PRIMARY KEY (id_fuente_poder),
  CONSTRAINT CHK_frecuancia_W CHECK (frecuencia_W > 0)
);

CREATE TABLE Procesador
(
  id_procesador INT IDENTITY(1,1) NOT NULL,
  marca VARCHAR(100) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  generacion SMALLINT NOT NULL,
  nucleos SMALLINT NOT NULL,
  velocidad DECIMAL(5,2) NOT NULL,
  CONSTRAINT PK_id_procesador PRIMARY KEY (id_procesador),
  CONSTRAINT CHK_generacion CHECK (generacion > 0),
  CONSTRAINT CHK_nucleos CHECK (nucleos > 0)
);

CREATE TABLE Placa_Madre
(
  id_placa_madre INT IDENTITY(1,1) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  RGB VARCHAR(100) NOT NULL,
  marca VARCHAR(100) NOT NULL,
  CONSTRAINT PK_id_placa_madre PRIMARY KEY (id_placa_madre)
);

CREATE TABLE Computadora
(
  id_computadora INT IDENTITY(1,1) NOT NULL,
  nombre VARCHAR(100),
  marca VARCHAR(100),
  tasa_refresco FLOAT,
  refrigeracion VARCHAR(100) NOT NULL,
  stock INT NOT NULL,
  id_gabinete INT NOT NULL,
  id_placa_video INT NOT NULL,
  id_almacenamiento INT NOT NULL,
  id_RAM INT NOT NULL,
  id_fuente_poder INT NOT NULL,
  id_procesador INT NOT NULL,
  id_placa_madre INT NOT NULL,
  CONSTRAINT PK_id_computadora PRIMARY KEY (id_computadora),
  CONSTRAINT FK_id_gabinete FOREIGN KEY (id_gabinete) REFERENCES Gabinete(id_gabinete),
  CONSTRAINT FK_id_placa_video FOREIGN KEY (id_placa_video) REFERENCES Placa_Video(id_placa_video),
  CONSTRAINT FK_id_almacenamiento FOREIGN KEY (id_almacenamiento) REFERENCES Almacenamiento(id_almacenamiento),
  CONSTRAINT FK_id_RAM FOREIGN KEY (id_RAM) REFERENCES RAM(id_RAM),
  CONSTRAINT FK_id_fuente_poder FOREIGN KEY (id_fuente_poder) REFERENCES Fuente_Poder(id_fuente_poder),
  CONSTRAINT FK_id_procesador FOREIGN KEY (id_procesador) REFERENCES Procesador(id_procesador),
  CONSTRAINT FK_id_placa_madre FOREIGN KEY (id_placa_madre) REFERENCES Placa_Madre(id_placa_madre),
  CONSTRAINT CHK_stock CHECK (stock >= 0),
  CONSTRAINT CHK_tasa_refresco CHECK (tasa_refresco > 0)
);

CREATE TABLE Detalle_Venta
(
  id_detalle_venta INT IDENTITY(1,1) NOT NULL,
  cantidad INT NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  id_cabecera_factura INT NOT NULL,
  id_computadora INT NOT NULL,
  CONSTRAINT PK_id_detalle_venta PRIMARY KEY (id_detalle_venta),
  CONSTRAINT FK_id_cabecera_factura FOREIGN KEY (id_cabecera_factura) REFERENCES Cabecera_Factura(id_cabecera_factura),
  CONSTRAINT FK_id_computadora FOREIGN KEY (id_computadora) REFERENCES Computadora(id_computadora),
  CONSTRAINT CHK_cantidad CHECK (cantidad > 0),
  CONSTRAINT CHK_subtotal CHECK (subtotal > 0)
);
