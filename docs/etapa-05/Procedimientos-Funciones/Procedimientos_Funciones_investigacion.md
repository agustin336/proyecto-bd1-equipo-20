# Informe de Investigación: Procedimientos y Funciones en SQL Server

**Asignatura:** Bases de Datos I

**Tema:** Investigación previa para la implementación de Procedientos y Funciones que involucran DML

## Introducción

En esta investigación sobre los procedimientos y las funciones almacenadas en SQL Server, se analizarán sus estructuras, características y formas de ejecución. El objetivo es comprender su funcionamiento, identificar las diferencias entre ambas herramientas y reconocer las situaciones en las que resulta conveniente utilizar cada una. Mediante este análisis, buscamos adquirir los conocimientos necesarios para aplicar correctamente estos recursos durante el desarrollo de nuestro proyecto de software.

## Desarrollo y Fundamentos Teóricos

los Procedimientos almacenados (o, tambien conocido como, módulos almacenados persistentes) es un conjunto de instrucciones de SQL almacenadas como un objeto en el servidor de una base de datos al que un cliente puede recurrir simplemente llamando al procedimiento.Realizan un conjunto de operaciones (pueden insertar,actualizar, eliminar datos), pueden aceptar parámetros de entrada/salida y pueden o no devolver un conjunto de resultados.

las Funciones Almacenadas es un conjunto de instrucciones SQL que se guarda como un objeto dentro de la base de datos y que permite realizar una operación o cálculo a partir de parámetros de entrada siempre devuelven un único valor y se pueden usar en expresiones SQL (ej., en SELECT, WHERE).
Ambas funciones y procedimientos son tipos de instrucciones de SQL que pueden manejar parámetros (valores pasados a una instrucción cuando se invoca esa instrucción).

## 3. Algunas implementaciones en SQL Server

### 3.1. Funciones almacenadas

**Función `StockDisponible`**

Recibe el identificador de una computadora y devuelve su cantidad de stock. Utiliza `ISNULL()` para devolver cero cuando la consulta no encuentra un registro.

```sql
CREATE FUNCTION dbo.StockDisponible(@id_computadora INT)
RETURNS INT AS BEGIN
    RETURN ISNULL((
    SELECT stock
    FROM Computadora
    WHERE id_computadora = @id_computadora
    ),0);
END; 
GO
```

**Procedimiento `actualizarStock`**

Permite incrementar el stock de una computadora determinada. Recibe el identificador del producto y la cantidad que se desea agregar, validando que esta última sea mayor que cero.

```sql
CREATE PROCEDURE dbo.actualizarStock(@id_computadora INT,@cantidad INT)
AS BEGIN
    SET NOCOUNT ON;

    IF @cantidad <= 0
        THROW 50003, 'La cantidad debe ser mayor a cero.', 1;

    UPDATE Computadora
    SET Stock = Stock + @cantidad
    WHERE id_computadora = @id_computadora;

    IF @@ROWCOUNT = 0
        THROW 50004, 'La computadora no existe.', 1;
    PRINT 'El stock se actualizó correctamente.';
END;
GO
```

**Procedimiento `quitarComputadora`**

Permite eliminar una computadora determinada. Recibe el identificador del producto y la cantidad que se desea agregar, validando que esta última sea mayor que cero.

```sql
CREATE PROCEDURE dbo.quitarComputadora(@id_computadora INT)
AS BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Computadora
        WHERE id_computadora = @id_computadora
    )
        THROW 50002, 'La computadora no existe.', 1;

    DELETE FROM Computadora
    WHERE id_computadora = @id_computadora;

    PRINT 'Computadora eliminada correctamente.';
END;
GO
```

## 4. Resultados obtenidos en las pruebas

se realizaron las siguientes comprobaciones:

| **#** | **Prueba** | **Resultado esperado** | **Resultado obtenido** | **Evidencia** |
|---|---|---|---|---|
| 1 | Consulta de stock (computadora ID 1) | `StockDisponible(1)` devuelve el stock registrado para la computadora con ID 1. | La función devuelve el stock correspondiente al registro consultado. | [Resultados](Evidencias/Funcion_stockDisponible1.png) |
| 2 | Consulta de stock (computadora ID 2) | `StockDisponible(2)` devuelve el stock registrado para la computadora con ID 2. | La función devuelve el stock correspondiente al registro consultado. | [Resultados](Evidencias/Funcion_stockDisponible2.png) |
| 3 | Consulta de stock (ID inexistente: 98) | `StockDisponible(98)` devuelve el valor `0`. | La función devuelve `0`. | [Resultados](Evidencias/Funcion_stockDisponible1.png) |
| 4 | Actualización de stock (computadora ID 4, cantidad 3) | El procedimiento incrementa en 3 unidades el stock de la computadora con ID 4. | Se incrementa el stock en 3 unidades. | [Resultados](Evidencias/Procedimiento_actualizarStock.png) |
| 5 | Actualización de stock (computadora ID 4, cantidad 0) | El procedimiento genera el error 50003 y no modifica el stock. | El procedimiento rechaza la operación y no modifica el stock. | [Resultados](Evidencias/Procedimiento_actualizarStock3.png) |
| 6 | Eliminar computadora (ID 11) | Se elimina la computadora con ID 11. | La computadora se elimina correctamente. | [Resultados](Evidencias/Procedimiento_quitarComputadora.png) |
| 7 | Eliminar computadora (ID inexistente: 22) | No se elimina ningún registro y se informa que la computadora no existe. | El procedimiento devuelve el mensaje "La computadora no existe". | [Resultados](Evidencias/Procedimiento_quitarComputadora2.png) |

## Conclusión

A partir de la investigación y las pruebas realizadas, comprobamos que los procedimientos y las funciones almacenadas son herramientas fundamentales para organizar y administrar la información en SQL Server. Las funciones permiten realizar cálculos y consultas que devuelven resultados, mientras que los procedimientos facilitan la ejecución de operaciones como inserciones, modificaciones y eliminaciones de registros.
Asimismo, verificamos la importancia de incorporar validaciones para proteger la integridad de los datos. Consideramos que los conocimientos adquiridos nos permitirán aplicar estas herramientas en nuestro proyecto, favoreciendo la reutilización del código, la organización de las operaciones y el mantenimiento de la base de datos
