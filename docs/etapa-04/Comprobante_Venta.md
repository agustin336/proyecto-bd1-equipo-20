## 1. Introducción y Contexto del Problema

En los sistemas de gestión comercial y facturación, es común que la información esté normalizada y dividida en múltiples tablas relacionales (cabecera, detalles, clientes, usuarios, etc.). Para generar comprobantes o facturas detalladas, se requiere un mecanismo que consolide estos datos de forma eficiente y permita acceder a los datos de cada factura/comprobante de manera independiente. Para dicha necesidad se desarrollo y elaboro la sig. consulta.

---

## 2. Código de la Consulta Implementada

A continuación se presenta el script final estructurado para su ejecución y prueba en el SSMS:

```sql
USE Venta_Computadoras;
GO

DECLARE @id_factura INT = 1;

SELECT  
    cf.id_cabecera_factura, 
    cf.fecha, 
    c.nombre AS 'Nombre Cliente', 
    u.nombre AS 'Nombre Usuario', 
    tp.tipo AS 'Tipo de Pago', 
    dv.id_detalle_venta, 
    dv.id_computadora, 
    cm.nombre AS 'Nombre Computadora',
    dv.cantidad, 
    dv.subtotal / dv.cantidad AS 'Precio Unitario', 
    dv.subtotal, 
    
    SUM(dv.subtotal) OVER (
        ORDER BY dv.id_detalle_venta 
        ROWS UNBOUNDED PRECEDING
    ) AS 'Total Acumulado'

FROM Cabecera_Factura cf
INNER JOIN Detalle_Venta dv ON cf.id_cabecera_factura = dv.id_cabecera_factura
INNER JOIN Cliente c ON cf.id_cliente = c.id_cliente
INNER JOIN Usuario u ON cf.id_usuario = u.id_usuario
INNER JOIN Tipo_Pago tp ON cf.id_tipo_pago = tp.id_tipo_pago
INNER JOIN Computadora cm ON dv.id_computadora = cm.id_computadora
WHERE cf.id_cabecera_factura = @id_factura;
GO
```

---

## 3. Desglose y Explicación Técnica

### 3.1. Gestión de Contexto y Pruebas con Parámetros
* **`USE Venta_Computadoras; GO`**: Selecciona la base de datos activa sobre la cual se ejecutará la consulta.
* **`DECLARE @id_factura INT = 1;`**: Simula el uso de un parámetro de entrada. Esta técnica permite probar de forma local y dinámica cualquier factura con solo modificar el valor numérico, emulando el comportamiento futuro de un Procedimiento Almacenado (`Stored Procedure`).

### 3.2. Uniones Relacionales (`INNER JOIN`)
Para armar la vista completa del comprobante, la consulta interconecta seis tablas distintas:
1. **`Cabecera_Factura cf`**: Tabla principal de la venta (contiene fecha, IDs de cliente, usuario y tipo de pago).
2. **`Detalle_Venta dv`**: Contiene los renglones individuales de los productos asociados a la factura.
3. **`Cliente c`**: Cruza el identificador del cliente para obtener su nombre descriptivo.
4. **`Usuario u`**: Cruza el identificador del empleado/sistema para obtener el nombre del usuario responsable.
5. **`Tipo_Pago tp`**: Traduce el identificador de pago en una descripción legible (*tipo*).
6. **`Computadora cm`**: Cruza el identificador del producto en el detalle para extraer el nombre comercial del equipo.

### 3.3. Proyecciones y Cálculos por Renglón
* **`dv.subtotal / dv.cantidad AS 'Precio Unitario'`**: Deriva matemáticamente el valor unitario de la computadora a partir de los datos almacenados en el detalle.
* **`dv.subtotal`**: Muestra el valor total correspondiente estrictamente al renglón actual.

### 3.4. Cálculo del Total Acumulado (Función de Ventana)
```sql
SUM(dv.subtotal) OVER (
    ORDER BY dv.id_detalle_venta 
    ROWS UNBOUNDED PRECEDING
) AS 'Total Acumulado'
```
* **Qué realiza:** Calcula un acumulado progresivo renglón por renglón sin agrupar ni colapsar las filas individuales.
* **`ORDER BY dv.id_detalle_venta`**: Ordena lógicamente los ítems de la factura de manera secuencial.
* **`ROWS UNBOUNDED PRECEDING`**: Delimita el marco físico de la ventana para que sume estrictamente desde el primer renglón de la consulta hasta la línea actual evaluada.

---

## 4. Conclusión

Esta estructura resuelve consolidación del comprobante. A nivel de base de datos se entrega una estructura orientada a renglones con sus respectivos subtotales y acumulados, permitiendo que la futura capa de aplicación (interfaz de usuario) gestione fácilmente la presentación única del encabezado y la representación de los ítems y detalles de la venta.
