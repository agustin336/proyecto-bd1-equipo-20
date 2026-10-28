# Informe de Investigación: Manejo de Transacciones en SQL Server

## Introducción

Una operación de negocio, como registrar una venta, modifica varias tablas a la vez. Si falla a mitad de camino, la base queda con datos parciales. Esta investigación estudia las **transacciones** de SQL Server Express (T-SQL), que permiten tratar esa operación como una unidad, y las aplica a la venta de una computadora en nuestro sistema.

## Desarrollo y Fundamentos Teóricos

### Definición y objetivo

Una transacción es un conjunto de operaciones que se ejecutan como **una única unidad lógica**: o se confirman todas (`COMMIT`) o se deshacen todas (`ROLLBACK`). Garantiza las propiedades **ACID**: atomicidad (todo o nada), consistencia (la base pasa de un estado válido a otro válido), aislamiento (las transacciones simultáneas no se ven a medias) y durabilidad (lo confirmado no se pierde).

Por defecto SQL Server trabaja en *autocommit*: cada sentencia se confirma sola. Eso no alcanza cuando una operación necesita varias sentencias.

### Ventajas y aplicaciones

- Evitan datos parciales ante errores y mantienen consistentes las tablas relacionadas.
- Se aplican en ventas, facturación, transferencias, reservas y cualquier completarproceso que toque varias tablas.
- Una transacción abierta bloquea las filas que modificó, por lo que conviene mantenerla corta.

### Implementación en SQL Server Express

Comandos utilizados:

- `BEGIN TRANSACTION`, `COMMIT` y `ROLLBACK`.
- `SAVE TRANSACTION` y `ROLLBACK TRANSACTION nombre`, para deshacer solo una parte.
- `@@TRANCOUNT` (nivel de anidamiento) y `XACT_STATE()` (estado de la transacción).
- `SET XACT_ABORT ON`, `BEGIN TRY ... BEGIN CATCH` y `THROW`, para manejar errores.

```sql
BEGIN TRY
    BEGIN TRANSACTION;

    -- operaciones (INSERT, INSERT, UPDATE)

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    PRINT 'ROLLBACK. Error ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
END CATCH;
```

### Transacciones anidadas

En SQL Server las transacciones anidadas **no son independientes**: cada `BEGIN TRANSACTION` solo suma 1 a `@@TRANCOUNT`.

- El `COMMIT` interno no confirma nada; solo confirma el del nivel más externo.
- Un `ROLLBACK` sin nombre deshace **todo**, incluso lo que parecía confirmado.
- Con `SAVE TRANSACTION` se puede deshacer solo hasta un punto de control.

## Caso concreto: venta en el sistema

Registrar una venta implica tres operaciones: insertar la cabecera en `Cabecera_Factura`, insertar el detalle en `Detalle_Venta` y descontar el `stock` en `Computadora`. Sin transacción, un fallo en el último paso dejaría una venta registrada con el stock sin descontar.

Las restricciones de la Etapa 3 cumplen un papel en el caso:

- **`CHK_stock`** (`stock >= 0`) rechaza el descuento si no hay unidades suficientes y provoca el rollback de toda la venta.
- **`CHK_total` y `CHK_subtotal`** (`> 0`) obligan a calcular el monto antes de insertar la cabecera.

La implementación es un script con un bloque de parámetros editable. La implementación registra un solo ítem por venta; la encapsulación en un procedimiento almacenado se desarrolla en [`procedimientos_funciones/investigacion.md`](../procedimientos_funciones/investigacion.md).

## Script de demostración y resultados

**Scripts:** [`transaccion_venta.sql`](../../../sql/temas_tecnicos/transacciones/transaccion_venta.sql) (implementación) y carpeta [`pruebas/`](../../../sql/temas_tecnicos/transacciones/pruebas/).

Partiendo de 8 facturas, 8 detalles y stock 5 (computadora 1) y 14 (computadora 2), cada script muestra el estado de la base antes y después de la prueba. Versión del motor: ![Versión de SQL Server](evidencias/00_version_sql_server.png)

| # | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|:-:|---|---|---|---|
| 1 | Venta correcta (2 unidades) | `COMMIT`. Facturas 8→9, detalles 8→9, stock 5→3 | `COMMIT`. Venta confirmada (factura 9). | [Messages](evidencias/01_prueba1_messages.png) · [Resultados](evidencias/02_prueba1_resultados.png) |
| 2 | Stock insuficiente (10 unidades) | `ROLLBACK`, error 547 (`CHK_stock`). Estado sin cambios | `ROLLBACK`. Error 547: The `UPDATE` statement conflicted with the `CHECK` constraint "CHK_stock". The conflict ocurred in database "Vneta_Computadoras", table "dbo.Computadora", column 'stock'. | [Messages](evidencias/03_prueba2_messages.png) · [Resultados](evidencias/04_prueba2_resultados.png) |
| 3 | Error intencional (`THROW` tras los `INSERT`) | `ROLLBACK`, error 50001. Estado sin cambios | `ROLLBACK`. Error 50001: Error intencional provocado despues de los INSERT. | [Messages](evidencias/05_prueba3_messages.png) · [Resultados](evidencias/06_prueba3_resultados.png) |
| 4 | Anidada con `ROLLBACK` externo | `@@TRANCOUNT` 1, 2, 1 y 0. Estado sin cambios | Despues del `BEGIN`externo : @@TRACOUT = 1<br>Despues del `BEGIN` interno : @@TRANCOUNT = 2<br>Despues del `COMMIT` interno : @@TRANCOUNT = 1<br>Despues del `ROLLBACK` : @@TRANCOUNT = 0 | [Messages](evidencias/07_prueba4_messages.png) · [Resultados](evidencias/08_prueba4_resultados.png) |
| 5 | Punto de control (`SAVE TRANSACTION`) | `COMMIT` parcial: +1 factura, +1 detalle, stock de la computadora 1 −1, stock de la computadora 2 sin cambios | `COMIT` parcial. Factura 13 con un unico item | [Messages](evidencias/09_prueba5_messages.png) · [Resultados](evidencias/10_prueba5_resultados.png) |

### Observación: los `IDENTITY` no se revierten

Al ejecutar la prueba 1 apareció el error 2627 (clave primaria duplicada en `Detalle_Venta`). El diagnóstico mostró ids del 4 al 11 con el contador `IDENTITY` en 8: un `ROLLBACK` o un `DELETE` no devuelven los números ya consumidos. Se corrigió con `DBCC CHECKIDENT` y ajustando la limpieza ([`99_limpieza_resultados.sql`](../../../sql/temas_tecnicos/transacciones/pruebas/99_limpieza_resultados.sql)).
Evidencia: [diagnóstico](evidencias/12_identity_diagnostico.png) y [error 2627](evidencias/13_error_2627.png).

## Conclusión

Las pruebas 2 y 3 muestran que, aunque la falla ocurra después de los `INSERT`, no queda ningún dato parcial: la transacción cumple la atomicidad y, junto con `CHK_stock`, mantiene la consistencia. La prueba 4 confirma que en SQL Server el `COMMIT` interno no confirma nada y un `ROLLBACK` externo deshace todo, y la prueba 5 que `SAVE TRANSACTION` permite deshacer solo una parte. Además, los valores de `IDENTITY` consumidos no se recuperan con un rollback, algo a tener en cuenta al limpiar datos de prueba.

Como limitaciones, las pruebas cubren un único ítem por venta y una sola sesión; el aislamiento entre sesiones concurrentes se describe pero no se probó.
