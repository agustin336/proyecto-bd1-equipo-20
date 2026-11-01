# Optimización de Consultas a través de Índices

## 1. Definición y objetivo

Un índice es una estructura que SQL Server mantiene aparte de la tabla para encontrar filas sin tener que leerlas todas. Funciona como el índice de un libro: en vez de recorrer todas las páginas buscando un tema, se va directo a la página que lo trata.

Cuando una tabla no tiene un índice útil para el filtro de una consulta, el motor hace un escaneo completo (*Table Scan* o *Clustered Index Scan*) y revisa fila por fila. Con pocas filas no se nota, pero con un millón o más los tiempos y las lecturas de disco crecen bastante.

El objetivo de esta parte es medir ese impacto: tomar una consulta por período sobre una tabla de más de un millón de registros y comparar cómo se comporta sin índice, con un índice agrupado y con un índice que cubre la consulta.

---

## 2. Ventajas y aplicaciones

**Ventajas**

- Las consultas de búsqueda y filtrado responden más rápido.
- El motor lee menos páginas (menos lecturas lógicas) para devolver el mismo resultado.
- Sirven para filtros por fechas, códigos, clientes, productos, y también para joins y ordenamientos.
- Ayudan a que el sistema siga respondiendo bien cuando los datos crecen.

**Costos a tener en cuenta**

- Ocupan espacio adicional en disco.
- Cada `INSERT`, `UPDATE` y `DELETE` tiene que actualizar también los índices, así que las escrituras se vuelven un poco más lentas.
- Un índice que ninguna consulta usa solo suma costo, por eso conviene crear índices según las consultas que realmente se hacen.

**Aplicaciones en un sistema de ventas**

Informes de ventas por período, búsqueda de facturas por cliente o por vendedor, consulta de comprobantes y ranking de clientes. Son consultas que recorren tablas que crecen todos los días.

---

## 3. Implementación en SQL Server Express

### 3.1. Tipos de índice que se usan

| Tipo | Qué hace | Cantidad por tabla |
| :--- | :--- | :-: |
| **Agrupado** (*clustered*) | Ordena físicamente la tabla por la columna elegida. Las hojas del índice son las filas mismas. | 1 |
| **No agrupado** (*nonclustered*) | Es una estructura aparte, ordenada por la columna elegida, que apunta a la fila de la tabla. | Muchos |
| **No agrupado con `INCLUDE`** | Igual que el anterior, pero guarda en sus hojas columnas extra. Si el `SELECT` pide solo esas columnas, no hace falta ir a la tabla (índice de cobertura). | Muchos |

Por defecto, la `PRIMARY KEY` crea un índice agrupado. Una tabla sin índice agrupado se llama *heap*.

### 3.2. Sintaxis

```sql
-- Índice agrupado
CREATE CLUSTERED INDEX nombre_indice ON tabla (columna);

-- Índice no agrupado con columnas incluidas
CREATE NONCLUSTERED INDEX nombre_indice ON tabla (columna) INCLUDE (col1, col2);

-- Eliminar un índice
DROP INDEX nombre_indice ON tabla;
```

`INCLUDE` solo existe para índices no agrupados, porque el agrupado ya contiene todas las columnas de la tabla.

### 3.3. Cómo se mide

- `SET STATISTICS TIME ON`: muestra el tiempo de CPU y el tiempo total de ejecución.
- `SET STATISTICS IO ON`: muestra las lecturas lógicas (páginas leídas).
- Plan de ejecución real en SSMS (`Ctrl + M`): muestra qué operador eligió el motor.
- `CHECKPOINT` y `DBCC DROPCLEANBUFFERS` antes de cada prueba: vacían la caché para que todas las mediciones partan de las mismas condiciones. Se usan solo en entorno de prueba.

### 3.4. Operadores que aparecen en los planes

| Operador | Significado |
| :--- | :--- |
| **Table Scan** | Recorre toda la tabla (tabla sin índice agrupado). |
| **Clustered Index Scan** | Recorre todo el índice agrupado, es decir, también toda la tabla. |
| **Clustered Index Seek** | Va directo al rango buscado dentro del índice agrupado. |
| **Index Seek** | Va directo al rango buscado dentro de un índice no agrupado. |
| **Key / RID Lookup** | Después de usar un índice no agrupado, vuelve a la tabla a buscar las columnas que faltan. |

---

## 4. Caso concreto aplicado al sistema de ventas

La tabla del sistema que más crece con el uso es `Cabecera_Factura`: una fila por cada venta, con su `fecha`. Además, el informe de ventas por vendedor de la Etapa IV (CU-05) filtra justamente por fecha:

```sql
WHERE fecha BETWEEN '2026-09-01' AND GETDATE()
```

Cuanto más historial haya, más lenta es esa consulta si la fecha no tiene un índice que ayude.

**La prueba no se hace sobre `Cabecera_Factura` real**, por dos motivos:

1. Cargarle un millón de filas inventadas ensuciaría los datos del sistema y cambiaría los resultados de los informes de la Etapa IV.
2. `Cabecera_Factura` ya tiene un índice agrupado por su clave primaria (`id_cabecera_factura`), y una tabla solo puede tener uno. Para probar un índice agrupado por fecha habría que sacar la PK, que está referenciada desde `Detalle_Venta`.

Por eso se crea una tabla de prueba, `Factura_Historica`, con las mismas columnas que `Cabecera_Factura`, sin claves ni índices:

| Columna | Tipo | Equivale en `Cabecera_Factura` |
| :--- | :--- | :--- |
| `id_factura` | `BIGINT IDENTITY` | `id_cabecera_factura` |
| `fecha` | `DATE` | `fecha` |
| `total` | `DECIMAL(10,2)` | `total` |
| `id_cliente` | `INT` | `id_cliente` |
| `id_tipo_pago` | `INT` | `id_tipo_pago` |
| `id_usuario` | `INT` | `id_usuario` |

**Consulta de prueba:** facturas emitidas en el primer trimestre de 2023.

```sql
SELECT id_factura, fecha, total
FROM dbo.Factura_Historica
WHERE fecha BETWEEN '2023-01-01' AND '2023-03-31';
```

Las fechas se reparten al azar entre 2020 y 2024 (1825 días), así que ese trimestre (90 días) devuelve alrededor del 5 % de las filas.

---

## 5. Script de demostración y resultados obtenidos

El script completo está en `etapa5_optimizacion_indices.sql`. Estas son sus partes:

### Parte 1 - Creación de la tabla de prueba

```sql
CREATE TABLE dbo.Factura_Historica
(
    id_factura   BIGINT        IDENTITY(1,1) NOT NULL,
    fecha        DATE          NOT NULL,
    total        DECIMAL(10,2) NOT NULL,
    id_cliente   INT           NOT NULL,
    id_tipo_pago INT           NOT NULL,
    id_usuario   INT           NOT NULL
);
```

No se define `PRIMARY KEY` a propósito: la tabla queda como *heap*, sin ningún índice.

### Parte 2 - Carga masiva de 1.000.000 de registros

```sql
WITH Numeros AS
(
    SELECT TOP (1000000)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_columns a
    CROSS JOIN sys.all_columns b
)
INSERT INTO dbo.Factura_Historica (fecha, total, id_cliente, id_tipo_pago, id_usuario)
SELECT
    DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 1825), CAST('2020-01-01' AS DATE)),
    CAST(100000 + ABS(CHECKSUM(NEWID()) % 900000) AS DECIMAL(10,2)),
    1 + ABS(CHECKSUM(NEWID()) % 200),
    1 + ABS(CHECKSUM(NEWID()) % 4),
    1 + ABS(CHECKSUM(NEWID()) % 10)
FROM Numeros;
```

Se verifica con `SELECT COUNT(*) FROM dbo.Factura_Historica;`, que debe devolver 1.000.000.

### Parte 3 - Consulta sin índice

Se activan las estadísticas, se limpia la caché y se ejecuta la consulta de prueba.
| Medición | Valor |
| :--- | :--- |
| Tiempo de CPU | 78 ms |
| Tiempo total | 465 ms |
| Lecturas lógicas | 5.077 |


### Parte 4 - Índice agrupado sobre la fecha

```sql
CREATE CLUSTERED INDEX IX_Factura_Historica_fecha
ON dbo.Factura_Historica (fecha);
```

Se repite la misma consulta.
| Medición | Valor |
| :--- | :--- |
| Tiempo de CPU | 31 ms |
| Tiempo total | 487 ms |
| Lecturas lógicas | 302 |


### Parte 5 - Eliminación del índice

```sql
DROP INDEX IX_Factura_Historica_fecha
ON dbo.Factura_Historica;
```

La tabla vuelve a ser un *heap*.

### Parte 6 - Índice de cobertura (no agrupado con `INCLUDE`)

```sql
CREATE NONCLUSTERED INDEX IX_Factura_Historica_fecha_cobertura
ON dbo.Factura_Historica (fecha)
INCLUDE (id_factura, total);
```

El índice está ordenado por `fecha` e incluye `id_factura` y `total`, que son las otras dos columnas que pide el `SELECT`. Con eso el motor puede responder la consulta usando solo el índice, sin volver a la tabla. Se repite la consulta.

| Medición | Valor |
| :--- | :--- |
| Tiempo de CPU | 16 ms |
| Tiempo total | 482 ms |
| Lecturas lógicas | 211 |


### Comparación

| Escenario | CPU (ms) | Tiempo total (ms) | Lecturas lógicas | Espacio reservado |
| :--- | :-: | :-: | :-: | :-: |
| Sin índice | 78 | 465 | 5.077 | 40.648 KB |
| Índice agrupado sobre fecha | 31 | 487 | 302 | 48.648 KB |
| Índice con cobertura | 16 | 482 | 211 | 82.320 KB |

El espacio se obtiene con `sp_spaceused 'dbo.Factura_Historica'` después de crear cada índice.

**Aclaración:** los valores de la tabla son los que se midieron en el momento de la prueba. Los tiempos (CPU y tiempo total) pueden variar claramente de una ejecución a otra, porque dependen del estado de la computadora, del disco y de la caché. Si la prueba se repite se van a obtener números distintos. Las lecturas lógicas, en cambio, casi no varían, y por eso son la métrica más confiable para comparar los tres escenarios.

**Costo de crear cada índice** (según `STATISTICS TIME` e `IO` al ejecutar el `CREATE INDEX`):

| Índice | CPU (ms) | Tiempo total (ms) | Lecturas lógicas |
| :--- | :-: | :-: | :-: |
| Agrupado sobre `fecha` | 3.094 | 3.164 | 5.077 |
| No agrupado con `INCLUDE` | 563 | 589 | 6.061 |

### Conclusiones

1. Sin índice, el motor leyó las 5.077 páginas de la tabla completa (unos 40 MB) para devolver cerca del 5 % de las filas. Las lecturas son las de la tabla entera sin importar qué tan chico sea el rango pedido.
2. Con el índice agrupado sobre `fecha`, las lecturas lógicas bajan de 5.077 a 302, unas 17 veces menos, porque el motor lee solo la parte de la tabla que corresponde al rango pedido. El tiempo de CPU baja de 78 ms a 31 ms.
3. El índice con cobertura incluye todas las columnas que pide el `SELECT`, así que resuelve la consulta sin volver a la tabla: 211 lecturas lógicas (24 veces menos que sin índice) y 16 ms de CPU. Como `Factura_Historica` tiene pocas columnas, la diferencia contra el agrupado es chica; sería más notoria en una tabla más ancha, porque el índice guarda solo las columnas necesarias.
4. El tiempo total casi no cambió entre los tres escenarios (465, 487 y 482 ms). Las pruebas se hicieron con la caché vaciada, así que ese tiempo incluye traer páginas del disco y enviar las filas al cliente, algo que pesa lo mismo en los tres casos. Por eso la mejora se ve mejor en las lecturas lógicas y en el tiempo de CPU.
5. Los índices tienen un costo. Ocupan espacio: la tabla pasó de 40.648 KB a 48.648 KB con el índice agrupado, y a 82.320 KB con el de cobertura, que casi duplica el tamaño. Además llevan tiempo de construcción (3,2 s el agrupado y 0,6 s el de cobertura sobre un millón de filas) y hay que mantenerlos actualizados en cada escritura. Por eso conviene crearlos para las consultas que realmente se usan, como los informes por período.
6. Para el sistema real, el índice que se ajusta a la consulta de informes por fecha sería uno no agrupado sobre `Cabecera_Factura(fecha)` que incluya `total` e `id_usuario`, ya que el índice agrupado de esa tabla lo ocupa la clave primaria.
