# Etapa 4 — Consultas Avanzadas

En este informe explicamos las tres consultas avanzadas que armamos en el archivo `sql/consultas/consulta_avanzada.sql`. El objetivo fue resolver distintas preguntas de negocio combinando subconsultas, agrupamientos, funciones de ventana, CTEs y filtros de fecha.

---

## Consulta 1: Ventas por encima del ticket promedio

### 1. ¿Qué necesidad de información resuelve la consulta?
Queremos identificar cuáles fueron las ventas individuales cuyo importe superó el promedio de facturación de la tienda. Además del número de factura y el monto total, nos interesa mostrar los datos del cliente y los componentes clave de la computadora vendida (nombre del equipo, procesador y placa de video). 

Esto le sirve al negocio para ver qué configuraciones de hardware y equipos se venden en las operaciones más caras.

### 2. Código de la consulta implementada

```sql
USE Venta_Computadoras;
GO

SELECT 
    cf.id_cabecera_factura, 
    cf.fecha,
    cl.nombre + ' ' + cl.apellido AS cliente,
    comp.nombre AS equipo,
    pr.modelo AS procesador,
    COALESCE(pv.modelo, 'Integrada') AS placa_video,
    cf.total
FROM Detalle_Venta dv
JOIN Cabecera_Factura cf ON cf.id_cabecera_factura = dv.id_cabecera_factura
JOIN Cliente cl ON cl.id_cliente = cf.id_cliente
JOIN Computadora comp ON comp.id_computadora = dv.id_computadora
JOIN Procesador pr ON pr.id_procesador = comp.id_procesador
LEFT JOIN Placa_Video pv ON pv.id_placa_video = comp.id_placa_video
WHERE cf.total > (SELECT AVG(total) FROM Cabecera_Factura)
ORDER BY cf.total DESC;
GO
```

### 3. ¿Qué estrategia SQL utiliza?
- **Tabla base y JOINs:** Partimos desde `Detalle_Venta` y la vinculamos con `Cabecera_Factura`, `Cliente`, `Computadora` y `Procesador` para juntar toda la información de la venta en una sola salida.
- **LEFT JOIN con Placa_Video:** Lo usamos porque en la base de datos hay equipos como notebooks o All-in-One que no tienen placa de video dedicada (su valor es `NULL`). Si usáramos un `INNER JOIN`, esas ventas desaparecerían del informe.
- **COALESCE:** Si la computadora no tiene placa dedicada (`NULL`), reemplaza ese valor por la palabra `'Integrada'` para que no quede la columna vacía.
- **Subconsulta en el WHERE:** Usamos `WHERE cf.total > (SELECT AVG(total) FROM Cabecera_Factura)` para comparar el total de cada factura contra el promedio general sin tener que calcularlo antes ni dejar un valor fijo en el código.
- **ORDER BY:** Ordena los resultados de mayor a menor por el total vendido.

### 4. ¿Qué resultado se espera?
Se espera una lista con las ventas que superaron el promedio general de facturación (que con nuestros datos de prueba es de $2.673.927,50). 

La consulta devuelve 4 filas:

| id_cabecera_factura | fecha | cliente | equipo | procesador | placa_video | total |
| :-: | :-: | :--- | :--- | :--- | :--- | ---: |
| 1 | 2026-09-01 | Martin Garcia | GP162 | Ryzen 3 3200G | RTX 5070 Ti | $3.240.670,00 |
| 3 | 2026-09-05 | Facundo Martinez | HP All In One 24 | Ryzen 5 40 | Integrada | $3.100.600,00 |
| 5 | 2026-09-10 | Nicolas Sanchez | GP608 | Core i5-14600K | RTX 5090 | $2.900.050,00 |
| 4 | 2026-09-08 | Valentina Romero | GP607 | Core i7-14700K | RX 9070 | $2.700.500,00 |

---

## Consulta 2: Medios de pago que superan el ticket promedio

### 1. ¿Qué necesidad de información resuelve la consulta?
Queremos saber qué medios de pago tienen un promedio de venta por factura superior al promedio general de la empresa, tomando un período determinado (en este caso, los últimos 30 días). 

Esta información ayuda a identificar a través de qué formas de pago los clientes hacen las compras de mayor valor, lo cual es útil para evaluar promociones bancarias o costos de comisiones.

### 2. Código de la consulta implementada

```sql
USE Venta_Computadoras;
GO

-- Variable para filtrar los últimos 30 días a partir de la fecha actual
DECLARE @desde DATE = DATEADD(DAY, -30, CAST(GETDATE() AS DATE));

SELECT 
    tp.tipo AS medio_pago,
    COUNT(DISTINCT cf.id_cabecera_factura) AS cantidad_facturas,
    SUM(dv.subtotal) AS monto_total,
    AVG(dv.subtotal) AS ticket_promedio
FROM Tipo_Pago tp
JOIN Cabecera_Factura cf ON cf.id_tipo_pago = tp.id_tipo_pago
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
WHERE cf.fecha >= @desde
GROUP BY tp.tipo
HAVING AVG(dv.subtotal) > (
    SELECT AVG(dv2.subtotal) 
    FROM Detalle_Venta dv2
    JOIN Cabecera_Factura cf2 ON cf2.id_cabecera_factura = dv2.id_cabecera_factura
    WHERE cf2.fecha >= @desde
)
ORDER BY ticket_promedio DESC;
GO
```

### 3. ¿Qué estrategia SQL utiliza?
- **Variable `@desde`:** Declaramos una variable de tipo `DATE` usando `DATEADD` y `GETDATE()` para calcular automáticamente la fecha de corte de los últimos 30 días.
- **COUNT(DISTINCT cf.id_cabecera_factura):** Como unimos con `Detalle_Venta`, si una factura tuviera varios productos, la cabecera se repetiría tantas veces como renglones tenga. Con `DISTINCT` nos aseguramos de contar facturas únicas.
- **GROUP BY:** Agrupa los datos por nombre del medio de pago (`tp.tipo`).
- **HAVING con subconsulta:** Filtra los grupos después de agrupar. Solo conserva aquellos medios de pago cuyo promedio (`AVG(dv.subtotal)`) sea mayor al promedio de todas las ventas del período (calculado en la subconsulta interna).
- **ORDER BY:** Ordena los métodos de pago de mayor a menor según su ticket promedio.

### 4. ¿Qué resultado se espera?
Se espera una tabla resumen con los medios de pago que superaron el promedio general del negocio en el período analizado.

Con los datos cargados en el sistema (promedio general de $2.673.927,50):

| medio_pago | cantidad_facturas | monto_total | ticket_promedio |
| :--- | :-: | ---: | ---: |
| Deposito | 1 | $2.900.050,00 | $2.900.050,00 |
| Efectivo | 2 | $5.647.730,00 | $2.823.865,00 |
| Transferencia | 1 | $2.700.500,00 | $2.700.500,00 |

Los demás medios de pago (como Tarjeta de Crédito, Débito o Ualá) quedan descartados automáticamente porque su ticket promedio no alcanzó la media global.

---

## Consulta 3: Clientes que más gastaron (ranking, hardware y porcentaje)

### 1. ¿Qué necesidad de información resuelve la consulta?
La empresa necesita analizar a sus mejores clientes, es decir, aquellos que en total gastaron más que el promedio gastado por cliente. 

Para cada uno de estos clientes se busca saber:
1. Qué lugar ocupan en un ranking de ventas según su gasto total.
2. Cuánto dinero gastaron en total, cuánto dinero gastaron por encima del promedio y qué porcentaje representa su compra respecto a la facturación total del negocio.
3. Qué computadora compraron, qué componentes tiene (procesador, RAM, almacenamiento y placa de video) y en qué gama se ubica el equipo.
4. Con qué medio de pago abonaron y qué vendedor los atendió.

### 2. Código de la consulta implementada

```sql
USE Venta_Computadoras;
GO

-- CTE 1: Calcula el gasto promedio por cliente y el total general de la empresa
WITH referencia AS (
    SELECT 
        AVG(t.monto_cliente) AS promedio_cliente,
        SUM(t.monto_cliente) AS total_general
    FROM (
        SELECT cf.id_cliente, SUM(dv.subtotal) AS monto_cliente
        FROM Cabecera_Factura cf
        JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
        GROUP BY cf.id_cliente
    ) AS t
),
-- CTE 2: Agrupa por cliente y se queda solo con los que superan el promedio
ventas_cliente AS (
    SELECT 
        cf.id_cliente,
        COUNT(DISTINCT cf.id_cabecera_factura) AS cantidad_compras,
        SUM(dv.subtotal) AS monto_total
    FROM Cabecera_Factura cf
    JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
    GROUP BY cf.id_cliente
    HAVING SUM(dv.subtotal) > (SELECT promedio_cliente FROM referencia)
)
SELECT
    DENSE_RANK() OVER (ORDER BY v.monto_total DESC) AS ranking,
    cl.nombre + ' ' + cl.apellido AS cliente,
    cf.fecha, 
    comp.nombre AS equipo,
    pr.marca + ' ' + pr.modelo AS procesador,
    r.tipo + ' ' + CAST(r.cantidad_memoria AS VARCHAR(10)) + ' GB' AS memoria_ram,
    al.tamano_gb AS almacenamiento_gb,
    COALESCE(pv.modelo, 'Integrada') AS placa_video,
    CASE
        WHEN pv.id_placa_video IS NULL THEN 'Sin placa dedicada'
        WHEN pv.cantidad_VRAM >= 16 THEN 'Gama alta'
        ELSE 'Gama media'
    END AS gama,
    dv.subtotal,
    v.monto_total AS total_cliente,
    v.monto_total - ref.promedio_cliente AS dif_vs_promedio,
    CAST(100.0 * v.monto_total / ref.total_general AS DECIMAL(5,2)) AS pct_del_total,
    tp.tipo AS medio_pago,
    u.nombre + ' ' + u.apellido AS vendedor
FROM ventas_cliente v
CROSS JOIN referencia ref
JOIN Cliente cl ON cl.id_cliente = v.id_cliente
JOIN Cabecera_Factura cf ON cf.id_cliente = v.id_cliente
JOIN Detalle_Venta dv ON dv.id_cabecera_factura = cf.id_cabecera_factura
JOIN Computadora comp ON comp.id_computadora = dv.id_computadora
JOIN Procesador pr ON pr.id_procesador = comp.id_procesador
JOIN RAM r ON r.id_RAM = comp.id_RAM
JOIN Almacenamiento al ON al.id_almacenamiento = comp.id_almacenamiento
LEFT JOIN Placa_Video pv ON pv.id_placa_video = comp.id_placa_video
JOIN Tipo_Pago tp ON tp.id_tipo_pago = cf.id_tipo_pago
JOIN Usuario u ON u.id_usuario = cf.id_usuario
ORDER BY ranking, cf.fecha;
GO
```

### 3. ¿Qué estrategia SQL utiliza?
- **Uso de CTEs (`WITH`):** Dividimos la lógica en dos tablas temporales:
  1. `referencia`: Suma lo gastado por cada cliente y obtiene dos datos clave para comparar: el gasto promedio por cliente (`promedio_cliente`) y la suma total vendida en la tienda (`total_general`).
  2. `ventas_cliente`: Suma lo comprado por cada cliente y filtra con un `HAVING` para quedarse únicamente con los que gastaron más que el promedio calculado en `referencia`.
- **CROSS JOIN con la tabla de referencia:** Como `referencia` devuelve una sola fila con los totales generales, un `CROSS JOIN` nos permite disponer de esos números en todas las filas para calcular porcentajes y diferencias sin tener que repetir subconsultas en cada columna.
- **Función de Ventana `DENSE_RANK()`:** Numera a los clientes del puesto 1 en adelante según su monto total (`ORDER BY v.monto_total DESC`). Elegimos `DENSE_RANK` en vez de `RANK` para que, en caso de empate en los montos, no deje huecos en los números del ranking.
- **CASE para definir la gama:** Clasificamos la potencia del equipo evaluando la memoria de la placa de video (`cantidad_VRAM`): si es `NULL` indica `'Sin placa dedicada'`, si tiene 16 GB o más es `'Gama alta'`, y en otro caso `'Gama media'`.
- **LEFT JOIN y COALESCE:** Mantiene en el informe a los equipos que no usan placa de video dedicada, mostrando el texto `'Integrada'`.
- **Cálculos matemáticos:**
  - `v.monto_total - ref.promedio_cliente`: Muestra cuántos pesos gastó el cliente por encima de la media.
  - `CAST(100.0 * v.monto_total / ref.total_general AS DECIMAL(5,2))`: Muestra el porcentaje que representa la compra de ese cliente sobre el total de ventas del negocio.
- **Relaciones con el resto de tablas:** Conectamos con `Cliente`, `Computadora`, `Procesador`, `RAM`, `Almacenamiento`, `Tipo_Pago` y `Usuario` para traer los nombres legibles de cada entidad (incluyendo el vendedor que hizo la venta).

### 4. ¿Qué resultado se espera?
Se espera una tabla completa con los clientes destacados, su posición en el ranking, qué equipo compraron y qué peso tuvieron en la facturación total.

Con los datos cargados en la base de datos (total de ventas de $21.391.420,00 y promedio por cliente de $2.673.927,50):

| ranking | cliente | fecha | equipo | procesador | memoria_ram | almacenamiento_gb | placa_video | gama | subtotal | total_cliente | dif_vs_promedio | pct_del_total | medio_pago | vendedor |
| :-: | :--- | :-: | :--- | :--- | :--- | :-: | :--- | :--- | ---: | ---: | ---: | :-: | :--- | :--- |
| **1** | Martin Garcia | 2026-09-01 | GP162 | AMD Ryzen 3 3200G | DDR5 16 GB | 1000 | RTX 5070 Ti | Gama alta | $3.240.670,00 | $3.240.670,00 | +$566.742,50 | 15.15% | Efectivo | Carlos Torrez |
| **2** | Facundo Martinez | 2026-09-05 | HP All In One 24 | AMD Ryzen 5 40 | DDR5 64 GB | 1000 | Integrada | Sin placa dedicada | $3.100.600,00 | $3.100.600,00 | +$426.672,50 | 14.49% | Tarjeta de Credito | Carlos Lopez |
| **3** | Nicolas Sanchez | 2026-09-10 | GP608 | Intel Core i5-14600K | DDR4 32 GB | 2000 | RTX 5090 | Gama alta | $2.900.050,00 | $2.900.050,00 | +$226.122,50 | 13.56% | Deposito | Carlos Torrez |
| **4** | Valentina Romero | 2026-09-08 | GP607 | Intel Core i7-14700K | DDR5 32 GB | 1000 | RX 9070 | Gama alta | $2.700.500,00 | $2.700.500,00 | +$26.572,50 | 12.62% | Transferencia | Lusiana Diaz |
