# Etapa IV: Informe de Casos de Uso

## 1. Actores

| Actor | Qué hace en el sistema |
| :--- | :--- |
| **Vendedor** | Atiende al cliente y entrega el comprobante de la venta. |
| **Supervisor / Administrador** | Mira las consultas avanzadas y los informes para controlar cómo viene la tienda. |

En el modelo no hay una entidad `Vendedor` aparte: el vendedor es un `Usuario` cuyo rol está cargado en `Tipo_Usuario`.

---

## 2. Resumen de casos de uso

| Código | Caso de uso | Actor principal | Script | Requerimiento relacionado |
| :-: | :--- | :--- | :--- | :--- |
| CU-01 | Consultar ventas por encima del ticket promedio | Supervisor | Consulta_avanzada (consulta 1) | RF#10 |
| CU-02 | Analizar los medios de pago de los últimos 30 días | Supervisor | Consulta_avanzada (consulta 2) | RF#9, RF#10 |
| CU-03 | Ver el ranking de clientes que más gastaron | Supervisor | Consulta_avanzada (consulta 3) | RF#10 |
| CU-04 | Emitir comprobante de venta | Vendedor | comprobante_venta | RF#7, RF#8 |
| CU-05 | Generar informe de ventas por vendedor | Supervisor | informe_venta | RF#10 |

---

## 3. Detalle de cada caso de uso

### CU-01 — Consultar ventas por encima del ticket promedio

* **Actor:** Supervisor
* **Tablas que usa:** `Detalle_Venta`, `Cabecera_Factura`, `Cliente`, `Computadora`, `Procesador`, `Placa_Video`
* **Objetivo:** ver cuáles son las ventas grandes, las que superan el total promedio de todas las facturas.
* **Precondición:** haber iniciado sesión y tener ventas cargadas.
* **Flujo principal:**
  1. El supervisor pide la consulta.
  2. El sistema calcula el promedio del `total` de todas las facturas.
  3. Se queda con las facturas cuyo total es mayor a ese promedio.
  4. Por cada una muestra: número de factura, fecha, cliente (nombre y apellido), equipo vendido, modelo del procesador, placa de video y total.
  5. El resultado sale ordenado de la venta más grande a la más chica.
* **Flujos alternativos:**
  * Si la computadora no tiene placa de video dedicada (notebooks, All in One), en esa columna aparece "Integrada".
  * Si una factura tiene varias computadoras, aparece una fila por cada una, todas con el mismo total de la factura.
  * Si ninguna factura supera el promedio, la lista sale vacía.
* **Postcondición:** ninguna, es solo una consulta.

### CU-02 — Analizar los medios de pago de los últimos 30 días

* **Actor:** Supervisor
* **Tablas que usa:** `Tipo_Pago`, `Cabecera_Factura`, `Detalle_Venta`
* **Objetivo:** saber qué medios de pago están dejando tickets más altos que el promedio general en el último mes.
* **Precondición:** haber iniciado sesión.
* **Flujo principal:**
  1. El sistema toma como fecha de corte los 30 días anteriores a hoy.
  2. Filtra las facturas desde esa fecha y las agrupa por tipo de pago.
  3. Por cada medio calcula la cantidad de facturas, el monto total y el ticket promedio.
  4. Calcula también el promedio general de los subtotales de ese mismo período.
  5. Muestra solo los medios de pago cuyo ticket promedio supera al general, ordenados de mayor a menor.
* **Flujos alternativos:**
  * Si en los últimos 30 días no hubo ventas, no se muestra ningún medio de pago.
  * Los medios que no tuvieron ventas en el período no aparecen.
* **Postcondición:** ninguna, es solo una consulta.
* **Nota:** el ticket promedio se calcula sobre las líneas de detalle (`subtotal`), no sobre el total de cada factura. Como la fecha de corte depende del día en que se corra, el resultado cambia con el tiempo.

### CU-03 — Ver el ranking de clientes que más gastaron

* **Actor:** Supervisor
* **Tablas que usa:** `Cabecera_Factura`, `Detalle_Venta`, `Cliente`, `Computadora`, `Procesador`, `RAM`, `Almacenamiento`, `Placa_Video`, `Tipo_Pago`, `Usuario`
* **Objetivo:** identificar a los clientes que gastan más que el cliente promedio y ver qué compraron.
* **Precondición:** haber iniciado sesión y tener ventas cargadas.
* **Flujo principal:**
  1. El sistema calcula cuánto gastó cada cliente en total, el promedio entre clientes y el total general vendido por la tienda.
  2. Se queda solo con los clientes cuyo gasto supera ese promedio.
  3. Arma un ranking de mayor a menor gasto. Si dos clientes empatan, comparten posición y el siguiente no se saltea número.
  4. Por cada compra de esos clientes muestra: fecha, equipo, procesador (marca y modelo), memoria RAM (tipo y GB), almacenamiento en GB, placa de video, gama, subtotal, medio de pago y vendedor.
  5. En cada fila también muestra el total del cliente, cuánto se pasa del promedio y qué porcentaje representa del total vendido.
  6. El resultado sale ordenado por ranking y fecha.
* **Flujos alternativos:**
  * La gama se clasifica así: "Sin placa dedicada" si el equipo no tiene placa de video, "Gama alta" si la placa tiene 16 GB de VRAM o más, y "Gama media" en el resto de los casos.
  * Si ningún cliente supera el promedio, la lista sale vacía.
  * Un cliente sin compras no aparece.
* **Postcondición:** ninguna, es solo una consulta.

### CU-04 — Emitir comprobante de venta

* **Actor:** Vendedor
* **Tablas que usa:** `Cabecera_Factura`, `Detalle_Venta`, `Cliente`, `Usuario`, `Tipo_Pago`, `Computadora`
* **Objetivo:** darle al cliente el comprobante con el detalle de lo que compró.
* **Precondición:** la venta ya está registrada y se conoce el número de factura.
* **Flujo principal:**
  1. El vendedor indica el número de factura.
  2. El sistema busca la cabecera y todas sus líneas de detalle.
  3. Cruza los datos con el cliente, el usuario que hizo la venta, el tipo de pago y la computadora de cada línea.
  4. Muestra el encabezado: número de factura, fecha, nombre del cliente, nombre del usuario que atendió y tipo de pago.
  5. Por cada línea muestra: id del detalle, id y nombre de la computadora, cantidad, precio unitario, subtotal y total acumulado.
  6. El vendedor lo imprime o se lo pasa al cliente.
* **Flujos alternativos:**
  * Si el número de factura no existe, la consulta no devuelve filas.
  * Si la computadora no tiene nombre cargado (es un campo opcional), esa columna sale vacía.
* **Postcondición:** el cliente se lleva su comprobante.
* **Nota:** el precio unitario no se guarda en ninguna tabla, se calcula dividiendo el subtotal por la cantidad. El total acumulado va sumando línea por línea, así que en la última línea queda el total de la factura.

### CU-05 — Generar informe de ventas por vendedor

* **Actor:** Supervisor
* **Tablas que usa:** `Usuario`, `Cabecera_Factura`
* **Objetivo:** ver cuánto vendió cada vendedor desde el inicio del período hasta hoy.
* **Precondición:** haber iniciado sesión.
* **Flujo principal:**
  1. El sistema toma las facturas con fecha entre el 01/09/2026 y el día de hoy.
  2. Las agrupa por usuario.
  3. Por cada uno cuenta la cantidad de ventas y suma el total vendido.
  4. Muestra: id, nombre, apellido, cantidad de ventas y total vendido, ordenado de quien más vendió a quien menos.
* **Flujos alternativos:**
  * Los usuarios que no hicieron ninguna venta en el período no aparecen en el informe.
  * Si no hubo ventas en el período, el informe sale vacío.
* **Postcondición:** ninguna, es solo una consulta.
* **Nota:** la fecha de inicio está escrita a mano en el script. Para ver otro período hay que cambiarla.

---

## 4. Relación entre los casos de uso

* **CU-04** parte siempre de una venta que ya está registrada en `Cabecera_Factura` y `Detalle_Venta`.
* **CU-01, CU-02 y CU-03** leen esas mismas dos tablas y las cruzan con otras. La primera mira ventas sueltas, la segunda agrupa por medio de pago y la tercera agrupa por cliente.
* **CU-05** es el más liviano: solo cruza `Usuario` con `Cabecera_Factura` para resumir por vendedor.
