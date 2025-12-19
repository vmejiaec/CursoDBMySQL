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