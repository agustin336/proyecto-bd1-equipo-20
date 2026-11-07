# Sistema de Ventas para una Tienda de Computación

Base de datos relacional en SQL Server para gestionar las ventas de una tienda física de computación que comercializa PCs pre-armadas, notebooks y PCs All In One.

Trabajo práctico integrador de la cátedra **Bases de Datos I** (FaCENA, UNNE) — **Equipo 20**.

## Contenido

1. [Presentación y objetivo](#presentación-y-objetivo)
2. [Alcance](#alcance)
3. [Requerimientos y reglas de negocio](#requerimientos-y-reglas-de-negocio)
4. [Modelo de datos](#modelo-de-datos)
5. [Implementación física](#implementación-física)
6. [Consultas y casos de uso](#consultas-y-casos-de-uso)
7. [Temas técnicos (Etapa 5)](#temas-técnicos-etapa-5)
8. [Estado del proyecto](#estado-del-proyecto)
9. [Estructura del repositorio](#estructura-del-repositorio)
10. [Cómo ejecutar el proyecto](#cómo-ejecutar-el-proyecto)
11. [Decisiones y limitaciones conocidas](#decisiones-y-limitaciones-conocidas)
12. [Equipo](#equipo)

---

## Presentación y objetivo

El local atiende tanto a clientes minoristas como a pequeñas empresas que necesitan equipamiento informático. El sistema debe permitir gestionar el catálogo de productos y su stock disponible, registrar clientes y usuarios, procesar ventas (detallando productos, cantidades y precios) y admitir distintos métodos de pago.

**Objetivo del proyecto:** diseñar, normalizar e implementar una base de datos relacional que soporte el ciclo completo de operaciones de venta, garantizando la integridad referencial, la consistencia y la no redundancia de la información.

Más detalle en [`Descripcion-caso.md`](docs/etapa-01/Descripcion-caso.md).

## Alcance

El sistema contempla:

- Catálogo de productos.
- Gestión de stock disponible por producto.
- Registro y gestión de clientes.
- Registro de usuarios.
- Registro de ventas y su detalle (producto, cantidad y precio en cada detalle).
- Métodos de pago por venta.
- Vendedores/empleados asociados a cada venta.

Este repositorio cubre la **capa de datos**: documentación, modelo, scripts SQL, consultas y mecanismos técnicos del motor (procedimientos, transacciones, triggers, seguridad e índices). No incluye una aplicación ni una interfaz de usuario.

Documento completo: [`Alcance.md`](docs/etapa-01/Alcance.md).

## Requerimientos y reglas de negocio

| Documento | Contenido |
|---|---|
| [`Requerimientos.md`](docs/etapa-01/Requerimientos.md) | 14 requerimientos funcionales y 9 no funcionales |
| [`Reglas-negocio.md`](docs/etapa-01/Reglas-negocio.md) | Reglas que rigen las operaciones (un cliente puede tener varias compras, cada venta la registra un único vendedor, el stock nunca es negativo, etc.) |

## Modelo de datos

El modelo conceptual se construyó con **ERDPlus** (notación de P. Chen) y se transformó a un esquema relacional en **Tercera Forma Normal (3FN)**.

![Diagrama Entidad-Relación](docs/etapa-02/der/DER%20Proyecto%20BDD.jpg)

![Modelo relacional](docs/etapa-02/modelo-relacional/modelo-relacional.png)

### Entidades

El esquema tiene 14 tablas en dos módulos:

| Módulo | Tablas |
|---|---|
| Comercial, facturación y seguridad | `Cliente`, `Usuario`, `Tipo_Usuario`, `Tipo_Pago`, `Cabecera_Factura`, `Detalle_Venta` |
| Equipos y hardware | `Computadora`, `Gabinete`, `Placa_Video`, `Almacenamiento`, `RAM`, `Fuente_Poder`, `Procesador`, `Placa_Madre` |

La cantidad de tablas supera el rango de referencia de la consigna (6 a 10) porque cada componente de hardware es una entidad propia. Así se evitan atributos multivaluados y cada pieza se describe con sus características técnicas reales.

### Relaciones

Todas las relaciones son de uno a muchos (1:N):

- `Cliente`, `Usuario` y `Tipo_Pago` → `Cabecera_Factura`
- `Tipo_Usuario` → `Usuario`
- `Cabecera_Factura` → `Detalle_Venta`
- `Computadora` → `Detalle_Venta`
- Cada componente de hardware → `Computadora` (7 relaciones)

### Decisiones principales

- **Claves subrogadas:** todas las tablas usan un ID autoincremental como clave primaria. `DNI` y `Email` quedan como atributos únicos.
- **Cabecera y detalle separados:** una factura puede incluir varios ítems sin repetir los datos generales.
- **Atributos opcionales en `Computadora`:** nombre, marca y tasa de refresco admiten `NULL`, para representar tanto PCs armadas como notebooks y All In One.

### Documentación de la etapa

- [`decisiones-diseno.md`](docs/etapa-02/decisiones-diseno.md): justificación del DER, del pasaje al modelo relacional y de la normalización (1FN, 2FN y 3FN).
- [`modelo-relacional.md`](docs/etapa-02/modelo-relacional/modelo-relacional.md): definición de las tablas.
- [`modelo-relacional-3FN/`](docs/etapa-02/modelo-relacional/modelo-relacional-3FN/): versión del modelo en 3FN.
- DER editable: [`DER Proyecto BDD.erdplus`](docs/etapa-02/der/DER%20Proyecto%20BDD.erdplus).

## Implementación física

La base de datos se implementó en **Microsoft SQL Server** (T-SQL) con **SQL Server Management Studio**.

- **DDL:** [`crear_bd.sql`](sql/ddl/crear_bd.sql) crea la base `Venta_Computadoras` y sus 14 tablas con claves primarias, foráneas y restricciones `UNIQUE`, `CHECK` y `NOT NULL`.
- **DML:** [`datos_prueba.sql`](sql/dml/datos_prueba.sql) carga datos de prueba coherentes en todas las tablas.
- **Convención de nombres:** las restricciones tienen nombre propio, con prefijos `PK_`, `FK_`, `UQ_` y `CHK_`.
- **Validación:** se probaron 23 casos que violan o respetan las restricciones a propósito.

Documentación: [`implementacion.md`](docs/etapa-03/implementacion.md), [`Restricciones-Integridad.md`](docs/etapa-03/Restricciones-Integridad.md) y [`pruebas-validacion.md`](docs/etapa-03/pruebas-validacion.md).

## Consultas y casos de uso

| Consulta | Qué responde | Técnicas | Script | Documentación |
|---|---|---|---|---|
| Comprobante de venta | Encabezado y detalle de una factura, con subtotal por renglón y total acumulado | `INNER JOIN` de 6 tablas, función de ventana `SUM() OVER` | [`Comprobante_Venta.sql`](sql/consultas/Comprobante_Venta.sql) | [`Comprobante_Venta.md`](docs/etapa-04/Comprobante_Venta.md) |
| Informe de ventas | Cantidad de ventas y total vendido por vendedor | `JOIN`, `GROUP BY`, `COUNT`, `SUM` | [`informe_ventas.sql`](sql/consultas/informe_ventas.sql) | [`informe_ventas.md`](docs/etapa-04/informe_ventas.md) |
| Consulta avanzada | Ventas sobre el ticket promedio, medios de pago de los últimos 30 días y ranking de clientes con el perfil de su compra | `JOIN` de hasta 10 tablas, `LEFT JOIN`, `HAVING`, subconsultas, CTE, `DENSE_RANK`, `CASE` | [`consulta_avanzada.sql`](sql/consultas/consulta_avanzada.sql) | [`consulta-avanzada.md`](docs/etapa-04/consulta-avanzada.md) |

Los casos de uso que cubren estas consultas están en [`casos_de_uso.md`](docs/etapa-04/casos_de_uso.md).

## Temas técnicos (Etapa 5)

La Etapa 5 suma cinco mecanismos de SQL Server que hacen la solución más robusta. Cada tema tiene su investigación y sus capturas de prueba en `docs/etapa-05/` y sus scripts en `sql/temas_tecnicos/`.

| Tema | Qué se implementó | Documentación | Scripts |
|---|---|---|---|
| Procedimientos y funciones | 3 funciones y 3 procedimientos sobre stock, descuentos y catálogo | [`Procedimientos_Funciones_investigacion.md`](docs/etapa-05/Procedimientos-Funciones/Procedimientos_Funciones_investigacion.md) | [`Procedimientos-Funciones/`](sql/temas_tecnicos/Procedimientos-Funciones/) |
| Transacciones | Venta atómica (cabecera, detalle y descuento de stock) con 5 pruebas | [`investigacion.md`](docs/etapa-05/transacciones/investigacion.md) | [`transacciones/`](sql/temas_tecnicos/transacciones/) |
| Triggers de auditoría | 14 triggers de auditoría y un trigger que bloquea borrados | [`Triggers_Auditoria_Investigacion.md`](docs/etapa-05/Triggers_Auditoria/Triggers_Auditoria_Investigacion.md) y [`Coclusion_En_Base_A_Las_Pruebas.md`](docs/etapa-05/Triggers_Auditoria/Coclusion_En_Base_A_Las_Pruebas.md) | [`Triggers/`](sql/temas_tecnicos/Triggers/) |
| Seguridad | Logins, usuarios y un rol por perfil, con 8 pruebas de permisos | [`seguridad.md`](docs/etapa-05/Seguridad/seguridad.md) | [`Seguridad/`](sql/temas_tecnicos/Seguridad/) |
| Índices | Comparación de consultas sin índice, con índice agrupado y con índice de cobertura | [`optimizacion_indices.md`](docs/etapa-05/Optimizacion_consultas/optimizacion_indices.md) | [`Optimizacion_de_consultas/`](sql/temas_tecnicos/Optimizacion_de_consultas/) |

### Procedimientos y funciones

- **Funciones:** `CalcularDescuento` (importe de descuento según lo acumulado por el cliente: 10 % desde $2.500.000 y 15 % desde $3.000.000), `calcularTotalVendido` y `StockDisponible`.
- **Procedimientos:** `agregarComputadora` (rechaza stock negativo), `quitarComputadora` y `actualizarStock` (valida que la cantidad sea positiva y que la computadora exista).
- **Pruebas:** casos válidos y casos de error, documentados con capturas en [`Evidencias/`](docs/etapa-05/Procedimientos-Funciones/Evidencias/).
- **Scripts:** [`implementacion_Procedimientos_Funciones.sql`](sql/temas_tecnicos/Procedimientos-Funciones/implementacion_Procedimientos_Funciones.sql) y [`datos_prueba_procedimientos_funciones.sql`](sql/temas_tecnicos/Procedimientos-Funciones/datos_prueba_procedimientos_funciones.sql).

### Transacciones

- **Transacción de venta:** inserta la cabecera en `Cabecera_Factura`, el detalle en `Detalle_Venta` y descuenta el stock en `Computadora`, de modo que la operación se confirma completa o no se registra. La implementación es [`script.sql`](sql/temas_tecnicos/transacciones/script.sql), con un bloque de parámetros editable.
- **Cinco pruebas** en [`pruebas/`](sql/temas_tecnicos/transacciones/pruebas/):
  1. Venta correcta.
  2. Stock insuficiente (error 547 por `CHK_stock`).
  3. Error intencional con `THROW` después de los `INSERT`.
  4. Transacción anidada con `ROLLBACK` externo (`@@TRANCOUNT`).
  5. Rollback parcial con `SAVE TRANSACTION`.
- **Observación documentada:** los valores de `IDENTITY` no se revierten con un `ROLLBACK`.
- **Evidencias:** [`evidencias/`](docs/etapa-05/transacciones/evidencias/).

### Triggers de auditoría

- **Auditoría:** cada tabla tiene su tabla `*_auditoria`.
  - En siete tablas (`Tipo_Usuario`, `Usuario`, `Cliente`, `Tipo_Pago`, `Cabecera_Factura`, `Computadora` y `Detalle_Venta`) el trigger se dispara con `UPDATE` y `DELETE` y guarda el valor anterior, el valor nuevo, el usuario (`SYSTEM_USER`) y la fecha.
  - En las siete tablas de componentes de hardware (`Gabinete`, `Placa_Video`, `Almacenamiento`, `RAM`, `Fuente_Poder`, `Procesador` y `Placa_Madre`) se audita solo el `DELETE`.
- **Bloqueo:** un trigger `INSTEAD OF DELETE` sobre `Usuario` impide borrar usuarios y muestra un mensaje con `RAISERROR`.
- **Scripts:** [`Implementacion_Triggers_Auditoria.sql`](sql/temas_tecnicos/Triggers/Implementacion_Triggers_Auditoria.sql), [`Implementacion_Trigger_Con_Mensaje.sql`](sql/temas_tecnicos/Triggers/Implementacion_Trigger_Con_Mensaje.sql) y [`datos_prueba_triggers.sql`](sql/temas_tecnicos/Triggers/datos_prueba_triggers.sql).
- **Evidencias:** [`Evidencias/`](docs/etapa-05/Triggers_Auditoria/Evidencias/).

### Seguridad

- **Principio de mínimo privilegio:** un login y un usuario por cada perfil de `Tipo_Usuario` (`usuario_admin`, `usuario_supervisor` y `usuario_vendedor`), más `usuario_sin_rol`, que sirve de control y no tiene permisos.
- **Rol `rol_vendedor`:** da acceso de consulta al catálogo de computadoras y a sus componentes.
- **Supervisor:** no tiene `INSERT` ni `UPDATE` sobre `Computadora`; solo puede dar de alta equipos y reponer stock mediante los procedimientos `agregarComputadora` y `actualizarStock`, gracias al encadenamiento de propiedad.
- **Pruebas:** 8 pruebas con `EXECUTE AS LOGIN`, que incluyen accesos denegados (error 229) y la integración con la auditoría. Los scripts son [`01`](sql/temas_tecnicos/Seguridad/01_logins_usuarios.sql), [`02`](sql/temas_tecnicos/Seguridad/02_permisos_usuarios.sql), [`03`](sql/temas_tecnicos/Seguridad/03_permisos_roles.sql), [`04`](sql/temas_tecnicos/Seguridad/04_pruebas.sql) y [`99_limpieza.sql`](sql/temas_tecnicos/Seguridad/99_limpieza.sql).
- **Evidencias:** [`evidencias/`](docs/etapa-05/Seguridad/evidencias/).

### Optimización con índices

Se creó una tabla de prueba, `Factura_Historica`, con un millón de filas y la misma estructura que `Cabecera_Factura`, para no alterar los datos reales. La consulta por rango de fechas dio estos resultados:

| Escenario | Lecturas lógicas | Espacio reservado |
|---|:-:|:-:|
| Sin índice | 5.077 | 40.648 KB |
| Índice agrupado sobre `fecha` | 302 | 48.648 KB |
| Índice no agrupado con cobertura (`INCLUDE`) | 211 | 82.320 KB |

Los índices reducen las lecturas de forma notable, a cambio de más espacio y de un mayor costo en las escrituras. Script: [`optimizacion_indices.sql`](sql/temas_tecnicos/Optimizacion_de_consultas/optimizacion_indices.sql).

## Estado del proyecto

| Etapa | Pregunta que responde | Producto | Estado | Documentación |
|---|---|---|---|---|
| I. Requerimientos | ¿Qué necesita el negocio? | Requerimientos y reglas | ✅ Completa | [`docs/etapa-01`](docs/etapa-01) |
| II. Modelado | ¿Cómo representamos la información? | DER, modelo relacional y 3FN | ✅ Completa | [`docs/etapa-02`](docs/etapa-02) |
| III. Implementación | ¿Cómo construimos la BD? | DDL y DML | ✅ Completa | [`docs/etapa-03`](docs/etapa-03) |
| IV. Consultas | ¿Cómo obtenemos información? | SQL y casos de uso | ✅ Completa | [`docs/etapa-04`](docs/etapa-04) |
| V. Temas técnicos | ¿Cómo hacemos la solución más robusta? | Procedimientos y funciones, transacciones, triggers de auditoría, seguridad e índices | ✅ Completa | [`docs/etapa-05`](docs/etapa-05) |

## Estructura del repositorio

```
proyecto-bd1-equipo-20/
├── docs/
│   ├── etapa-01/
│   │   ├── Descripcion-caso.md
│   │   ├── Alcance.md
│   │   ├── Reglas-negocio.md
│   │   └── Requerimientos.md
│   ├── etapa-02/
│   │   ├── der/                      ← DER (.erdplus y .jpg)
│   │   ├── modelo-relacional/        ← modelo relacional (.md, .png y versión 3FN)
│   │   └── decisiones-diseno.md
│   ├── etapa-03/
│   │   ├── implementacion.md
│   │   ├── Restricciones-Integridad.md
│   │   └── pruebas-validacion.md
│   ├── etapa-04/
│   │   ├── casos_de_uso.md
│   │   ├── Comprobante_Venta.md
│   │   ├── informe_ventas.md
│   │   └── consulta-avanzada.md
│   └── etapa-05/
│       ├── Optimizacion_consultas/
│       │   └── optimizacion_indices.md
│       ├── Procedimientos-Funciones/
│       │   ├── Procedimientos_Funciones_investigacion.md
│       │   └── Evidencias/
│       ├── Seguridad/
│       │   ├── seguridad.md
│       │   └── evidencias/
│       ├── Triggers_Auditoria/
│       │   ├── Triggers_Auditoria_Investigacion.md
│       │   ├── Coclusion_En_Base_A_Las_Pruebas.md
│       │   └── Evidencias/
│       └── transacciones/
│           ├── investigacion.md
│           └── evidencias/
├── sql/
│   ├── ddl/crear_bd.sql
│   ├── dml/datos_prueba.sql
│   ├── consultas/
│   │   ├── Comprobante_Venta.sql
│   │   ├── informe_ventas.sql
│   │   └── consulta_avanzada.sql
│   └── temas_tecnicos/
│       ├── Optimizacion_de_consultas/
│       │   └── optimizacion_indices.sql
│       ├── Procedimientos-Funciones/
│       │   ├── implementacion_Procedimientos_Funciones.sql
│       │   └── datos_prueba_procedimientos_funciones.sql
│       ├── Seguridad/
│       │   ├── 01_logins_usuarios.sql
│       │   ├── 02_permisos_usuarios.sql
│       │   ├── 03_permisos_roles.sql
│       │   ├── 04_pruebas.sql
│       │   └── 99_limpieza.sql
│       ├── Triggers/
│       │   ├── Implementacion_Triggers_Auditoria.sql
│       │   ├── Implementacion_Trigger_Con_Mensaje.sql
│       │   └── datos_prueba_triggers.sql
│       └── transacciones/
│           ├── script.sql
│           └── pruebas/              ← 01 a 05 y 99_limpieza.sql
└── README.md
```

## Cómo ejecutar el proyecto

**Requisitos:** Microsoft SQL Server y SQL Server Management Studio.

1. Ejecutar [`sql/ddl/crear_bd.sql`](sql/ddl/crear_bd.sql). Crea la base `Venta_Computadoras` y sus tablas.
2. Ejecutar [`sql/dml/datos_prueba.sql`](sql/dml/datos_prueba.sql). Carga los datos de prueba.
3. Ejecutar los scripts de [`sql/consultas/`](sql/consultas/) a gusto. Todos comienzan con `USE Venta_Computadoras;`.
4. Ejecutar los scripts de [`sql/temas_tecnicos/`](sql/temas_tecnicos/), de a un tema por vez y en este orden:

| Tema | Orden de ejecución |
|---|---|
| Procedimientos y funciones | `implementacion_Procedimientos_Funciones.sql` → `datos_prueba_procedimientos_funciones.sql` |
| Triggers | `Implementacion_Triggers_Auditoria.sql` → `datos_prueba_triggers.sql` → `Implementacion_Trigger_Con_Mensaje.sql` (último, porque bloquea el borrado de usuarios) |
| Seguridad | Requiere los procedimientos ya creados. `01` → `02` → `03` → `04` → `99_limpieza.sql` |
| Transacciones | `pruebas/01` a `pruebas/05`, en orden, y por último `pruebas/99_limpieza.sql` |
| Índices | `optimizacion_indices.sql` (crea la tabla independiente `Factura_Historica`) |

> **Importante:** los scripts de prueba de la Etapa 5 modifican datos y cada tema espera cierto estado inicial. Por ejemplo, las pruebas de transacciones parten de stock 5 y 14 en las computadoras 1 y 2, y el script de datos de procedimientos suma stock a las computadoras 1 y 7. Además, los scripts de implementación de procedimientos y de triggers usan `CREATE` y no se pueden ejecutar dos veces sobre la misma base.
>
> Para reproducir los resultados documentados, conviene recrear la base antes de cada tema (eliminándola primero, como se indica más abajo, y repitiendo los pasos 1 y 2) o usar los scripts de limpieza. La limpieza de transacciones reinicia los contadores `IDENTITY` a 8, lo cual es correcto sobre una base recién creada (con ids desde 1).

El DDL no borra las tablas existentes. Para empezar de cero, hay que eliminar la base antes de volver a ejecutarlo:

```sql
USE master;
GO
DROP DATABASE IF EXISTS Venta_Computadoras;
GO
```

## Decisiones y limitaciones conocidas

- **Precio unitario:** no se guarda como columna. El comprobante lo calcula como `subtotal / cantidad`.
- **Medios de pago:** cada venta admite un único medio de pago, según la regla de negocio RN09.
- **Notebooks y All In One:** `Computadora` permite `NULL` en gabinete, placa de video y fuente de poder para estos equipos.
- **Reglas de stock:** la transacción de venta demuestra el descuento de stock y el rechazo de ventas sin stock suficiente (RF#5 y RF#6), pero como script y no como un procedimiento integrado. El aviso de stock mínimo (RF#11) y la solicitud de reposición (RF#14) no se implementaron.
- **Transacción de venta:** las pruebas registran un ítem por venta.
- **Auditoría:** los triggers registran `UPDATE` y `DELETE`, pero no `INSERT`; en las tablas de componentes de hardware solo se audita el `DELETE`.
- **Trigger de bloqueo:** impide eliminar usuarios. Para borrar datos de prueba de `Usuario` hay que desactivarlo antes con `DISABLE TRIGGER`.
- **Seguridad:** las contraseñas de los logins del script son de demostración, y `99_limpieza.sql` elimina logins, usuarios y rol.
- **Fechas de prueba:** los datos de prueba son de septiembre de 2026, y las consultas con filtro relativo (últimos 30 días) devuelven resultados distintos según el día en que se ejecutan.

## Equipo

**Equipo 20** — Bases de Datos I, FaCENA, UNNE.

| Integrante | DNI |
|---|---|
| Ian Ivan Alexey Stach | 46243784 |
| Thiago Alvadero | 46149363 |
| Lucas Kruzolek | 39637375 |
| Agustin Valenzuela | 45097979 |
| Federico Alejandro Zini | 46380885 |
