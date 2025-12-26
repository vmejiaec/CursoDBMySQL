-- Consultas de la base de datos SaludTotal
use saludtotal;
select * from clientes;

select count(*) from clientes;

select count(*) from medicinas;

-- Caso: Consultar los datos de un cliente por su número de cédula
-- Ejemplo: 1000000041

select *
from clientes
where cedula = '1000000041';

select *
from clientes
where cedula = '9000000041';

-- Caso: Proyección. Consultar el email de un cliente por su cédula
select 
  email
from clientes
where cedula = '1000000041';

-SELECT
  nombre,
  email
from clientes
where cedula = '1000000041';

-- Caso: Consultar todos clientes cuyo nombre empiece por la letra A
SELECT
  cedula,
  nombre
from clientes
where nombre like 'A%';

SELECT
   id,
   nombre
from medicinas
where nombre like 'F%';

SELECT
  cedula,
  nombre
from clientes
where nombre like '%Herrera%';

-- Caso: buscar los clientes tipo NAT cuyos nombres contengan 'Juan'
use saludtotal;
select 
  cedula,
  nombre,
  tipo
from clientes
where 
  tipo = 'NAT'
  AND
  nombre like '%Juan%';

-- Caso: Buscar los clientes cuyo email tengo dominio en gmail y sean JUR
select 
  cedula,
  nombre,
  tipo,
  email
from clientes
where 
  tipo = 'JUR'
  AND
  email like '%gmail.com%';

-- Resultado de la carga de datos en medicinas frecuentes
use saludtotal;
select * from medicinafrecuente;

select count(*)
from medicinafrecuente;

-- Caso: Consultar los pacientes del plan de medicina frecuente
--       en una lista que incluya:
---      Nombre y cédula del paciente, nombre e Id de la medicina,
--       Descuento
use saludtotal;
select 
  cliente_cedula as cedula,
  (select nombre from clientes where cedula = cliente_cedula) as cliente,
  medicina_id as id,
  (select nombre from medicinas where id = medicina_id) as medicina,
  descuento
from
  medicinafrecuente;

-- caso: Listar los clientes y las medicinas que tienen un descuento menor 
--       al descuento del cliente con cédula '1000000010'
select 
  cliente_cedula as cedula,
  (select nombre from clientes where cedula = cliente_cedula) as cliente,
  medicina_id as id,
  (select nombre from medicinas where id = medicina_id) as medicina,
  descuento
from
  medicinafrecuente
where descuento < (
                  select descuento 
                  from medicinafrecuente
                  where cliente_cedula = '1000000010'
                );

-- Caso: Listado de pacientes del plan medicina frecuente
--       presente el precio final de la medicina junto
--       con el precio sin descuento


-- Caso: Las medicinas comerciales pueden ser reemplazadas por
--       sus correspondientes medicinas genéricas.
--       Elaborar un listado que compare el precio de la medicina comercial
--       con su equivalente genérico

-- Caso: Crear todas las combinaciones posibles entre la tabla
--       de clientes y la tabla de medicinafrecuente.
--       Producto Carteciano

use saludtotal;
select *
from 
   clientes,
   medicinafrecuente
where 
   clientes.cedula = medicinafrecuente.cliente_cedula;

select 
   c.cedula,
   c.nombre,
   m.nombre,
   mf.descuento,
   m.tipo
from
   clientes c,
   medicinas m,
   medicinafrecuente mf
where 
      m.id = mf.medicina_id 
  and c.cedula = mf.cliente_cedula
  and m.tipo = 'COM';
use saludtotal;
select 
   c.cedula,
   c.nombre,
   m.nombre,
   mf.descuento,
   m.tipo
from
   medicinafrecuente mf
join clientes c on c.cedula = mf.cliente_cedula
join medicinas m on m.id = mf.medicina_id 
where 
   m.tipo = 'COM';
use saludtotal;
select 
  mcom.id,
  mcom.nombre,
  mcom.precio,
  mcg.medicinagenerica_id,
  mgen.nombre,
  mgen.precio,
  mcom.precio - mgen.precio as diferencia
from
  medicinacomercialgenerica mcg
join medicinas mcom on mcom.id = mcg.medicinacomercial_id
join medicinas mgen on mgen.id = mcg.medicinagenerica_id
WHERE
      mcom.precio > 5
  and mgen.precio < 5
;

create view v_medicinagencom
as 
select 
  mcom.id,
  mcom.nombre as nombre_comercial,
  mcom.precio as precio_comercial,
  mcg.medicinagenerica_id,
  mgen.nombre as nombre_generico,
  mgen.precio as precio_generico,
  mcom.precio - mgen.precio as diferencia
from
  medicinacomercialgenerica mcg
join medicinas mcom on mcom.id = mcg.medicinacomercial_id
join medicinas mgen on mgen.id = mcg.medicinagenerica_id
WHERE
      mcom.precio > 5
  and mgen.precio < 5
;

-- Caso: Presentar una factura y sus detalles, que incluya,
--      Los datos de la farmacia: nombre, ruc, ...
--      Los del cliente: ...
--      Los datos de la cabecera de la factura: numero, fecha
--      Las medicinas vendidas: nombre medicina, id, cant, precio, subtotal
--      Los datos al pie de la factura: Total y la forma de pago

-- 1. Carga de datos en facturas cabecera y detalles
--    usar los datos ya existenes
-- 2. Select para cabera de factura 
-- 3. Select para los detalles de  factura
-- 4. Select para el pie factura. 

alter table facturas
drop column total;

use saludtotal;
desc facturas;
desc facturadetalle;

select count(*) from facturas;
select count(*) from facturadetalle;
-- Cabecera de la factura
select  
  f.facturanumero,
  f.fecha,
  c.nombre,
  c.telefono,
  c.direccion,
  c.email
from facturas f
join clientes c on c.cedula = f.cedula
where 
   facturanumero='F000000036';

-- Detalles de la factura
select
  fd.facturanumero,
  fd.medicamento_id,
  m.nombre,
  fd.precio,
  fd.cantidad,
  fd.precio * fd.cantidad as subtotal
from 
  facturadetalle fd
join medicinas m on m.id = fd.medicamento_id
where 
   fd.facturanumero = 'F000000036'

-- Pie de la factura
select
  sum(fd.precio * fd.cantidad) as subtotal
from 
  facturadetalle fd
join medicinas m on m.id = fd.medicamento_id
where 
   fd.facturanumero = 'F000000036';

SELECT 
  nombre
from 
  medicinas
where 
  tipo != 'GEN';

-- frecuencia ('SEM'.'DIA', 'QUI',MEN)
-- Mediante el uso de IN
select 
  *
FROM
  medicinafrecuente
where 
  frecuencia in ('SEM','MEN')
;
-- Mediante el uso de OR

select 
  *
FROM
  medicinafrecuente
where 
     frecuencia = 'SEM'
  OR frecuencia = 'MEN'
;

select * from v_medicinagencom;


select 
  cedula, 
  direccion 
from clientes
where 
   direccion is NOT null;
desc clientes;

update clientes
set direccion = NULL
where cedula in ('1000000008','1000000010','1000000012');

-- Consultar las medicinas declaradas en el plan de medicina frecuente
select count(*) from medicinas;
select count(*) from medicinafrecuente;
SELECT
  *
from medicinas m 
left join medicinafrecuente mf on m.id = mf.medicina_id
where mf.medicina_id is null;

SELECT
  *
from medicinafrecuente mf 
left join medicinas m   on m.id = mf.medicina_id;

-- Caso: Lista ordenada de clientes por nombre alfabético
use saludtotal;
select 
 nombre, 
 fechanacimiento
from 
  clientes
order BY
  fechanacimiento desc 
limit 1;

-- Caso: Conocer las cinco medicinas más caras de la farmacia
select
  nombre, 
  precio
from medicinas
order by 
  precio desc
limit 5;
-- Caso: Conocer las cinco medicinas más baratas de la farmacia
select
  nombre, 
  precio
from medicinas
order by 
  precio 
limit 5;
-- Caso: La medicina comercial más barata
select
  nombre, 
  precio
from medicinas
where
  tipo = 'COM'
order by 
  precio asc
limit 1;
-- Caso: La medicina genérica más cara
select
  nombre, 
  precio
from medicinas
where
  tipo = 'GEN'
order by 
  precio desc
limit 1;

-- Caso: Las cinco medicinas comerciales con el menor descuento
select
 id,
 nombre,
 descuento
from medicinafrecuente
join medicinas on id = medicina_id
where
      tipo = 'COM'
order by
  descuento
;

select 
  nombre
from medicinas
where 
  id  in (
        select
          id
        from medicinafrecuente
        join medicinas on id = medicina_id
        where
          tipo = 'COM'
        order by
          descuento
  );


-- Caso: agrupamientos

select 
 tipo,
 count(*) as Numero
from clientes
GROUP BY
  tipo
;

desc medicinas;

SELECT
  id,
  nombre,
  precio,
  stock,
  precio * stock
from medicinas;

select 
 tipo,
 sum(precio * stock)
from medicinas
GROUP BY
 tipo;

-- Caso: Facturas detalles. Valor monetario por medicina vendida

select 
 medicamento_id,
 cantidad,
 precio,
 cantidad * precio as subtotal
from facturadetalle
order by medicamento_id;

SELECT
 fd.medicamento_id,
 m.nombre,
 sum(fd.cantidad * fd.precio )
from facturadetalle fd
join medicinas m on m.id = fd.medicamento_id
GROUP BY
  medicamento_id
order by medicamento_id;

-- Caso: El mejor cliente. 
use saludtotal;
SELECT
 f.cedula,
 c.nombre,
 sum(fd.cantidad * fd.precio ) as facturatotal
from facturadetalle fd
join facturas f on f.facturanumero = fd.facturanumero
join clientes c on c.cedula = f.cedula
GROUP BY
  f.cedula
ORDER BY
 facturatotal desc
limit 1;

-- Caso: Proyección de la venta total del stock, tomando en cuenta
--       el descuento para las medicinas del plan de medicina frecuente

SELECT
  sum(precio * stock)
from medicinas;

create view v_proyeccion_ventas
as
select   -- Medicinas con descuento del plan
  mf.medicina_id,
  m.nombre,
  m.precio,
  m.stock,
  mf.descuento,  -- Descuento del plan
  m.precio * (1-mf.descuento/100) as nuevo_precio
from medicinafrecuente mf
join medicinas m on m.id = mf.medicina_id
UNION
select   -- Medicinas sin descuento no están en el plan
  mf.medicina_id,
  m.nombre,
  m.precio,
  m.stock,
  0.0 as descuento,  -- Sin descuento es descuento cero
  m.precio as nuevo_precio -- El precio final es igual al precio
from medicinafrecuente mf
right join medicinas m on m.id = mf.medicina_id
where mf.descuento is null
;

select
  sum(nuevo_precio * stock)
from
  v_proyeccion_ventas;

-- Caso: Averiguar qué medicinas vencen en el proximo mes.
select 
  id,
  nombre,
  fechacaducidad
from
  medicinas
where 
   fechacaducidad >= date_add(last_day( curdate()),interval 1 day)
   and  fechacaducidad <= 
              last_day(date_add (curdate(), INTERVAL 1 MONTH) )
order by
   fechacaducidad;


-- Caso: Cronograma de vencimiento de medicinas a tres meses vista


-- Caso: Kardex de la farmacia
--       De una medicina, quiero los movimientos de entrada y salida
--         - Stock inicial por período
--         - Compras, Alta por inventario, Donaciones, etc.
--         - Ventas, Bajas por inventario, Vencimiento, etc.
--       Resultado: stock final.
--       Método para valorar: PROMEDIO, FIFO y LIFO

use saludtotal;
drop view v_mov_ventas;
create view v_mov_ventas
as
select 
  f.fecha,
  fd.medicamento_id,
  m.nombre as medicina,
  f.facturanumero as documento,
  'Venta' as tipo_mov,
  sum(fd.cantidad)
     over (partition by fd.medicamento_id order by f.fecha) as acumulado,
  m.stock,
  fd.cantidad
from facturadetalle fd
join facturas f on f.facturanumero = fd.facturanumero
join medicinas m on m.id = fd.medicamento_id 
order BY
  f.fecha;

SELECT
  fecha,
  documento,
  tipo_mov,
  stock,
  cantidad,
  acumulado,
  stock - acumulado as saldo
from v_mov_ventas
where
  medicamento_id = 36;

-- Caso: Crear Proveedores
--       ruc, nombre, telefono, email    
-- Caso: Crear OrdenCompra
--       ordennumero, fecha, proveedor_ruc
-- Caso: Crear OredeCompreDetalle
--       ordennumero, medicamento_id, cantidad, costo

use SaludTotal;
create table proveedor(
  ruc char(13) PRIMARY key,
  nombre char(200) UNIQUE not NULL,
  telefono varchar(20),
  email varchar(100) unique
);

create table ordencompra(
  numero int primary key,
  proveedor_ruc char(13),
  fecha date
);

alter table ordencompra
add constraint ordencompra_proveedor_ruc_fk
foreign key (proveedor_ruc)
references proveedor(ruc);

drop table ordencompra_detalle;
create table ordencompra_detalle(
  ordennumero int,
  medicamento_id int,
  cantidad int,
  costo decimal(15,2)
);

alter table ordencompra_detalle
add constraint ordencompra_detalle_ordennumero_fk
foreign key (ordennumero)
references ordencompra(numero);
alter table ordencompra_detalle
add constraint ordencompra_detalle_medicamento_id_fk
foreign key (medicamento_id)
references medicinas(id);

alter table ordencompra_detalle
add primary key(ordennumero,medicamento_id);

select * from proveedor;

select * from ordencompra;

drop view v_mov_ventas;
create view v_mov_ventas
as
select 
  f.fecha,
  fd.medicamento_id,
  m.nombre as medicina,
  f.facturanumero as documento,
  'Venta' as tipo_mov,
  m.stock,
  fd.cantidad
from facturadetalle fd
join facturas f on f.facturanumero = fd.facturanumero
join medicinas m on m.id = fd.medicamento_id 
order BY
  f.fecha;
create view v_mov_compra
as
select 
  oc.fecha,
  ocd.medicamento_id,
  m.nombre as medicina,
  oc.numero as documento,
  'Compra' as tipo_mov,
  m.stock,
  ocd.cantidad
from ordencompra_detalle ocd
join ordencompra oc on oc.numero = ocd.ordennumero
join medicinas m on m.id = ocd.medicamento_id 
order BY
  oc.fecha;

create view v_movimientos
as
SELECT
 *
from v_mov_ventas
UNION
SELECT
 *
FROM v_mov_compra
ORDER BY fecha;

select
 fecha,
 medicamento_id,
  tipo_mov,
 documento,
 stock,
 cantidad,
 stock +
 sum(
   case tipo_mov
   when 'Venta' then -cantidad
   when 'Compra' then cantidad
   end
 ) over (partition by medicamento_id order by fecha) as saldo
FROM
  v_movimientos
where medicamento_id=36;