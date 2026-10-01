# Etapa III: Pruebas de Validación de Integridad

## 1. Cómo lo hicimos
La idea es simple: por cada restricción del DDL, armamos un `INSERT`, `UPDATE` o `DELETE` que la viola a propósito, y anotamos qué pasó realmente contra lo que debería haber pasado.

---

## 2. Matriz de Pruebas sobre Restricciones

### 2.1. Claves primarias y unicidad

| # | Restricción probada | Tabla | Dato de prueba | Resultado esperado | Resultado obtenido | Estado |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: |
| 1 | `UQ_dni_cliente` | Cliente | Insertar un cliente con un `dni` ya existente | Rechazo | Rechazo | OK |
| 2 | `UQ_email` | Cliente | Insertar un cliente con un `email` ya existente | Rechazo | Rechazo | OK |
| 3 | `UQ_dni_usuario` | Usuario | Insertar un usuario con un `dni` ya existente | Rechazo | Rechazo | OK |
| 4 | `UQ_nombre_usuario` | Usuario | Insertar un usuario con un `nombre_usuario` ya existente | Rechazo | Rechazo | OK |

### 2.2. Formato de datos (`CHECK` de dominio)

| # | Restricción probada | Tabla | Dato de prueba | Resultado esperado | Resultado obtenido | Estado |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: |
| 5 | `CHK_dni_cliente` | Cliente | DNI con letras (`"3011122A"`) | Rechazo | Rechazo | OK |
| 6 | `CHK_dni_cliente` | Cliente | DNI con menos de 8 dígitos (`"301112"`) | Rechazo | Rechazo | OK |
| 7 | `CHK_dni_usuario` | Usuario | DNI con 9 dígitos | Rechazo | Rechazo | OK |

### 2.3. Montos y cantidades positivas

| # | Restricción probada | Tabla | Dato de prueba | Resultado esperado | Resultado obtenido | Estado |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: |
| 8 | `CHK_total` | Cabecera_Factura | `total = 0` | Rechazo (exige estrictamente `> 0`) | Rechazo | OK |
| 9 | `CHK_cantidad` | Detalle_Venta | `cantidad = 0` | Rechazo | Rechazo | OK |
| 10 | `CHK_subtotal` | Detalle_Venta | `subtotal = 0` | Rechazo | Rechazo | OK |
| 11 | `CHK_stock` | Computadora | `stock = -1` | Rechazo | Rechazo | OK |

### 2.4. Restricciones dimensionales y técnicas de hardware

| # | Restricción probada | Tabla | Dato de prueba | Resultado esperado | Resultado obtenido | Estado |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: |
| 12 | `CHK_cantidad_VRAM` | Placa_Video | `cantidad_VRAM = 0` | Rechazo | Rechazo | OK |
| 13 | `CHK_anio` | Placa_Video | `anio = -1` | Rechazo | Rechazo | OK |
| 14 | `CHK_cantidad_memoria` | RAM | `cantidad_memoria = 0` | Rechazo | Rechazo | OK |
| 15 | `CHK_Potencia_W` | Fuente_Poder | `potencia_W = 0` | Rechazo | Rechazo | OK |
| 16 | `CHK_nucleos` | Procesador | `nucleos = 0` | Rechazo | Rechazo | OK |
| 17 | `CHK_tasa_refresco` | Computadora | `tasa_refresco = 0` (en un equipo que sí lo usa) | Rechazo | Rechazo | OK |

### 2.5. Integridad referencial (`FOREIGN KEY`)

| # | Restricción probada | Tabla | Dato de prueba | Resultado esperado | Resultado obtenido | Estado |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: |
| 18 | `FK_id_tipo_usuario` | Usuario | `id_tipo_usuario` inexistente (ej. `9999`) | Rechazo | Rechazo | OK |
| 19 | `FK_id_computadora` | Detalle_Venta | `id_computadora` inexistente | Rechazo | Rechazo | OK |
| 20 | Borrado de `Cliente` con facturas asociadas | Cliente | `DELETE` sobre un cliente con `Cabecera_Factura` cargada | Rechazo (por defecto `NO ACTION`, ya que no se declaró ninguna variante de `ON DELETE`) | Rechazo | OK |
| 21 | Borrado de `Cabecera_Factura` con detalle asociado | Cabecera_Factura | `DELETE` sobre una factura con `Detalle_Venta` cargado | Rechazo (mismo motivo que el punto anterior) | Rechazo | OK |

### 2.6. Atributos opcionales (prueba positiva, no de rechazo)

| # | Caso probado | Tabla | Dato de prueba | Resultado esperado | Resultado obtenido | Estado |
| :-: | :--- | :--- | :--- | :--- | :--- | :-: |
| 22 | Notebook sin `id_gabinete`, `id_placa_video` ni `id_fuente_poder` | Computadora | Insertar una notebook con esos tres campos en `NULL` | **Éxito** (son `NULL`-ables para contemplar notebooks/AIO) | Éxito | OK |
| 23 | Equipo sin tasa de refresco | Computadora | Insertar una PC de escritorio con `tasa_refresco = NULL` | Éxito | Éxito | OK |

---


## 3. Conclusión

De las 23 pruebas, todas las restricciones hicieron su trabajo y rechazaron el dato inválido cuando correspondía. El diseño físico resiste bien los casos límite probados, tanto en las restricciones de dominio como en la integridad referencial.
