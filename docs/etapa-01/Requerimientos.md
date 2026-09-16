***Requerimientos Funcionales:***



* **RF#1 —** El sistema DEBE permitir registrar un nuevo cliente indicando nombre, apellido, código identificador (DNI/CUIT) y datos de contacto.
* **RF#2 —** El sistema DEBE validar que el código identificador (DNI/CUIT) de cada cliente sea único antes de confirmar el alta, rechazando duplicados.
* **RF#3 —** El sistema DEBE permitir registrar un producto indicando código identificador único, nombre, categoría (PC armada o Notebook), precio unitario y stock inicial.
* **RF#4 —** El sistema DEBE permitir consultar el catálogo de productos filtrando por categoría y mostrando el stock disponible de cada uno.
* **RF#5 —** El sistema DEBE impedir el registro de una venta cuando la cantidad solicitada de un producto supere el stock disponible.
* **RF#6 —** El sistema DEBE descontar automáticamente del stock la cantidad vendida de cada producto al confirmarse una venta.
* **RF#7 —** El sistema DEBE permitir registrar una venta asociada a un único cliente y a un único vendedor responsable de la operación.
* **RF#8 —** El sistema DEBE almacenar en el detalle de cada venta el precio unitario vigente del producto al momento de la operación, sin verse afectado por cambios posteriores en el precio de lista.
* **RF#9 —** El sistema DEBE permitir registrar uno o varios métodos de pago para una misma venta, validando que la suma de los montos ingresados coincida con el total de la venta.
* **RF#10 —** El sistema DEBE permitir consultar el historial de ventas filtrando por cliente, vendedor o rango de fechas.
* **RF#11 —** El sistema DEBE notificar cuando se alcanza el stock mínimo establecido para cada producto
* **RF#12 —** El sistema DEBE permitir registrar un nuevo usuario indicando nombre, apellido, DNI (utilizado como usuario de acceso) y numero de contacto y contraseña
* **RF#13 —** El sistema DEBE permitir asignarle un tipo de usuario a los usuarios registrados 
* **RF#14 —** El sistema DEBE permitir generar una solicitud para la reposición del stock en la tienda





***Requerimientos No Funcionales:***



* **RNF#1 (eficiencia — rendimiento) —** El sistema DEBE procesar el registro de una venta, incluyendo el descuento de stock, en un tiempo máximo de 2 segundos, considerando un uso simultáneo de hasta 5 puestos de trabajo dentro de la tienda.
* **RNF#2 (usabilidad) —** El sistema DEBE permitir que un vendedor complete el registro de una venta (cliente, productos y pago) en no más de 5 pasos dentro de la interfaz.
* **RNF#3 (fiabilidad) —** El sistema DEBE garantizar que ninguna venta confirmada quede sin su correspondiente descuento de stock, incluso ante un corte de energía o una caída de la red local durante la operación.
* **RNF#4 (seguridad) —** El sistema DEBE restringir el acceso a los datos de clientes y ventas únicamente al personal de la tienda autenticado con usuario y contraseña propios, sin exponer ninguna funcionalidad fuera de la red local.
* **RNF#5 (legislativo — privacidad) —** El sistema DEBE cumplir con la normativa vigente de protección de datos personales al almacenar los datos de clientes (DNI/CUIT, contacto).
* **RNF#6 (portabilidad) —** El sistema DEBE ejecutarse en las computadoras de la tienda dentro de la red local (LAN), sin requerir conexión a internet para registrar ventas o consultar stock.
* **RNF#7 (estándares — implementación) —** El sistema DEBE almacenar los datos en una base de datos relacional normalizada hasta la Tercera Forma Normal (3FN) y comunicarse con ella mediante algún tipo de lenguaje SQL.
* **RNF#8 (fiabilidad — respaldo) —** El sistema DEBE permitir generar una copia de seguridad local de la base de datos al menos una vez por día, para prevenir la pérdida de información ante una falla del equipo.
* **RNF#9 (eficiencia — espacio) —** El sistema DEBE soportar un catálogo de al menos 1.000 productos y un historial de 10.000 ventas anuales sin degradar el tiempo de respuesta de las consultas, acorde al volumen de un comercio local.    

