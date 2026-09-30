#### **EXPLICACION Y DETALLE DE LAS RESTRICCIONES-INTEGRIDAD DE CADA TABLA EN LA BD**



\-Estructura del documento:



Nombre De la Tabla

* restricción/integridad con su respectiva explicación y consideración
* ….
* ….



\-----------------------------------------------------------------------------------------------------------------------------------------------------------------------





###### **Tipo\_Usuario**

* `PK\_id\_tipo\_usuario` (PRIMARY KEY en `id\_tipo\_usuario`): Garantiza la identificación única de cada rol de usuario en el sistema. Utiliza la propiedad `IDENTITY` para su incremento automático.
* `nombre\_rol` (`NOT NULL`): Campo obligatorio que define la denominación del rol (por ejemplo, Administrador, Vendedor).





###### **Usuario**

* `PK\_id\_usuario` (PRIMARY KEY en `id\_usuario`): Identificador único para cada usuario registrado en el sistema, con incremento automático (`IDENTITY`).
* `FK\_id\_tipo\_usuario` (FOREIGN KEY en `id\_tipo\_usuario`): Relaciona al usuario con la tabla `Tipo\\\_Usuario`, asegurando que el rol asignado exista previamente.
* `UQ\_dni\_usuario` (UNIQUE en `dni`): Evita que se registren dos usuarios con el mismo número de Documento Nacional de Identidad.
* `UQ\_nombre\_usuario` (UNIQUE en `nombre\_usuario`): Asegura que el nombre de usuario (alias de login) sea único dentro del sistema.
* `CHK\_dni\_usuario` (CHECK): Valida que el DNI tenga exactamente 8 caracteres numéricos (`LEN(dni) = 8 AND dni NOT LIKE '%\\\[^0-9]%'`), previniendo caracteres extraños o longitudes incorrectas.
* Campos obligatorios (`NOT NULL`): `dni`, `nombre\_usuario`, `contrasena`, `email`, `nombre`, `apellido`, `telefono\_contacto` y `id\_tipo\_usuario`.





###### **Cliente**

* `PK\_id\_cliente` (PRIMARY KEY en `id\_cliente`): Clave primaria autoincremental para identificar de manera unívoca a cada cliente.
* `UQ\_email` (UNIQUE en `email`): Garantiza que no existan dos clientes registrados con la misma dirección de correo electrónico.
* `UQ\_dni\_cliente` (UNIQUE en `dni`): Asegura la unicidad del DNI del cliente en la base de datos.
* `CHK\_dni\_cliente` (CHECK): Restringe el formato del DNI exigiendo una longitud exacta de 8 dígitos numéricos sin letras u otros símbolos.
* Campos obligatorios (`NOT NULL`): `email`, `nombre`, `apellido`, `dni`, `telefono\_contacto`.





###### **Tipo\_Pago**

* `PK\_id\_tipo\_pago` (PRIMARY KEY en `id\_tipo\_pago`): Identificador único y autoincremental para los diferentes métodos de pago disponibles (efectivo, tarjeta, transferencia, etc.).
* `tipo` (`NOT NULL`): Campo obligatorio que describe el nombre o modalidad del pago.



###### 

###### **Cabecera\_Factura**

* `PK\_id\_cabecera\_factura` (PRIMARY KEY en `id\_cabecera\_factura`): Identificador único autoincremental para cada factura o comprobante de venta emitido.
* `FK\_id\_cliente` (FOREIGN KEY en `id\_cliente`): Asegura que la factura esté asociada a un cliente válido existente en la tabla `Cliente`.
* `FK\_id\_tipo\_pago` (FOREIGN KEY en `id\_tipo\_pago`): Garantiza que el método de pago seleccionado exista en la tabla `Tipo\\\_Pago`.
* `FK\_id\_usuario` (FOREIGN KEY en `id\_usuario`): Vincula la factura con el usuario/empleado que realizó la venta, asegurando su existencia.
* `CHK\_total` (CHECK): Valida que el monto `total` de la factura sea estrictamente mayor a cero (`total > 0`).
* Campos obligatorios (`NOT NULL`): `fecha`, `total`, `id\_cliente`, `id\_tipo\_pago`, `id\_usuario`.





###### **Gabinete**

* `PK\_id\_gabinete` (PRIMARY KEY en `id\_gabinete`): Identificador único autoincremental para cada chasis o gabinete de computadora.
* `CHK\_altura` (CHECK): Asegura que la dimensión física de la `altura` sea mayor a cero (`altura > 0`).
* `CHK\_ancho` (CHECK): Asegura que la dimensión física del `ancho` sea mayor a cero (`ancho > 0`).
* Campos obligatorios (`NOT NULL`): `altura`, `ancho`, `marca`, `modelo`, `RGB`.





###### **Placa\_Video**

* `PK\_id\_placa\_video` (PRIMARY KEY en `id\_placa\_video`): Identificador único autoincremental para cada placa gráfica registrada.
* `CHK\_cantidad\_VRAM` (CHECK): Valida que la capacidad de memoria VRAM sea mayor a cero (`cantidad\_VRAM > 0`).
* `CHK\_anio` (CHECK): Asegura que el año de lanzamiento o fabricación sea un valor positivo mayor a cero (`anio > 0`).
* Campos obligatorios (`NOT NULL`): `cantidad\_VRAM`, `tipo\_VRAM`, `frecuencia\_VRAM`, `marca`, `modelo`, `anio`.





###### **Almacenamiento**

* `PK\_id\_almacenamiento` (PRIMARY KEY en `id\_almacenamiento`): Identificador único autoincremental para cada unidad de almacenamiento (SSD, HDD, etc.).
* `CHK\_velocidad\_lectura` (CHECK): Garantiza que la velocidad de lectura especificada sea un valor numérico positivo (`velocidad\_lectura > 0`).
* Campos obligatorios (`NOT NULL`): `marca`, `velocidad\_lectura`, `tamano\_gb`, `tipo`, `modelo`.



###### 

###### **RAM**

* `PK\_id\_RAM` (PRIMARY KEY en `id\_RAM`): Identificador único autoincremental para cada módulo de memoria RAM.
* `CHK\_cantidad\_memoria` (CHECK): Valida que la cantidad de memoria en gigabytes sea mayor a cero (`cantidad\_memoria > 0`).
* `CHK\_frecuencia` (CHECK): Asegura que la frecuencia de la memoria RAM sea un valor positivo (`frecuencia > 0`).
* Campos obligatorios (`NOT NULL`): `tipo`, `cantidad\_memoria`, `frecuencia`, `marca`, `RGB`.





###### **Fuente\_Poder**

* `PK\_id\_fuente\_poder` (PRIMARY KEY en `id\_fuente\_poder`): Identificador único autoincremental para cada fuente de alimentación.
* `CHK\_Potencia\_W` (CHECK): Verifica que la potencia en watts de la fuente sea mayor a cero (`frecuencia\_W > 0`).
* Campos obligatorios (`NOT NULL`): `modelo`, `potencia\_W`, `RGB`, `marca`.





###### **Procesador**

* `PK\_id\_procesador` (PRIMARY KEY en `id\_procesador`): Identificador único autoincremental para cada CPU o procesador.
* `CHK\_generacion` (CHECK): Controla que el número de generación del procesador sea mayor a cero (`generacion > 0`).
* `CHK\_nucleos` (CHECK): Asegura que la cantidad de núcleos físicos sea mayor a cero (`nucleos > 0`).
* Campos obligatorios (`NOT NULL`): `marca`, `modelo`, `generacion`, `nucleos`, `velocidad`.





###### **Placa\_Madre**

* `PK\_id\_placa\_madre` (PRIMARY KEY en `id\_placa\_madre`): Identificador único autoincremental para cada placa base (motherboard) disponible.
* Campos obligatorios (`NOT NULL`): `modelo`, `RGB`, `marca`.





###### **Computadora**

* `PK\_id\_computadora` (PRIMARY KEY en `id\\\_computadora`): Identificador único autoincremental para cada equipo ensamblado o computadora armada.
* Claves foráneas de componentes (`FOREIGN KEY`):

  * `FK\_id\_gabinete`: Vincula con el gabinete correspondiente.
  * `FK\_id\_placa\_video`: Vincula con la placa gráfica integrada/instalada.
  * `FK\_id\_almacenamiento`: Vincula con la unidad de almacenamiento.
  * `FK\_id\_RAM`: Vincula con el módulo de memoria RAM.
  * `FK\_id\_fuente\_poder`: Vincula con la fuente de alimentación.
  * `FK\_id\_procesador`: Vincula con el procesador del equipo.
  * `FK\_id\_placa\_madre`: Vincula con la placa madre del sistema.
Todas aseguran la existencia del componente respectivo en su tabla de origen.
* `CHK\_stock` (CHECK): Permite almacenar cantidades de stock iguales o mayores a cero (`stock >= 0`), evitando existencias negativas pero permitiendo stock agotado.
* `CHK\_tasa\_refresco` (CHECK): Si se especifica, valida que la tasa de refresco sea mayor a cero (`tasa\_refresco > 0`).
* Campos obligatorios (`NOT NULL`): `refrigeracion`, `stock`, `id\_almacenamiento`, `id\_RAM`, `id\_fuente\_poder`, `id\_procesador`, `id\_placa\_madre`.





###### **Detalle\_Venta**

* `PK\_id\_detalle\_venta` (PRIMARY KEY en `id\_detalle\_venta`): Identificador único autoincremental para cada ítem dentro del detalle de una venta.
* `FK\_id\_cabecera\_factura` (FOREIGN KEY en `id\_cabecera\_factura`): Relaciona el detalle con su correspondiente cabecera de factura, garantizando integridad referencial.
* `FK\_id\_computadora` (FOREIGN KEY en `id\_computadora`): Asegura que la computadora vendida exista en el catálogo de equipos.
* `CHK\_cantidad` (CHECK): Valida que la cantidad de artículos vendidos en esa línea sea estrictamente mayor a cero (`cantidad > 0`).
* `CHK\_subtotal` (CHECK): Controla que el monto del subtotal sea mayor a cero (`subtotal > 0`).
* Campos obligatorios (`NOT NULL`): `cantidad`, `subtotal`, `id\_cabecera\_factura`, `id\_computadora`.

