# Seguridad: permisos a nivel de usuarios y roles

## 1. Definición y objetivo

La seguridad de una base de datos controla **quién puede acceder** a la información y **qué operaciones puede realizar** sobre ella. SQL Server la organiza en dos niveles:

| Nivel | Objeto | Para qué sirve |
| :--- | :--- | :--- |
| Servidor | **Login** (inicio de sesión) | Permite conectarse a la instancia de SQL Server. |
| Base de datos | **Usuario** | Representa a ese login dentro de una base concreta. Los permisos se asignan al usuario. |
| Base de datos | **Rol** | Agrupa permisos. Un usuario que es miembro del rol recibe todos sus permisos. |

Los permisos se otorgan con `GRANT`, se quitan con `REVOKE` y se prohíben con `DENY`. Un usuario sin `GRANT` sobre un objeto no puede usarlo: el acceso está prohibido por defecto.

El objetivo de esta parte es aplicar el **principio de mínimo privilegio** al sistema de ventas: que cada perfil de `Tipo_Usuario` (Administrador, Supervisor y Vendedor) tenga solo los permisos que necesita para su tarea, y demostrar que el motor rechaza todo lo demás.

---

## 2. Ventajas y aplicaciones

**Ventajas**

- Protegen la información sensible (datos de clientes, facturación).
- Evitan modificaciones accidentales o no autorizadas.
- Asignan responsabilidades según el perfil de cada usuario.
- Los roles simplifican la administración: un vendedor nuevo recibe sus permisos con una sola instrucción (`ALTER ROLE ... ADD MEMBER`), en lugar de repetir cada `GRANT`.
- Combinados con procedimientos almacenados, permiten que un usuario realice una operación **solo de la forma autorizada**, con las validaciones del procedimiento, sin acceso directo a la tabla.

**Aplicaciones en un sistema de ventas**

Separar quién consulta el catálogo, quién registra ventas o mueve stock y quién administra la base; impedir que un usuario de consulta modifique precios o stock; exponer las operaciones de negocio solo a través de procedimientos.

---

## 3. Implementación en SQL Server Express

### 3.1. Sintaxis utilizada

```sql
-- Nivel servidor
CREATE LOGIN nombre WITH PASSWORD = 'Clave123*';

-- Nivel base de datos
CREATE USER nombre FOR LOGIN nombre;
CREATE ROLE nombre_rol;
ALTER ROLE nombre_rol ADD MEMBER nombre;      -- también para roles fijos: db_owner

-- Permisos
GRANT SELECT  ON dbo.Tabla         TO usuario_o_rol;
GRANT EXECUTE ON dbo.Procedimiento TO usuario_o_rol;
```

### 3.2. Encadenamiento de propiedad 
Cuando un procedimiento y las tablas que usa tienen el **mismo dueño** (en este caso `dbo`), SQL Server verifica el permiso `EXECUTE` sobre el procedimiento y **no vuelve a verificar** los permisos sobre las tablas. Por eso un usuario puede insertar a través del procedimiento aunque no tenga `INSERT` sobre la tabla. 

### 3.3. Cómo se prueba sin reconectarse

Las pruebas usan `EXECUTE AS LOGIN = 'nombre'`, que ejecuta las instrucciones siguientes con la identidad y los permisos de ese login, y `REVERT`, que vuelve a la identidad original. Así no hace falta habilitar la autenticación de SQL Server ni abrir una conexión por usuario. Un acceso denegado produce el **error 229** (*The ... permission was denied on the object ...*).

---

## 4. Caso concreto aplicado al sistema de ventas

Se crea un login y un usuario por cada perfil de `Tipo_Usuario`, más uno sin permisos que sirve de control:

| Usuario | Perfil | Permisos | Forma de asignación |
| :--- | :--- | :--- | :--- |
| `usuario_admin` | Administrador | Control total de la base | Miembro de `db_owner` (directo) |
| `usuario_supervisor` | Supervisor | `SELECT` sobre `Cabecera_Factura` y `Detalle_Venta`; `EXECUTE` sobre `agregarComputadora` y `actualizarStock` | Directo al usuario |
| `usuario_vendedor` | Vendedor | `SELECT` sobre `Computadora` y sus componentes | A través de `rol_vendedor` |
| `usuario_sin_rol` | — | Ninguno | — |


El supervisor no recibe `INSERT` ni `UPDATE` sobre `Computadora`: solo puede dar de alta equipos o reponer stock mediante los procedimientos `agregarComputadora` y `actualizarStock`, desarrollados en el tema *Procedimientos y funciones*. Este tema **no crea ni modifica** esos procedimientos; solo les asigna permisos.

---

## 5. Script de demostración y resultados obtenidos

**Scripts** ([`sql/temas_tecnicos/Seguridad/`](../../../sql/temas_tecnicos/Seguridad/)):

| Script | Contenido |
| :--- | :--- |
| [`01_logins_usuarios.sql`](../../../sql/temas_tecnicos/Seguridad/01_logins_usuarios.sql) | Logins y usuarios (se puede ejecutar varias veces) |
| [`02_permisos_usuarios.sql`](../../../sql/temas_tecnicos/Seguridad/02_permisos_usuarios.sql) | Parte 1: permisos directos a usuarios |
| [`03_permisos_roles.sql`](../../../sql/temas_tecnicos/Seguridad/03_permisos_roles.sql) | Parte 2: rol `rol_vendedor` y sus miembros |
| [`04_pruebas.sql`](../../../sql/temas_tecnicos/Seguridad/04_pruebas.sql) | 8 pruebas con `EXECUTE AS LOGIN`: permisos efectivos, estado antes y después y mensaje de resultado |
| [`99_limpieza.sql`](../../../sql/temas_tecnicos/Seguridad/99_limpieza.sql) | Borra datos de prueba, usuarios, rol y logins; reinicia el `IDENTITY` |

**Orden de ejecución:** `crear_bd.sql` → `datos_prueba.sql` → `implementacion_Procedimientos_Funciones.sql` → `01` → `02` → `03` → `04`. Al terminar, `99_limpieza.sql`.


### Integración con los triggers de auditoría

Los triggers del tema *Triggers de auditoría* registran el usuario con `SYSTEM_USER`. Si todas las operaciones se hacen con la cuenta del administrador, la auditoría siempre muestra el mismo nombre. Con logins separados por perfil, el `UPDATE` de stock de la prueba 7 queda registrado en `computadora_auditoria` como hecho por `usuario_supervisor`. La auditoría identifica a la persona responsable sin modificar el código de los triggers ni el del procedimiento.

---

## Conclusión

Las pruebas confirman que SQL Server aplica la negación de acceso por defecto: un usuario solo puede hacer lo que se le otorgó con `GRANT`. `usuario_vendedor` consulta el catálogo porque es miembro de `rol_vendedor`, mientras que `usuario_sin_rol`, sin ningún permiso, recibe el error 229 al intentar la misma consulta. La diferencia entre ambos es únicamente la pertenencia al rol, lo que muestra que los roles permiten administrar los accesos por perfil.

La comparación entre el `INSERT` directo y el procedimiento almacenado es el resultado central. `usuario_supervisor` no puede insertar ni modificar el stock directamente sobre `Computadora`, pero sí puede hacer ambas operaciones mediante `agregarComputadora` y `actualizarStock`. Por el encadenamiento de propiedad, el motor solo verifica el permiso `EXECUTE`, de modo que la tabla queda cerrada y la operación sigue disponible por la vía autorizada. Además, la prueba con stock negativo muestra que el permiso de ejecución no evita las validaciones del procedimiento: las reglas de negocio se cumplen siempre, sin importar quién ejecute la operación.

La separación de usuarios también mejora la trazabilidad. Con un login por perfil, los triggers de auditoría registran como responsable a `usuario_supervisor` y no a la cuenta del administrador, sin cambios en el código de los triggers ni del procedimiento. De esta forma, los temas de seguridad, procedimientos almacenados y auditoría se complementan: los permisos definen quién puede operar, los procedimientos definen cómo, y la auditoría deja constancia de lo que se hizo.
