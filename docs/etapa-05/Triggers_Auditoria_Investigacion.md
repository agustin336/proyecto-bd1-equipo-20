# Informe de Investigación: Triggers de Auditoría en SQL Server

**Asignatura:** Bases de Datos I

**Tema:** Investigación previa para la implementación de auditoría mediante triggers en prosesos que involucran DML

## Introducción

En el marco del desarrollo de nuestro proyecto de software en el paradigma de bases de datos relacionales, resulta critico contar con un mecanismo que garantice la trazabilidad y la integridad de la información. Ante esta necesidad, se realiza la siguiente investigación sobre los **Triggers que corresponden al DML (Data Manipulation Language)** en SQL Server.

Entonces podemos definif que el objetivo de esta investigación es comprender la estructura, el funcionamiento y las mejores prácticas asociadas al uso de triggers de auditoría, asi mediante un análisis previo poder diseñar una estrategia sólida para registrar automáticamente las acciones realizadas sobre datos sensibles en nuestro sistema.

## Desarrollo y Fundamentos Teóricos

Un *trigger* (o, tambien conocido como, disparador) es un tipo especial de procedimiento almacenado que se ejecuta de forma automática cuando ocurre un evento específico dentro del motor de la base de datos. En el contexto de auditoría, se utilizan los **Triggers DML**, los cuales responden a las sentencias `INSERT`, `UPDATE` y `DELETE`.

### -Tablas Temporales en Memoria (`inserted` y `deleted`)

Para llevar a cabo la auditoría sin interferir manualmente con las consultas del usuario, SQL Server utiliza dos tablas especiales creadas temporalmente en memoria durante la transacción:

* **`inserted`:** Registra las filas nuevas que ingresan a la tabla (en sentencias `INSERT`) o las copias de las filas con los nuevos valores modificados (en sentencias `UPDATE`).
* **`deleted`:** Registra las filas que han sido removidas (en sentencias `DELETE`) o los valores originales antes de ser alterados (en sentencias `UPDATE`).

### -Comportamiento según la Operación DML

El trigger de auditoría debe evaluar cuál de las tres operaciones posibles ocurrió para registrar los datos adecuados:

1. **Operación `INSERT`:** Ocurre cuando se agregan nuevos registros. En esta situación, la tabla `deleted` se encuentra vacía, mientras que `inserted` contiene los nuevos datos. La auditoría captura principalmente la información entrante y el usuario responsable.
2. **Operación `DELETE`:** Ocurre cuando se eliminan registros. La tabla `inserted` permanece vacía, mientras que `deleted` guarda una copia de la información que existía antes del borrado. Esto permite conservar un historial de los datos destruidos.
3. **Operación `UPDATE`:** Conceptualmente, una actualización en SQL Server se procesa como un borrado seguido de un ingreso. Por ello, la tabla `deleted` almacena el valor anterior (estado viejo) y la tabla `inserted` guarda el valor nuevo (estado actualizado). Esto permite comparar el cambio exacto realizado en cada columna.

### -Estructura del Trigger

A continuación se presenta un esquema genérico de cómo se implementa la estructura un trigger (completo) en SQL Server (T-SQL):

```sql
CREATE TRIGGER trg_AuditarTablaEjemplo
ON TablaPrincipal
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Esta linea tiene como objetivo desactivar mensajes secundarios para optimizar el rendimiento
    SET NOCOUNT ON;

    -- 1. En caso de Insert
    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO TablaAuditoria (IdRegistro, Accion, Usuario, Fecha, ValorNuevo)
        SELECT Id, 'INSERT', SYSTEM_USER, GETDATE(), CampoAuditado
        FROM inserted;
    END

    -- 2. En caso de Delete
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO TablaAuditoria (IdRegistro, Accion, Usuario, Fecha, ValorAnterior)
        SELECT Id, 'DELETE', SYSTEM_USER, GETDATE(), CampoAuditado
        FROM deleted;
    END

    -- 3. En caso de Update
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO TablaAuditoria (IdRegistro, Accion, Usuario, Fecha, ValorAnterior, ValorNuevo)
        SELECT i.Id, 'UPDATE', SYSTEM_USER, GETDATE(), d.CampoAuditado, i.CampoAuditado
        FROM inserted i
        INNER JOIN deleted d ON i.Id = d.Id;
    END
END;
```

### -Aspectos Relevantes para la Fase de Implementación

* **Lógica basada en conjuntos:** SQL Server ejecuta el trigger una sola vez por cada sentencia ejecutada, no por cada fila afectada. Por lo tanto, el código dentro del trigger debe procesar múltiples registros a la vez utilizando operaciones de conjuntos (`JOIN`, `SELECT`) y evitando el uso de cursores.
* **Manejo de Transacciones:** El trigger se ejecuta dentro de la misma transacción que la sentencia original. Si el trigger falla (por ejemplo, por falta de permisos o errores de sintaxis en la tabla de auditoría), se realiza un `ROLLBACK` total, impidiendo que la acción principal se complete.

## -Conclusión

En coclusion, gracias a la investigación realizada podemos afirmar que los triggers para las sentencias que untilizan DML constituyen una herramienta muy potente y eficiente en muchos sentidos para implementar auditorías de manera transparente al usuario final y la aplicación. Entonces, comprendiendo asi que la interacción entre las tablas `inserted` y `deleted` es la clave para capturar de manera correcta los eventos de `INSERT`, `UPDATE` y `DELETE`. 

Con estos conceptos teóricos afianzados y la estructura genérica definida, consideramos que se cuenta con la preparación necesaria para proceder al diseño de las tablas definitivas e implementar los triggers de auditoría en nuestro proyecto de estudio.