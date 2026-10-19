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
7. [Estado del proyecto](#estado-del-proyecto)
8. [Estructura del repositorio](#estructura-del-repositorio)
9. [Cómo ejecutar el proyecto](#cómo-ejecutar-el-proyecto)
10. [Decisiones y limitaciones conocidas](#decisiones-y-limitaciones-conocidas)
11. [Equipo](#equipo)

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

Este repositorio cubre la **capa de datos**: documentación, modelo, scripts SQL y consultas. No incluye una aplicación ni una interfaz de usuario.

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

## Estado del proyecto

| Etapa | Pregunta que responde | Producto | Estado | Documentación |
|---|---|---|---|---|
| I. Requerimientos | ¿Qué necesita el negocio? | Requerimientos y reglas | ✅ Completa | [`docs/etapa-01`](docs/etapa-01) |
| II. Modelado | ¿Cómo representamos la información? | DER, modelo relacional y 3FN | ✅ Completa | [`docs/etapa-02`](docs/etapa-02) |
| III. Implementación | ¿Cómo construimos la BD? | DDL y DML | ✅ Completa | [`docs/etapa-03`](docs/etapa-03) |
| IV. Consultas | ¿Cómo obtenemos información? | SQL y casos de uso | ✅ Completa | [`docs/etapa-04`](docs/etapa-04) |
| V. Temas técnicos | ¿Cómo hacemos la solución más robusta? | Procedimientos y funciones, transacciones, triggers de auditoría, seguridad e índices | ⏳ Pendiente | — |

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
│   └── etapa-04/
│       ├── casos_de_uso.md
│       ├── Comprobante_Venta.md
│       ├── informe_ventas.md
│       └── consulta-avanzada.md
├── sql/
│   ├── ddl/crear_bd.sql
│   ├── dml/datos_prueba.sql
│   └── consultas/
│       ├── Comprobante_Venta.sql
│       ├── informe_ventas.sql
│       └── consulta_avanzada.sql
└── README.md
```

## Cómo ejecutar el proyecto

**Requisitos:** Microsoft SQL Server y SQL Server Management Studio.

1. Ejecutar [`sql/ddl/crear_bd.sql`](sql/ddl/crear_bd.sql). Crea la base `Venta_Computadoras` y sus tablas.
2. Ejecutar [`sql/dml/datos_prueba.sql`](sql/dml/datos_prueba.sql). Carga los datos de prueba.
3. Ejecutar los scripts de [`sql/consultas/`](sql/consultas/) a gusto. Todos comienzan con `USE Venta_Computadoras;`.

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
- **Reglas de stock:** el descuento automático, el stock mínimo y la reposición (RF#5, RF#6, RF#11 y RF#14) requieren lógica procedural y quedan para evaluar en la Etapa 5.
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
