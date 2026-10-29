# reporte de Conclusiónes en base a las pruebas

## -Introducción
Durante el desarrollo e implementación de las herramientas de auditoría en la base de datos **`Venta_Computadoras`**, el enfoque principal no fue solo almacenar transacciones, sino dotar al sistema de **trazabilidad y control activo**. El objetivo era que el sistema de información no solo debe permitir operar, sino también responder con precisión a preguntas clave: *¿Quién modificó este dato?, ¿Qué valor tenía antes?, ¿Cuándo ocurrió?* y *¿Qué acciones están totalmente prohibidas?*.

---

## - ¿Cómo operan los Triggers?
Uno de los aspectos más interesantes que pudimos comprobar durante las pruebas es cómo los **triggers (disparadores)** actúan de forma totalmente automatizada y transparente ("invisible") para la aplicación y el usuario final.

* **Sin tocar el código de la aplicación:** El usuario o el sistema operativo ejecuta un comando común de SQL (`UPDATE` o `DELETE`) sin enterarse de nada especial. Sin embargo, en milisegundos, el motor de la base de datos activa el trigger correspondiente.
* **Las tablas virtuales (`inserted` y `deleted`):** Comprendimos que el motor utiliza estas estructuras temporales en memoria RAM como una especie de "fotografía instantánea" del momento. No consumen espacio permanente en el disco ni saturan el sistema; capturan el estado anterior y nuevo de los datos, los vuelcan en nuestras tablas de auditoría con sufijo `_auditoria`, y desaparecen inmediatamente al finalizar la operación.

---

## -¿Qué nos mostraron las Pruebas de Funcionamiento?
Al ejecutar los scripts de prueba (insertando registros, modificando precios o stocks, y finalmente borrándolos), las tablas de auditoría reflejaron con total fidelidad el ciclo de vida de la información:

1. **En las Modificaciones (`UPDATE`):** Los triggers combinados ("todo en uno") lograron capturar con éxito el contraste exacto. Guardaron el valor viejo (*anterior*) y el valor actualizado (*nuevo*), registrando además automáticamente el usuario que realizó la acción (`SYSTEM_USER`) y la fecha exacta.
2. **En los Borrados (`DELETE`):** Funcionaron como una red de seguridad infalible. Ya sea en las tablas transaccionales o en los componentes de hardware (gabinetes, procesadores, memorias RAM), cada registro eliminado dejó una "foto" histórica antes de desaparecer para siempre de la tabla principal.

---

## -Seguridad Activa: El poder de detener una acción
Un logro importante en nuestras pruebas fue la implementación de restricciones de seguridad mediante un trigger de tipo **`INSTEAD OF DELETE`** (en la tabla `Usuario`). 

A diferencia de los triggers tradicionales que actúan *después* de que la orden está hecha, este enfoque intercepta dicha orden **antes** de que el motor toque los datos. 
* Mediante el uso de un mensaje personalizado (`RAISERROR`), logramos comunicarle claramente al usuario por qué la operación no era válida.
* Aprendimos también cómo opera el **`ROLLBACK TRANSACTION`** de forma implícita: al cancelar la transacción automática que crea SQL Server, garantizamos que ningún dato se corrompa y que la base de datos mantenga su integridad ante intentos no autorizados de borrado.

---

## -Reflexión Final
Al realizar el diseño e implementación de este esquema de auditoría entendimos que la seguridad y el control de los datos deben recaer principalmente en la propia **capa de base de datos** y no depender exclusivamente de la aplicación externa. 

Entonces, podemos decir que gracias a  el uso eficiente de triggers combinados y la validación estricta de reglas de negocio, el proyecto **`Venta_Computadoras`** cuenta ahora con un historial robusto, transparente y listo para garantizar la confiabilidad de cualquier entorno comercial real.