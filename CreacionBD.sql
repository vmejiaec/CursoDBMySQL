-- Creación de la base de datos del sistema SaludTotal
--
-- Creación de la base de datos  
drop database saludtotal;
create database SaludTotal;
-- Confirmar la creación de la nueva base
show databases;
use SaludTotal;
-- Creación de las tablas
-- Crear tabla de medicinas
create table medicinas
(
    id  int primary key,  
    nombre VARCHAR(100), 
    tipo char(3),  -- GEN - Genérico   COM - Comercial
    precio decimal(15,2), 
    stock int, 
    fechacaducidad datetime
);

show tables;
desc medicinas;

-- Carga de datos iniciales
insert into medicinas
values (1, 'Paracetamol', 'GEN', 
   1.50, 12, 
   '2026-01-01 00:00:00');

insert into medicinas
values (2, 'Acetaminofen', 'GEN', 
   0.56, 23, 
   '2027-01-01 00:00:00');
insert into medicinas
values (3, 'Finalin', 'COM', 
   2.75, 43, 
   '2028-01-01 00:00:00');
insert into medicinas
values (12,'Losartan','GEM', 3.43,12,'2028-01-01 00:00:00');


select * from medicinas;

-- crear la entidad clientes
create table clientes(
    cedula CHAR(10) PRIMARY key,
    nombre VARCHAR(100),
    tipo char(3), -- NAT persona natural , JUR persona jurídica
    fechanacimiento date
);
use saludtotal;
alter table clientes
add column email varchar(20);
alter table clientes
add column telefono varchar(14);
alter table clientes
add column direccion varchar(100);

desc clientes;
delete from clientes;
insert into clientes
values('1800000000', 'Juanito', 'NAT','2000-01-01', 
'juan34@daf.com','0998987687', 'Amazonas E34-S3');
insert into clientes
values('1800000001', 'María', 'NAT','2003-01-01', 
'mariaec@daf.com','099898333', 'Carrión E34-S3');
insert into clientes
values('1800000002', 'Marco', 'NAT','2005-01-01', 
'marcoggg@daf.com','0998987111', 'Av. 10 de Agosto E34-S3');

update clientes
set email='juan34@er.com'
where cedula = '1800000000';

select * from clientes;

use saludtotal;
-- Creación de la tabla para medicina frecuente
create table medicinafrecuente
(
   cliente_cedula char(10),
   medicina_id int,
   condicion varchar(100),
   frecuencia char(3), -- SEM - semanal , MEN - mensual, CRI - Crisis
   descuento decimal(5,2)  -- 123,45
);
-- Añadir la validación de clave foranea a la cedula del cliente
alter table medicinafrecuente
add CONSTRAINT clientecedula_fk
foreign key (cliente_cedula)
references clientes(cedula);
-- Añadir la validación de clave foranea de la medicina id
alter table medicinafrecuente
add constraint medicinaid_fk
Foreign Key (medicina_id) 
REFERENCES medicinas(id);
-- Añadir la validación de clave primaria de cedula y la medicinaId
alter table medicinafrecuente
add primary key (cliente_cedula, medicina_id);

show databases;


desc medicinafrecuente;

insert into medicinafrecuente
values (
   '1800000000',
   1,
   'Diabetes',
   'SEM',
   0.25
);
use saludtotal;
select * from medicinafrecuente;

use saludtotal;
-- Creación de la tabla datos de la empresa
create table empresa(
   ruc char(13),
   razonsocial varchar(100),
   direccion varchar(100),
   telefono varchar(14),
   email VARCHAR(25)
);

insert into empresa values('1712312345001', 'Salud Total S.A.', 'Av. 10 de Agosto S/N','099123456788','sanatotal@sana.com');

select * from empresa;

-- Creación de las tablas de facturas y factrurasdetalle

create table facturas(
   facturanumero char(10) primary key,
   fecha date,
   cedula char(10),
   total decimal(15,2)
);

alter table facturas
add constraint facturascedula_fk
foreign key (cedula)
references clientes(cedula);

insert into facturas values(
   '0000000001','2025-12-12','1800000001', 5.25
);

create table facturadetalle(
   facturanumero char(19),
   medicamento_id int,
   cantidad int,
   precio decimal(15,2)
);

alter table facturadetalle
add constraint facturadetalle_cantidad_ck
check (cantidad > 0);

alter table facturadetalle
add primary key (facturanumero, medicamento_id);

insert into facturadetalle values(
   '0000000001', 3, 12, 2.75
);
insert into facturadetalle values(
   '0000000001', 1, 5, 0.75
);