/* ============================================================================
   3. Permisos a nivel de roles

     rol_vendedor        -> puede consultar el catálogo (computadoras y
                            componentes)
     usuario_vendedor    -> se agrega como miembro de rol_vendedor
     usuario_sin_rol     -> no se agrega al rol

   Los permisos se asignan al rol y no al usuario.
   ============================================================================ */

USE Venta_Computadoras;
GO

-- Creación del rol
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'rol_vendedor' AND type = 'R')
    CREATE ROLE rol_vendedor;
GO

-- Asignación de permisos al rol
GRANT SELECT ON dbo.Computadora    TO rol_vendedor;
GRANT SELECT ON dbo.Procesador     TO rol_vendedor;
GRANT SELECT ON dbo.RAM            TO rol_vendedor;
GRANT SELECT ON dbo.Placa_Video    TO rol_vendedor;
GRANT SELECT ON dbo.Almacenamiento TO rol_vendedor;
GRANT SELECT ON dbo.Placa_Madre    TO rol_vendedor;
GRANT SELECT ON dbo.Gabinete       TO rol_vendedor;
GRANT SELECT ON dbo.Fuente_Poder   TO rol_vendedor;
GO

-- Incorporación del usuario al rol
ALTER ROLE rol_vendedor ADD MEMBER usuario_vendedor;
GO

-- Verificación: permisos del rol
SELECT p.permission_name       AS permiso,
       p.state_desc            AS estado,
       OBJECT_NAME(p.major_id) AS objeto
FROM sys.database_permissions p
JOIN sys.database_principals r ON r.principal_id = p.grantee_principal_id
WHERE r.name = 'rol_vendedor'
ORDER BY objeto;

-- Verificación: miembros del rol
SELECT r.name AS rol, m.name AS miembro
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE r.name = 'rol_vendedor';
GO
