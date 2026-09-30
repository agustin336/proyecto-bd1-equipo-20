#### **EXPLICACION Y DETALLE DE LAS RESTRICCIONES-INTEGRIDAD DE CADA TABLA EN LA BD**



\-Estructura del documento:



Nombre De la Tabla

* restricción/integridad con su respectiva explicación y consideración
* ….
* ….



\-----------------------------------------------------------------------------------------------------------------------------------------------------------------------





###### **Tipo\_Usuario**

* `PK_id_tipo_usuario` (PRIMARY KEY en `id_tipo_usuario`): Garantiza la identificación única de cada rol de usuario en el sistema. Utiliza la propiedad `IDENTITY` para su incremento automático.
* `nombre_rol` (`NOT NULL`): Campo obligatorio que define la denominación del rol (por ejemplo, Administrador, Vendedor).





###### **Usuario**

* `PK_id_usuario` (PRIMARY KEY en `id\usuario`): Identificador único para cada usuario registrado en el sistema, con incremento automático (`IDENTITY`).
* `FK_id_tipo_usuario` (FOREIGN KEY en `id_tipo_usuario`): Relaciona al usuario con la tabla `Tipo_Usuario`, asegurando que el rol asignado exista previamente.
* `UQ_dni_usuario` (UNIQUE en `dni`): Evita que se registren dos usuarios con el mismo número de Documento Nacional de Identidad.
* `UQ_nombre_usuario` (UNIQUE en `nombre_usuario`): Asegura que el nombre de usuario (alias de login) sea único dentro del sistema.
* `CHK_dni_usuario` (CHECK): Valida que el DNI tenga exactamente 8 caracteres numéricos (`LEN(dni) = 8 AND dni NOT LIKE '%[^0-9]%'`), previniendo caracteres extraños o longitudes incorrectas.
* Campos obligatorios (`NOT NULL`): `dni`, `nombre_usuario`, `contrasena`, `email`, `nombre`, `apellido`, `telefono_contacto` y `id_tipo_usuario`.





###### **Cliente**

* `PK_id_cliente` (PRIMARY KEY en `id_cliente`): Clave primaria autoincremental para identificar de manera unívoca a cada cliente.
* `UQ_email` (UNIQUE en `email`): Garantiza que no existan dos clientes registrados con la misma dirección de correo electrónico.
* `UQ_dni_cliente` (UNIQUE en `dni`): Asegura la unicidad del DNI del cliente en la base de datos.
* `CHK_dni_cliente` (CHECK): Restringe el formato del DNI exigiendo una longitud exacta de 8 dígitos numéricos sin letras u otros símbolos.
* Campos obligatorios (`NOT NULL`): `email`, `nombre`, `apellido`, `dni`, `telefono_contacto`.





###### **Tipo\_Pago**

* `PK_id_tipo_pago` (PRIMARY KEY en `id_tipo_pago`): Identificador único y autoincremental para los diferentes métodos de pago disponibles (efectivo, tarjeta, transferencia, etc.).
* `tipo` (`NOT NULL`): Campo obligatorio que describe el nombre o modalidad del pago.



###### 

###### **Cabecera\_Factura**

* `PK_id_cabecera_factura` (PRIMARY KEY en `id_cabecera_factura`): Identificador único autoincremental para cada factura o comprobante de venta emitido.
* `FK_id_cliente` (FOREIGN KEY en `id_cliente`): Asegura que la factura esté asociada a un cliente válido existente en la tabla `Cliente`.
* `FK_id_tipo_pago` (FOREIGN KEY en `id_tipo_pago`): Garantiza que el método de pago seleccionado exista en la tabla `Tipo_Pago`.
* `FK_id_usuario` (FOREIGN KEY en `id_usuario`): Vincula la factura con el usuario/empleado que realizó la venta, asegurando su existencia.
* `CHK_total` (CHECK): Valida que el monto `total` de la factura sea estrictamente mayor a cero (`total > 0`).
* Campos obligatorios (`NOT NULL`): `fecha`, `total`, `id_cliente`, `id_tipo_pago`, `id_usuario`.





###### **Gabinete**

* `PK_id_gabinete` (PRIMARY KEY en `id_gabinete`): Identificador único autoincremental para cada chasis o gabinete de computadora.
* `CHK_altura` (CHECK): Asegura que la dimensión física de la `altura` sea mayor a cero (`altura > 0`).
* `CHK_ancho` (CHECK): Asegura que la dimensión física del `ancho` sea mayor a cero (`ancho > 0`).
* Campos obligatorios (`NOT NULL`): `altura`, `ancho`, `marca`, `modelo`, `RGB`.





###### **Placa\_Video**

* `PK_id_placa_video` (PRIMARY KEY en `id_placa_video`): Identificador único autoincremental para cada placa gráfica registrada.
* `CHK_cantidad_VRAM` (CHECK): Valida que la capacidad de memoria VRAM sea mayor a cero (`cantidad_VRAM > 0`).
* `CHK_anio` (CHECK): Asegura que el año de lanzamiento o fabricación sea un valor positivo mayor a cero (`anio > 0`).
* Campos obligatorios (`NOT NULL`): `cantidad_VRAM`, `tipo_VRAM`, `frecuencia_VRAM`, `marca`, `modelo`, `anio`.





###### **Almacenamiento**

* `PK_id_almacenamiento` (PRIMARY KEY en `id_almacenamiento`): Identificador único autoincremental para cada unidad de almacenamiento (SSD, HDD, etc.).
* `CHK_velocidad_lectura` (CHECK): Garantiza que la velocidad de lectura especificada sea un valor numérico positivo (`velocidad_lectura > 0`).
* Campos obligatorios (`NOT NULL`): `marca`, `velocidad\_lectura`, `tamano_gb`, `tipo`, `modelo`.



###### 

###### **RAM**

* `PK_id_RAM` (PRIMARY KEY en `id_RAM`): Identificador único autoincremental para cada módulo de memoria RAM.
* `CHK_cantidad_memoria` (CHECK): Valida que la cantidad de memoria en gigabytes sea mayor a cero (`cantidad_memoria > 0`).
* `CHK_frecuencia` (CHECK): Asegura que la frecuencia de la memoria RAM sea un valor positivo (`frecuencia > 0`).
* Campos obligatorios (`NOT NULL`): `tipo`, `cantidad\_memoria`, `frecuencia`, `marca`, `RGB`.





###### **Fuente\_Poder**

* `PK_id_fuente_poder` (PRIMARY KEY en `id_fuente_poder`): Identificador único autoincremental para cada fuente de alimentación.
* `CHK_Potencia_W` (CHECK): Verifica que la potencia en watts de la fuente sea mayor a cero (`frecuencia_W > 0`).
* Campos obligatorios (`NOT NULL`): `modelo`, `potencia_W`, `RGB`, `marca`.





###### **Procesador**

* `PK_id_procesador` (PRIMARY KEY en `id_procesador`): Identificador único autoincremental para cada CPU o procesador.
* `CHK_generacion` (CHECK): Controla que el número de generación del procesador sea mayor a cero (`generacion > 0`).
* `CHK_nucleos` (CHECK): Asegura que la cantidad de núcleos físicos sea mayor a cero (`nucleos > 0`).
* Campos obligatorios (`NOT NULL`): `marca`, `modelo`, `generacion`, `nucleos`, `velocidad`.





###### **Placa\_Madre**

* `PK_id_placa_madre` (PRIMARY KEY en `id_placa_madre`): Identificador único autoincremental para cada placa base (motherboard) disponible.
* Campos obligatorios (`NOT NULL`): `modelo`, `RGB`, `marca`.





###### **Computadora**

* `PK_id_computadora` (PRIMARY KEY en `id_computadora`): Identificador único autoincremental para cada equipo ensamblado o computadora armada.
* Claves foráneas de componentes (`FOREIGN KEY`):

  * `FK_id_gabinete`: Vincula con el gabinete correspondiente.
  * `FK_id_placa_video`: Vincula con la placa gráfica integrada/instalada.
  * `FK_id_almacenamiento`: Vincula con la unidad de almacenamiento.
  * `FK_id_RAM`: Vincula con el módulo de memoria RAM.
  * `FK_id_fuente_poder`: Vincula con la fuente de alimentación.
  * `FK_id_procesador`: Vincula con el procesador del equipo.
  * `FK_id_placa_madre`: Vincula con la placa madre del sistema.
Todas aseguran la existencia del componente respectivo en su tabla de origen.
* `CHK_stock` (CHECK): Permite almacenar cantidades de stock iguales o mayores a cero (`stock >= 0`), evitando existencias negativas pero permitiendo stock agotado.
* `CHK_tasa_refresco` (CHECK): Si se especifica, valida que la tasa de refresco sea mayor a cero (`tasa_refresco > 0`).
* Campos obligatorios (`NOT NULL`): `refrigeracion`, `stock`, `id_almacenamiento`, `id_RAM`, `id_fuente_poder`, `id_procesador`, `id_placa_madre`.





###### **Detalle\_Venta**

* `PK_id_detall\_venta` (PRIMARY KEY en `id_detalle_venta`): Identificador único autoincremental para cada ítem dentro del detalle de una venta.
* `FK_id_cabecera_factura` (FOREIGN KEY en `id_cabecera_factura`): Relaciona el detalle con su correspondiente cabecera de factura, garantizando integridad referencial.
* `FK_id_computadora` (FOREIGN KEY en `id_computadora`): Asegura que la computadora vendida exista en el catálogo de equipos.
* `CHK_cantidad` (CHECK): Valida que la cantidad de artículos vendidos en esa línea sea estrictamente mayor a cero (`cantidad > 0`).
* `CHK_subtotal` (CHECK): Controla que el monto del subtotal sea mayor a cero (`subtotal > 0`).
* Campos obligatorios (`NOT NULL`): `cantidad`, `subtotal`, `id_cabecera_factura`, `id_computadora`.

