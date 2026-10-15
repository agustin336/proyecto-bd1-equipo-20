## 1. ¿Qué necesidad de información resuelve la consulta?
La consulta permite conocer cuántas ventas realizó cada vendedor y cuál fue el importe total vendido durante un período determinado. Esta información ayuda a la empresa a evaluar el desempeño de sus vendedores y comparar sus resultados.
## 2. ¿Qué estrategia SQL utiliza?
Utiliza las siguientes herramientas de SQL:
- INNER JOIN: relaciona las tablas usuario y cabecera_factura mediante el identificador del usuario, para saber qué vendedor realizó cada venta.
- WHERE y BETWEEN: filtran las ventas según un rango de fechas.
- GROUP BY: agrupa las ventas por vendedor.
- COUNT(): cuenta la cantidad de ventas realizadas por cada vendedor.
- SUM(): calcula el importe total vendido por cada vendedor.
- ORDER BY: ordena los resultados de mayor a menor según el importe total vendido.
## 3. ¿Qué resultado se espera?
Se espera obtener una tabla con una fila por cada vendedor que haya realizado ventas dentro del período seleccionado. La tabla mostrará su identificador, nombre, apellido, cantidad de ventas y total vendido.
Por ejemplo, utilizando los datos anteriormente cargados:
|Vendedor| Cantidad de ventas| Total vendido|
|:-:|:---:|---:|
|Carlos Torrez|4|$10.876.230|
|Carlos Lopez|2|$5.407.630|
|Luciana Diaz|1|$2.700.500|
|Lucas Ruiz|1|$2.407.060|

De esta manera, la empresa puede identificar qué vendedores realizaron más ventas y quiénes generaron mayores ingresos durante el período analizado.
