# Etapa 3 — Implementación de la Base de Datos

**Asignatura:** Bases de Datos I — FaCENA (UNNE)  
**Equipo:** 20  
**Pregunta que responde esta etapa:** *¿Cómo construimos la BD?*  
**Resultado:** scripts DDL (estructura) + DML (datos de prueba)

---

## 1. Objetivo de la etapa

En las etapas anteriores definimos **qué** tiene que guardar el sistema (etapa 1: caso, alcance, reglas de negocio y requerimientos) y **cómo se organiza** esa información (etapa 2: DER, modelo relacional y normalización a 3FN).

En esta etapa llevamos ese diseño a una base de datos real: escribimos el script que crea la base y sus tablas con todas sus restricciones (DDL) y el script que la carga con datos de prueba (DML). Este documento explica cómo está organizada la implementación, qué decisiones tomamos al pasar del modelo al SQL y en qué orden hay que ejecutar los scripts. Las pruebas que comprueban que la base funciona y cumple los requerimientos están en [`pruebas-validacion.md`](./pruebas-validacion.md).

---

## 2. Entorno de implementación

| Aspecto | Elección |
|---|---|
| Motor (SGBD) | Microsoft SQL Server |
| Lenguaje | T-SQL (Transact-SQL) |
| Herramienta sugerida | SQL Server Management Studio (SSMS) |
| Nombre de la base | `Venta_Computadoras` |

Elegimos SQL Server porque es el motor que usamos en la cátedra y porque cumple con el RNF#7 (base relacional, normalizada, manejada con SQL) y con el RNF#6 (corre de forma local en la red de la tienda, sin necesitar internet).

En los scripts usamos algunas características propias de T-SQL: `IDENTITY` para las claves autoincrementales, el separador de lotes `GO`, la función `LEN()` y los comodines `[^0-9]` dentro de `LIKE` para validar los DNI.

---

## 3. Estructura de los archivos

```
proyecto-bd1-equipo-20/
├── docs/
│   └── etapa-03/
│       ├── implementacion.md             ← este documento
│       ├── pruebas-validacion.md         ← pruebas y validación de la BD
│       └── Restricciones-Integridad.md   ← detalle de cada restricción por tabla
└── sql/
    ├── ddl/
    │   └── crear_bd.sql                  ← crea la base y las 14 tablas
    └── dml/
        └── datos_prueba.sql              ← carga los datos de prueba
```

Separamos DDL y DML en carpetas distintas para poder recrear la estructura sin datos, o volver a cargar los datos sin tocar la estructura.

---

## 4. Script DDL — `sql/ddl/crear_bd.sql`

### 4.1 Creación de la base

El script primero verifica si la base existe y, si no, la crea:

```sql
IF DB_ID(N'Venta_Computadoras') IS NULL
BEGIN
    CREATE DATABASE Venta_Computadoras;
END
GO

USE Venta_Computadoras;
GO
```

### 4.2 Orden de creación de las tablas

Una tabla que tiene una clave foránea solo se puede crear después de la tabla a la que referencia. Por eso el script sigue este orden:

| # | Tabla | Depende de |
|---|---|---|
| 1 | `Tipo_Usuario` | — |
| 2 | `Usuario` | `Tipo_Usuario` |
| 3 | `Cliente` | — |
| 4 | `Tipo_Pago` | — |
| 5 | `Cabecera_Factura` | `Cliente`, `Tipo_Pago`, `Usuario` |
| 6 | `Gabinete` | — |
| 7 | `Placa_Video` | — |
| 8 | `Almacenamiento` | — |
| 9 | `RAM` | — |
| 10 | `Fuente_Poder` | — |
| 11 | `Procesador` | — |
| 12 | `Placa_Madre` | — |
| 13 | `Computadora` | los 7 componentes (6 a 12) |
| 14 | `Detalle_Venta` | `Cabecera_Factura`, `Computadora` |

Cada `CREATE TABLE` va seguido de `GO`, así cada tabla se crea en su propio lote y, si una falla, el error es fácil de ubicar.

### 4.3 Tipos de datos elegidos

| Dato | Tipo | Por qué |
|---|---|---|
| Claves primarias | `INT IDENTITY` | Clave subrogada que el motor numera sola (1, 2, 3…). No hay que calcularla al insertar. |
| DNI (cliente y usuario) | `CHAR(8)` | Longitud fija; se guarda como texto para no perder ceros a la izquierda y porque no se hacen cuentas con él. |
| Importes (`total`, `subtotal`) | `DECIMAL(10,2)` | Precisión exacta con dos decimales. Evitamos `FLOAT` en dinero porque redondea. |
| Teléfono | `VARCHAR(16)` | Texto: puede llevar prefijos y no se opera matemáticamente. |
| Nombres, marcas, modelos | `VARCHAR(100)` | Longitud variable, solo ocupa lo que se usa. |
| Año, generación, núcleos | `SMALLINT` | Valores chicos; no hace falta un `INT`. |
| Velocidad del procesador | `DECIMAL(5,2)` | Ej.: 3.60 GHz, con precisión fija. |
| Medidas y frecuencias | `FLOAT` | Datos técnicos donde un redondeo mínimo no afecta. |
| Fecha de la venta | `DATE` | Solo necesitamos el día, no la hora. |
| Campo `RGB` | `VARCHAR(100)` | Guarda "Si" / "No". |

### 4.4 Restricciones de integridad

Todas las restricciones tienen nombre propio, siguiendo esta convención:

| Prefijo | Tipo de restricción | Ejemplo |
|---|---|---|
| `PK_` | Clave primaria | `PK_id_cliente` |
| `FK_` | Clave foránea | `FK_id_tipo_usuario` |
| `UQ_` | Unicidad | `UQ_dni_cliente` |
| `CHK_` | Validación (CHECK) | `CHK_stock` |

Ponerles nombre sirve para que, cuando una operación falla, el mensaje de error diga exactamente qué regla se violó, y para poder modificarlas o eliminarlas después sin tener que buscar el nombre que genera el motor.

El detalle tabla por tabla está en [`Restricciones-Integridad.md`](./Restricciones-Integridad.md). Acá resumimos las que implementan reglas de negocio de la etapa 1:

| Regla / requerimiento | Cómo lo implementamos |
|---|---|
| **RN02 / RF#2** — DNI de cliente único | `UQ_dni_cliente` + `CHK_dni_cliente` (8 dígitos numéricos) |
| **RN07** — Stock nunca negativo | `CHK_stock CHECK (stock >= 0)` en `Computadora` |
| **RN01** — Cada venta pertenece a un único cliente | `id_cliente NOT NULL` + `FK_id_cliente` en `Cabecera_Factura` |
| **RN06 / RF#7** — Cada venta la registra un único vendedor | `id_usuario NOT NULL` + `FK_id_usuario` en `Cabecera_Factura` |
| **RN09** — Una venta, un método de pago | `id_tipo_pago NOT NULL` + `FK_id_tipo_pago` en `Cabecera_Factura` |
| **RN03** — Relación muchos a muchos venta–producto | Tabla intermedia `Detalle_Venta` con FK a ambas |
| **RF#12** — DNI como usuario de acceso | `UQ_dni_usuario`, `UQ_nombre_usuario`, `CHK_dni_usuario` |
| **RF#13** — Tipo de usuario | `FK_id_tipo_usuario` hacia `Tipo_Usuario` |
| Montos y cantidades coherentes | `CHK_total`, `CHK_subtotal`, `CHK_cantidad` (> 0) |

---

## 5. Script DML — `sql/dml/datos_prueba.sql`

### Orden de carga

Los datos se insertan respetando las dependencias: primero las tablas que no referencian a ninguna otra y al final las que tienen claves foráneas. Si se invierte el orden, SQL Server rechaza el `INSERT` porque la FK apuntaría a un registro que todavía no existe.

1. `Tipo_Usuario` → `Usuario`
2. `Cliente`
3. Componentes: `Gabinete`, `Placa_Video`, `Almacenamiento`, `Procesador`, `Fuente_Poder`, `Placa_Madre`, `RAM`
4. `Tipo_Pago`
5. `Computadora`
6. `Cabecera_Factura` → `Detalle_Venta`

Como las claves son `IDENTITY` y la base se carga vacía, los ID se asignan en el orden de inserción (1, 2, 3…). Por eso las FK del DML usan esos números directamente.

---

## 6. Cómo ejecutar los scripts

1. Abrir SQL Server Management Studio y conectarse a la instancia local.
2. Abrir y ejecutar `sql/ddl/crear_bd.sql` (F5). Se crea la base `Venta_Computadoras` con sus 14 tablas.
3. Abrir y ejecutar `sql/dml/datos_prueba.sql`. Se cargan los datos de prueba.
4. Para comprobar la carga y las restricciones, seguir las pruebas de [`pruebas-validacion.md`](./pruebas-validacion.md).

> **Importante:** el DDL no borra las tablas antes de crearlas. Si la base ya existe con las tablas, el script falla con "There is already an object named…". Para empezar de cero hay que eliminar la base primero:
>
> ```sql
> USE master;
> GO
> DROP DATABASE IF EXISTS Venta_Computadoras;
> GO
> ```

---


