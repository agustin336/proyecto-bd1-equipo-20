USE Venta_Computadoras;
GO

--Aqui creo las tablas de auditoria donde guardare toda la info. que cambie o se elimine
--es decir, la que registre de los triggers

CREATE TABLE tipo_usuario_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_tipo_usuario INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    nombre_rol_anterior VARCHAR(100) NULL,
    nombre_rol_nuevo VARCHAR(100) NULL
);
GO

CREATE TABLE usuario_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_usuario INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    nombre_usuario_anterior VARCHAR(100),
    contrasena_anterior VARCHAR(100),
    email_anterior VARCHAR(100),
    nombre_anterior VARCHAR(100),
    apellido_anterior VARCHAR(100),
    telefono_contacto_anterior VARCHAR(16),
    id_tipo_usuario_anterior INT,
    nombre_usuario_nuevo VARCHAR(100),
    contrasena_nuevo VARCHAR(100),
    email_nuevo VARCHAR(100),
    nombre_nuevo VARCHAR(100),
    apellido_nuevo VARCHAR(100),
    telefono_contacto_nuevo VARCHAR(16),
    id_tipo_usuario_nuevo INT
);
GO

CREATE TABLE cliente_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_cliente INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    email_anterior VARCHAR(100),
    nombre_anterior VARCHAR(100),
    apellido_anterior VARCHAR(100),
    telefono_contacto_anterior VARCHAR(16),
    email_nuevo VARCHAR(100),
    nombre_nuevo VARCHAR(100),
    apellido_nuevo VARCHAR(100),
    telefono_contacto_nuevo VARCHAR(16)
);
GO

CREATE TABLE tipo_pago_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_tipo_pago INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    tipo_anterior VARCHAR(100),
    tipo_nuevo VARCHAR(100)
);
GO

CREATE TABLE cabecera_factura_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_cabecera_factura INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    fecha_factura_anterior DATE,
    total_anterior DECIMAL(10,2),
    id_cliente_anterior INT,
    id_tipo_pago_anterior INT,
    id_usuario_anterior INT,
    fecha_factura_nuevo DATE,
    total_nuevo DECIMAL(10,2),
    id_cliente_nuevo INT,
    id_tipo_pago_nuevo INT,
    id_usuario_nuevo INT
);
GO

CREATE TABLE computadora_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_computadora INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    nombre_anterior VARCHAR(100),
    tasa_refresco_anterior FLOAT,
    refrigeracion_anterior VARCHAR(100),
    stock_anterior INT,
    id_gabinete_anterior INT,
    id_placa_video_anterior INT,
    id_almacenamiento_anterior INT,
    id_RAM_anterior INT,
    id_fuente_poder_anterior INT,
    id_procesador_anterior INT,
    id_placa_madre_anterior INT,
    nombre_nuevo VARCHAR(100),
    tasa_refresco_nuevo FLOAT,
    refrigeracion_nuevo VARCHAR(100),
    stock_nuevo INT,
    id_gabinete_nuevo INT,
    id_placa_video_nuevo INT,
    id_almacenamiento_nuevo INT,
    id_RAM_nuevo INT,
    id_fuente_poder_nuevo INT,
    id_procesador_nuevo INT,
    id_placa_madre_nuevo INT
);
GO

CREATE TABLE detalle_venta_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_detalle_venta INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    cantidad_anterior INT,
    subtotal_anterior DECIMAL(10,2),
    id_cabecera_factura_anterior INT,
    id_computadora_anterior INT,
    cantidad_nuevo INT,
    subtotal_nuevo DECIMAL(10,2),
    id_cabecera_factura_nuevo INT,
    id_computadora_nuevo INT
);
GO

--Aca defino las tablas para los triggers que son solo para el DELETE
CREATE TABLE gabinete_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_gabinete INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE placa_video_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_placa_video INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE almacenamiento_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_almacenamiento INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE ram_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_RAM INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    tipo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE fuente_poder_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_fuente_poder INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE procesador_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_procesador INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL
);
GO

CREATE TABLE placa_madre_auditoria (
    auditoria_id INT IDENTITY PRIMARY KEY,
    id_placa_madre INT NOT NULL,
    accion VARCHAR(10) NOT NULL,
    fecha DATETIME DEFAULT GETDATE() NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL
);
GO


--Triggers de Auditoria (UPDATE y DELETE)
CREATE TRIGGER trigger_tipo_usuario_auditoria
ON Tipo_Usuario
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO tipo_usuario_auditoria (id_tipo_usuario, accion, usuario, nombre_rol_anterior, nombre_rol_nuevo)
        SELECT d.id_tipo_usuario, 'UPDATE', SYSTEM_USER, d.nombre_rol, i.nombre_rol
        FROM inserted i JOIN deleted d ON i.id_tipo_usuario = d.id_tipo_usuario;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO tipo_usuario_auditoria (id_tipo_usuario, accion, usuario, nombre_rol_anterior, nombre_rol_nuevo)
        SELECT d.id_tipo_usuario, 'DELETE', SYSTEM_USER, d.nombre_rol, NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trigger_usuario_auditoria
ON Usuario
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO usuario_auditoria (
            id_usuario, accion, usuario, 
            nombre_usuario_anterior, contrasena_anterior, email_anterior, nombre_anterior, apellido_anterior, telefono_contacto_anterior, id_tipo_usuario_anterior,
            nombre_usuario_nuevo, contrasena_nuevo, email_nuevo, nombre_nuevo, apellido_nuevo, telefono_contacto_nuevo, id_tipo_usuario_nuevo
        )
        SELECT 
            d.id_usuario, 'UPDATE', SYSTEM_USER, 
            d.nombre_usuario, d.contrasena, d.email, d.nombre, d.apellido, d.telefono_contacto, d.id_tipo_usuario,
            i.nombre_usuario, i.contrasena, i.email, i.nombre, i.apellido, i.telefono_contacto, i.id_tipo_usuario
        FROM inserted i JOIN deleted d ON i.id_usuario = d.id_usuario;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO usuario_auditoria (
            id_usuario, accion, usuario, 
            nombre_usuario_anterior, contrasena_anterior, email_anterior, nombre_anterior, apellido_anterior, telefono_contacto_anterior, id_tipo_usuario_anterior,
            nombre_usuario_nuevo, contrasena_nuevo, email_nuevo, nombre_nuevo, apellido_nuevo, telefono_contacto_nuevo, id_tipo_usuario_nuevo
        )
        SELECT 
            d.id_usuario, 'DELETE', SYSTEM_USER, 
            d.nombre_usuario, d.contrasena, d.email, d.nombre, d.apellido, d.telefono_contacto, d.id_tipo_usuario,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trigger_cliente_auditoria
ON Cliente
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO cliente_auditoria (
            id_cliente, accion, usuario, 
            email_anterior, nombre_anterior, apellido_anterior, telefono_contacto_anterior,
            email_nuevo, nombre_nuevo, apellido_nuevo, telefono_contacto_nuevo
        )
        SELECT 
            d.id_cliente, 'UPDATE', SYSTEM_USER, 
            d.email, d.nombre, d.apellido, d.telefono_contacto,
            i.email, i.nombre, i.apellido, i.telefono_contacto
        FROM inserted i JOIN deleted d ON i.id_cliente = d.id_cliente;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO cliente_auditoria (
            id_cliente, accion, usuario, 
            email_anterior, nombre_anterior, apellido_anterior, telefono_contacto_anterior,
            email_nuevo, nombre_nuevo, apellido_nuevo, telefono_contacto_nuevo
        )
        SELECT 
            d.id_cliente, 'DELETE', SYSTEM_USER, 
            d.email, d.nombre, d.apellido, d.telefono_contacto,
            NULL, NULL, NULL, NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trigger_tipo_pago_auditoria
ON Tipo_Pago
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO tipo_pago_auditoria (id_tipo_pago, accion, usuario, tipo_anterior, tipo_nuevo)
        SELECT d.id_tipo_pago, 'UPDATE', SYSTEM_USER, d.tipo, i.tipo
        FROM inserted i JOIN deleted d ON i.id_tipo_pago = d.id_tipo_pago;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO tipo_pago_auditoria (id_tipo_pago, accion, usuario, tipo_anterior, tipo_nuevo)
        SELECT d.id_tipo_pago, 'DELETE', SYSTEM_USER, d.tipo, NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trigger_cabecera_factura_auditoria
ON Cabecera_Factura
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO cabecera_factura_auditoria (
            id_cabecera_factura, accion, usuario, 
            fecha_factura_anterior, total_anterior, id_cliente_anterior, id_tipo_pago_anterior, id_usuario_anterior,
            fecha_factura_nuevo, total_nuevo, id_cliente_nuevo, id_tipo_pago_nuevo, id_usuario_nuevo
        )
        SELECT 
            d.id_cabecera_factura, 'UPDATE', SYSTEM_USER, 
            d.fecha, d.total, d.id_cliente, d.id_tipo_pago, d.id_usuario,
            i.fecha, i.total, i.id_cliente, i.id_tipo_pago, i.id_usuario
        FROM inserted i JOIN deleted d ON i.id_cabecera_factura = d.id_cabecera_factura;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO cabecera_factura_auditoria (
            id_cabecera_factura, accion, usuario, 
            fecha_factura_anterior, total_anterior, id_cliente_anterior, id_tipo_pago_anterior, id_usuario_anterior,
            fecha_factura_nuevo, total_nuevo, id_cliente_nuevo, id_tipo_pago_nuevo, id_usuario_nuevo
        )
        SELECT 
            d.id_cabecera_factura, 'DELETE', SYSTEM_USER, 
            d.fecha, d.total, d.id_cliente, d.id_tipo_pago, d.id_usuario,
            NULL, NULL, NULL, NULL, NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trigger_computadora_auditoria
ON Computadora
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO computadora_auditoria (
            id_computadora, accion, usuario, 
            nombre_anterior, tasa_refresco_anterior, refrigeracion_anterior, stock_anterior, 
            id_gabinete_anterior, id_placa_video_anterior, id_almacenamiento_anterior, id_RAM_anterior, id_fuente_poder_anterior, id_procesador_anterior, id_placa_madre_anterior,
            nombre_nuevo, tasa_refresco_nuevo, refrigeracion_nuevo, stock_nuevo, 
            id_gabinete_nuevo, id_placa_video_nuevo, id_almacenamiento_nuevo, id_RAM_nuevo, id_fuente_poder_nuevo, id_procesador_nuevo, id_placa_madre_nuevo
        )
        SELECT 
            d.id_computadora, 'UPDATE', SYSTEM_USER, 
            d.nombre, d.tasa_refresco, d.refrigeracion, d.stock, 
            d.id_gabinete, d.id_placa_video, d.id_almacenamiento, d.id_RAM, d.id_fuente_poder, d.id_procesador, d.id_placa_madre,
            i.nombre, i.tasa_refresco, i.refrigeracion, i.stock, 
            i.id_gabinete, i.id_placa_video, i.id_almacenamiento, i.id_RAM, i.id_fuente_poder, i.id_procesador, i.id_placa_madre
        FROM inserted i JOIN deleted d ON i.id_computadora = d.id_computadora;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO computadora_auditoria (
            id_computadora, accion, usuario, 
            nombre_anterior, tasa_refresco_anterior, refrigeracion_anterior, stock_anterior, 
            id_gabinete_anterior, id_placa_video_anterior, id_almacenamiento_anterior, id_RAM_anterior, id_fuente_poder_anterior, id_procesador_anterior, id_placa_madre_anterior,
            nombre_nuevo, tasa_refresco_nuevo, refrigeracion_nuevo, stock_nuevo, 
            id_gabinete_nuevo, id_placa_video_nuevo, id_almacenamiento_nuevo, id_RAM_nuevo, id_fuente_poder_nuevo, id_procesador_nuevo, id_placa_madre_nuevo
        )
        SELECT 
            d.id_computadora, 'DELETE', SYSTEM_USER, 
            d.nombre, d.tasa_refresco, d.refrigeracion, d.stock, 
            d.id_gabinete, d.id_placa_video, d.id_almacenamiento, d.id_RAM, d.id_fuente_poder, d.id_procesador, d.id_placa_madre,
            NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trigger_detalle_venta_auditoria
ON Detalle_Venta
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO detalle_venta_auditoria (
            id_detalle_venta, accion, usuario, 
            cantidad_anterior, subtotal_anterior, id_cabecera_factura_anterior, id_computadora_anterior,
            cantidad_nuevo, subtotal_nuevo, id_cabecera_factura_nuevo, id_computadora_nuevo
        )
        SELECT 
            d.id_detalle_venta, 'UPDATE', SYSTEM_USER, 
            d.cantidad, d.subtotal, d.id_cabecera_factura, d.id_computadora,
            i.cantidad, i.subtotal, i.id_cabecera_factura, i.id_computadora
        FROM inserted i JOIN deleted d ON i.id_detalle_venta = d.id_detalle_venta;
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO detalle_venta_auditoria (
            id_detalle_venta, accion, usuario, 
            cantidad_anterior, subtotal_anterior, id_cabecera_factura_anterior, id_computadora_anterior,
            cantidad_nuevo, subtotal_nuevo, id_cabecera_factura_nuevo, id_computadora_nuevo
        )
        SELECT 
            d.id_detalle_venta, 'DELETE', SYSTEM_USER, 
            d.cantidad, d.subtotal, d.id_cabecera_factura, d.id_computadora,
            NULL, NULL, NULL, NULL
        FROM deleted d;
    END
END;
GO

--Triggers de Auditoria (DELETE)
CREATE TRIGGER trigger_gabinete_delete_auditoria
ON Gabinete
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO gabinete_auditoria (id_gabinete, accion, usuario, marca, modelo)
    SELECT id_gabinete, 'DELETE', SYSTEM_USER, marca, modelo
    FROM deleted;
END;
GO

CREATE TRIGGER trg_placa_video_delete_auditoria
ON Placa_Video
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO placa_video_auditoria (id_placa_video, accion, usuario, marca, modelo)
    SELECT id_placa_video, 'DELETE', SYSTEM_USER, marca, modelo
    FROM deleted;
END;
GO

CREATE TRIGGER trg_almacenamiento_delete_auditoria
ON Almacenamiento
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO almacenamiento_auditoria (id_almacenamiento, accion, usuario, marca, modelo)
    SELECT id_almacenamiento, 'DELETE', SYSTEM_USER, marca, modelo
    FROM deleted;
END;
GO

CREATE TRIGGER trg_ram_delete_auditoria
ON RAM
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ram_auditoria (id_RAM, accion, usuario, marca, tipo)
    SELECT id_RAM, 'DELETE', SYSTEM_USER, marca, tipo
    FROM deleted;
END;
GO

CREATE TRIGGER trg_fuente_poder_delete_auditoria
ON Fuente_Poder
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO fuente_poder_auditoria (id_fuente_poder, accion, usuario, marca, modelo)
    SELECT id_fuente_poder, 'DELETE', SYSTEM_USER, marca, modelo
    FROM deleted;
END;
GO

CREATE TRIGGER trg_procesador_delete_auditoria
ON Procesador
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO procesador_auditoria (id_procesador, accion, usuario, marca, modelo)
    SELECT id_procesador, 'DELETE', SYSTEM_USER, marca, modelo
    FROM deleted;
END;
GO

CREATE TRIGGER trg_placa_madre_delete_auditoria
ON Placa_Madre
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO placa_madre_auditoria (id_placa_madre, accion, usuario, marca, modelo)
    SELECT id_placa_madre, 'DELETE', SYSTEM_USER, marca, modelo
    FROM deleted;
END;
GO