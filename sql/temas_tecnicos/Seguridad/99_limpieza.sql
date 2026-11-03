/* ============================================================================
   99. Limpieza

   Deja la base y el servidor como estaban antes de los scripts de seguridad:

     1. Se eliminan las computadoras de prueba (prefijo 'PRUEBA_SEG')
     2. Se reinicia el IDENTITY de Computadora al id más alto existente
     3. Se eliminan los usuarios, el rol y los logins (los permisos se
        eliminan con ellos)

   Si los triggers de auditoría están instalados, el borrado del paso 1
   queda registrado en computadora_auditoria.
   ============================================================================ */

USE Venta_Computadoras;
GO

-- Eliminación de datos de prueba y reinicio del IDENTITY
DELETE FROM dbo.Computadora WHERE nombre LIKE 'PRUEBA[_]SEG%';

DECLARE @max INT = (SELECT ISNULL(MAX(id_computadora), 0) FROM dbo.Computadora);
DBCC CHECKIDENT ('dbo.Computadora', RESEED, @max);
GO

-- Eliminación de usuarios y rol (primero los usuarios, para que el rol quede sin miembros)
DROP USER IF EXISTS usuario_admin;
DROP USER IF EXISTS usuario_supervisor;
DROP USER IF EXISTS usuario_vendedor;
DROP USER IF EXISTS usuario_sin_rol;
DROP ROLE IF EXISTS rol_vendedor;
GO

-- Eliminación de logins (DROP LOGIN no admite IF EXISTS)
USE master;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_admin')      DROP LOGIN usuario_admin;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_supervisor') DROP LOGIN usuario_supervisor;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_vendedor')   DROP LOGIN usuario_vendedor;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'usuario_sin_rol')    DROP LOGIN usuario_sin_rol;
GO

-- Verificación: las tres primeras columnas deben dar 0
USE Venta_Computadoras;
GO

SELECT (SELECT COUNT(*) FROM dbo.Computadora WHERE nombre LIKE 'PRUEBA[_]SEG%')          AS computadoras_prueba,
       (SELECT COUNT(*) FROM sys.database_principals WHERE name LIKE 'usuario[_]%'
                                                        OR name = 'rol_vendedor')         AS usuarios_y_rol,
       (SELECT COUNT(*) FROM sys.server_principals   WHERE name LIKE 'usuario[_]%')       AS logins,
       IDENT_CURRENT('dbo.Computadora')                                                   AS identity_actual;
GO
