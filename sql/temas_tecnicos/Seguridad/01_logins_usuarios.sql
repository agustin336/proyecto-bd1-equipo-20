/* ============================================================================
   1. Logins y usuarios

   Se crean los logins (al nivel del servidor) y los usuarios
   (al nivel de la base de datos):

     usuario_admin       -> Administrador, tiene control total (db_owner)
     usuario_supervisor  -> Supervisor, puede consultar ventas pero no tocar
                            las tablas de manera directa, solo a través de procedimientos
     usuario_vendedor    -> Vendedor, puede ver el catálogo gracias a un rol
     usuario_sin_rol     -> no tiene ningún permiso

   Antes de crear cada login y cada usuario se verifica si ya existe.
   ============================================================================ */

-- Creación de logins
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_admin')
    CREATE LOGIN usuario_admin      WITH PASSWORD = 'Admin123',  DEFAULT_DATABASE = Venta_Computadoras;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_supervisor')
    CREATE LOGIN usuario_supervisor WITH PASSWORD = 'Supervisor123', DEFAULT_DATABASE = Venta_Computadoras;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_vendedor')
    CREATE LOGIN usuario_vendedor   WITH PASSWORD = 'Vendedor123',  DEFAULT_DATABASE = Venta_Computadoras;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_sin_rol')
    CREATE LOGIN usuario_sin_rol    WITH PASSWORD = 'SinRol123', DEFAULT_DATABASE = Venta_Computadoras;
GO

-- Creacion de usuarios
USE Venta_Computadoras;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_admin')
    CREATE USER usuario_admin      FOR LOGIN usuario_admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_supervisor')
    CREATE USER usuario_supervisor FOR LOGIN usuario_supervisor;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_vendedor')
    CREATE USER usuario_vendedor   FOR LOGIN usuario_vendedor;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usuario_sin_rol')
    CREATE USER usuario_sin_rol    FOR LOGIN usuario_sin_rol;
GO

-- Verificación: seleccionamos cada login junto con su usuario
SELECT sp.name AS login_servidor,
       dp.name AS usuario_base,
       dp.type_desc
FROM sys.server_principals sp
LEFT JOIN sys.database_principals dp ON dp.sid = sp.sid
WHERE sp.name LIKE 'usuario[_]%'
ORDER BY sp.name;
GO
