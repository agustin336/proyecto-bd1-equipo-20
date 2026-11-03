/* ============================================================================
   4. Pruebas de permisos

   Requiere los scripts 1, 2 y 3.

   En cada prueba se cambia de usuario con EXECUTE AS LOGIN, se ejecuta una
   operacion y se vuelve al usuario original con REVERT.

     Pruebas 1 a 5 -> demostracion sugerida por la guia
     Pruebas 6 a 8 -> pruebas complementarias (procedimientos y auditoria)

   Las computadoras insertadas llevan el prefijo 'PRUEBA_SEG' y se eliminan
   con 99_limpieza.sql.
   ============================================================================ */

USE Venta_Computadoras;
GO


/* ----------------------------------------------------------------------------
   PRUEBA 1 - SELECT sobre Computadora con usuario_vendedor
   Resultado esperado: correcto (miembro de rol_vendedor)
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 1: SELECT sobre Computadora con usuario_vendedor ===';

-- Permisos efectivos de usuario_vendedor sobre Computadora
EXECUTE AS LOGIN = 'usuario_vendedor';
SELECT SUSER_SNAME() AS usuario, 'dbo.Computadora' AS objeto, permission_name AS permiso
FROM fn_my_permissions('dbo.Computadora', 'OBJECT')
WHERE subentity_name = '';
REVERT;
GO

BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_vendedor';
    SELECT SUSER_SNAME() AS ejecutado_por, id_computadora, nombre, marca, stock
    FROM dbo.Computadora;
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_vendedor puede consultar Computadora (permiso heredado de rol_vendedor).';
END TRY
BEGIN CATCH
    -- Si la operacion falla, se vuelve al usuario original
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO


/* ----------------------------------------------------------------------------
   PRUEBA 2 - SELECT sobre Computadora con usuario_sin_rol
   Resultado esperado: acceso denegado (error 229)
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 2: SELECT sobre Computadora con usuario_sin_rol ===';

-- Permisos efectivos de usuario_sin_rol sobre Computadora (tabla vacia)
EXECUTE AS LOGIN = 'usuario_sin_rol';
SELECT SUSER_SNAME() AS usuario, 'dbo.Computadora' AS objeto, permission_name AS permiso
FROM fn_my_permissions('dbo.Computadora', 'OBJECT')
WHERE subentity_name = '';
REVERT;
GO

BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_sin_rol';
    SELECT SUSER_SNAME() AS ejecutado_por, id_computadora, nombre, marca, stock
    FROM dbo.Computadora;
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_sin_rol pudo consultar Computadora.';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO


/* ----------------------------------------------------------------------------
   PRUEBA 3 - INSERT directo sobre Computadora con usuario_admin
   Resultado esperado: correcto (miembro de db_owner)
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 3: INSERT directo sobre Computadora con usuario_admin ===';

PRINT '--- Estado ANTES ---';
SELECT (SELECT COUNT(*) FROM dbo.Computadora)                                 AS computadoras,
       (SELECT COUNT(*) FROM dbo.Computadora WHERE nombre LIKE 'PRUEBA[_]SEG%') AS computadoras_prueba;
GO

BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_admin';
    INSERT INTO dbo.Computadora (nombre, marca, tasa_refresco, refrigeracion, stock,
                                 id_gabinete, id_placa_video, id_almacenamiento, id_RAM,
                                 id_fuente_poder, id_procesador, id_placa_madre)
    VALUES ('PRUEBA_SEG insert admin', 'HP', 60, 'Aire', 5, NULL, NULL, 2, 2, NULL, 2, 9);
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_admin inserto la computadora (id '
          + CAST(SCOPE_IDENTITY() AS VARCHAR(10)) + ').';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (una computadora mas) ---';
SELECT (SELECT COUNT(*) FROM dbo.Computadora)                                 AS computadoras,
       (SELECT COUNT(*) FROM dbo.Computadora WHERE nombre LIKE 'PRUEBA[_]SEG%') AS computadoras_prueba;
SELECT id_computadora, nombre, marca, stock
FROM dbo.Computadora
WHERE nombre = 'PRUEBA_SEG insert admin';
GO


/* ----------------------------------------------------------------------------
   PRUEBA 4 - INSERT directo sobre Computadora con usuario_supervisor
   Resultado esperado: acceso denegado (no tiene INSERT sobre la tabla)
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 4: INSERT directo sobre Computadora con usuario_supervisor ===';

-- Permisos efectivos de usuario_supervisor sobre Computadora (tabla vacia)
EXECUTE AS LOGIN = 'usuario_supervisor';
SELECT SUSER_SNAME() AS usuario, 'dbo.Computadora' AS objeto, permission_name AS permiso
FROM fn_my_permissions('dbo.Computadora', 'OBJECT')
WHERE subentity_name = '';
REVERT;

PRINT '--- Estado ANTES ---';
SELECT COUNT(*) AS computadoras FROM dbo.Computadora;
GO

BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_supervisor';
    INSERT INTO dbo.Computadora (nombre, marca, tasa_refresco, refrigeracion, stock,
                                 id_gabinete, id_placa_video, id_almacenamiento, id_RAM,
                                 id_fuente_poder, id_procesador, id_placa_madre)
    VALUES ('PRUEBA_SEG insert supervisor', 'HP', 60, 'Aire', 5, NULL, NULL, 2, 2, NULL, 2, 9);
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_supervisor inserto la computadora.';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (debe ser igual al ANTES) ---';
SELECT COUNT(*) AS computadoras FROM dbo.Computadora;
GO


/* ----------------------------------------------------------------------------
   PRUEBA 5 - EXEC dbo.agregarComputadora con usuario_supervisor
   Resultado esperado: correcto. El procedimiento y la tabla tienen el mismo
   dueño (dbo), por lo que solo se verifica el permiso EXECUTE
   (encadenamiento de propiedad).
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 5: EXEC dbo.agregarComputadora con usuario_supervisor ===';

-- Permisos efectivos de usuario_supervisor sobre el procedimiento
EXECUTE AS LOGIN = 'usuario_supervisor';
SELECT SUSER_SNAME() AS usuario, 'dbo.agregarComputadora' AS objeto, permission_name AS permiso
FROM fn_my_permissions('dbo.agregarComputadora', 'OBJECT');
REVERT;

PRINT '--- Estado ANTES ---';
SELECT COUNT(*) AS computadoras FROM dbo.Computadora;
GO

BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_supervisor';
    EXEC dbo.agregarComputadora
        @Nombre = 'PRUEBA_SEG via procedimiento', @Marca = 'HP', @tasa_refresco = 60,
        @Refrigeracion = 'Aire', @Stock = 5, @id_gabinete = NULL, @id_placa_video = NULL,
        @id_almacenamiento = 2, @id_RAM = 2, @id_fuente_poder = NULL,
        @id_procesador = 2, @id_placa_madre = 9;
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_supervisor registro la computadora a traves del procedimiento.';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (una computadora mas) ---';
SELECT COUNT(*) AS computadoras FROM dbo.Computadora;
GO


/* ----------------------------------------------------------------------------
   PRUEBA 6 - UPDATE directo del stock con usuario_supervisor
   Requiere la prueba 5 (usa la computadora insertada en esa prueba).
   Resultado esperado: acceso denegado (no tiene UPDATE sobre la tabla)
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 6: UPDATE directo del stock con usuario_supervisor ===';

PRINT '--- Estado ANTES ---';
SELECT id_computadora, nombre, stock
FROM dbo.Computadora
WHERE nombre = 'PRUEBA_SEG via procedimiento';
GO

DECLARE @id INT = (SELECT MAX(id_computadora) FROM dbo.Computadora
                   WHERE nombre = 'PRUEBA_SEG via procedimiento');
BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_supervisor';
    UPDATE dbo.Computadora SET stock = stock + 3 WHERE id_computadora = @id;
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_supervisor modifico el stock.';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (el stock no cambia) ---';
SELECT id_computadora, nombre, stock
FROM dbo.Computadora
WHERE nombre = 'PRUEBA_SEG via procedimiento';
GO


/* ----------------------------------------------------------------------------
   PRUEBA 7 - EXEC dbo.actualizarStock con usuario_supervisor
   Requiere la prueba 5 (usa la computadora insertada en esa prueba).
   Resultado esperado: correcto. Si los triggers de auditoría están
   instalados, el cambio se registra a nombre de usuario_supervisor.
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 7: EXEC dbo.actualizarStock con usuario_supervisor ===';

PRINT '--- Estado ANTES ---';
SELECT id_computadora, nombre, stock
FROM dbo.Computadora
WHERE nombre = 'PRUEBA_SEG via procedimiento';
GO

DECLARE @id INT = (SELECT MAX(id_computadora) FROM dbo.Computadora
                   WHERE nombre = 'PRUEBA_SEG via procedimiento');
BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_supervisor';
    EXEC dbo.actualizarStock @id_computadora = @id, @cantidad = 3;
    REVERT;
    PRINT 'RESULTADO: correcto. usuario_supervisor aumento el stock en 3 a traves del procedimiento.';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: acceso denegado. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (stock + 3) ---';
SELECT id_computadora, nombre, stock
FROM dbo.Computadora
WHERE nombre = 'PRUEBA_SEG via procedimiento';
GO

-- Verificación: registro de auditoría del cambio
-- (solo si los triggers de auditoría están instalados)
IF OBJECT_ID('dbo.computadora_auditoria', 'U') IS NOT NULL
BEGIN
    PRINT '--- Auditoria: el cambio queda registrado a nombre de usuario_supervisor ---';
    SELECT TOP 1 auditoria_id, id_computadora, accion, fecha, usuario,
           stock_anterior, stock_nuevo
    FROM dbo.computadora_auditoria
    WHERE nombre_nuevo = 'PRUEBA_SEG via procedimiento'
    ORDER BY auditoria_id DESC;
END
ELSE
    PRINT 'Triggers de auditoria no instalados: se omite la consulta de auditoria.';
GO


/* ----------------------------------------------------------------------------
   PRUEBA 8 - EXEC dbo.agregarComputadora con stock -1 (usuario_supervisor)
   Resultado esperado: rechazado por el procedimiento (error 50001).
   El permiso EXECUTE no evita las validaciones del procedimiento.
   ---------------------------------------------------------------------------- */
PRINT '=== PRUEBA 8: EXEC dbo.agregarComputadora con stock -1 (usuario_supervisor) ===';

PRINT '--- Estado ANTES ---';
SELECT COUNT(*) AS computadoras FROM dbo.Computadora;
GO

BEGIN TRY
    EXECUTE AS LOGIN = 'usuario_supervisor';
    EXEC dbo.agregarComputadora
        @Nombre = 'PRUEBA_SEG stock negativo', @Marca = 'HP', @tasa_refresco = 60,
        @Refrigeracion = 'Aire', @Stock = -1, @id_gabinete = NULL, @id_placa_video = NULL,
        @id_almacenamiento = 2, @id_RAM = 2, @id_fuente_poder = NULL,
        @id_procesador = 2, @id_placa_madre = 9;
    REVERT;
    PRINT 'RESULTADO: correcto. Se registro una computadora con stock negativo.';
END TRY
BEGIN CATCH
    IF SUSER_SNAME() <> ORIGINAL_LOGIN() REVERT;
    PRINT 'RESULTADO: rechazado por el procedimiento. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
GO

PRINT '--- Estado DESPUES (debe ser igual al ANTES) ---';
SELECT COUNT(*) AS computadoras FROM dbo.Computadora;
GO
