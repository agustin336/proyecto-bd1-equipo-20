/* ============================================================================
   2. Permisos a nivel de usuarios 

     usuario_admin       -> se agrega al rol db_owner
     usuario_supervisor  -> puede consultar las ventas y ejecutar los
                            procedimientos agregarComputadora y actualizarStock.
                            No tiene INSERT ni UPDATE sobre Computadora.

   No se utiliza DENY: un usuario sin GRANT no tiene acceso.
   Los permisos solo afectan a los usuarios creados en el script 1.
   ============================================================================ */

USE Venta_Computadoras;
GO

-- Verificación: los procedimientos deben existir antes de asignar permisos
IF OBJECT_ID('dbo.agregarComputadora', 'P') IS NULL
   OR OBJECT_ID('dbo.actualizarStock', 'P') IS NULL
BEGIN
    RAISERROR('Faltan dbo.agregarComputadora o dbo.actualizarStock. Ejecutar antes implementacion_Procedimientos_Funciones.sql.', 16, 1);
    RETURN;
END;

-- Administrador
ALTER ROLE db_owner ADD MEMBER usuario_admin;

-- Supervisor: consulta de ventas
GRANT SELECT ON dbo.Cabecera_Factura TO usuario_supervisor;
GRANT SELECT ON dbo.Detalle_Venta    TO usuario_supervisor;

-- Supervisor: ejecución de procedimientos
GRANT EXECUTE ON dbo.agregarComputadora TO usuario_supervisor;
GRANT EXECUTE ON dbo.actualizarStock    TO usuario_supervisor;
GO

-- Verificación: permisos asignados a cada usuario
SELECT dp.name                         AS usuario,
       p.permission_name               AS permiso,
       p.state_desc                    AS estado,
       OBJECT_NAME(p.major_id)         AS objeto
FROM sys.database_permissions p
JOIN sys.database_principals dp ON dp.principal_id = p.grantee_principal_id
WHERE dp.name LIKE 'usuario[_]%'
  AND p.class = 1                      -- permisos sobre objetos
ORDER BY dp.name, objeto;

-- Verificación: miembros de db_owner
SELECT r.name AS rol, m.name AS miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name = 'db_owner';
GO
