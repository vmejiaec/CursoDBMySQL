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