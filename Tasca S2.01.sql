select * 
from company;

select * 
from transaction;

select declined, count(id)
from transaction 
group by declined;

# NIVEL 1: -----

#Ejercicio 1:
 # Revisar PDF adjunto.

#Ejercicio 1.2:
# 1.2.1 - Listado de paises que están haciendo compras. Asumimos 2 cosas: (1) Una compra se entiende como una transacción
# concretada (declined = 0) y (2) Que en el listado no se repitan los países (distinct)

select distinct country from company
join transaction
where declined = '0'
order by country asc;

# 1.2.2 - Desde cuántos países se realizan compras.

select count(distinct country) from company
join transaction
where declined = '0';

# 1.2.3 - Compañía con mayor media de ventas:

select company_id, company_name, avg(amount) as media_ventas
from transaction
join company 
on company.id = transaction.company_id
where declined = '0'
group by company_id
order by avg(amount) desc
limit 1;

# Ejercicio 3: Subqueries - Utilizar solo subconsultas (no utilizar JOIN). 
# Con transacción asumimos que se pide tratar todo aquel registro (con id) en la tabla
# transaction; indistintamente de si fue declinada o no.

# 1.3.1 - Transacciones realizadas por empresas de Alemania. 

select *
from transaction 
where company_id
in (select id
from company
where company.country = 'Germany') ;

# 1.3.2 - Lista de empresas que han realizado transacciones por una cantidad superior a la media de todas las transacciones.

select company_id, count(amount)
from transaction
where amount >= 
	(select avg(transaction.amount)
	from transaction)
group by company_id;

        
# Media de transacciones:
select avg(transaction.amount)
from transaction;

# 1.3.3 - Eliminar del sistema las empresas que carecen de transacciones registradas, entregar el listado de tales empresas:

Select company_name
from company
where not exists
(select distinct company_id
from transaction);

# NIVEL 2: -----

# Ejercicio 2.1: Identificar los 5 días que se generó la mayor cantidad de ingresos en la empresa por ventas. Mostrar la
# fecha de cada transacción junto con el total de las ventas.

select sum(transaction.amount) as total_dia, dia
from transaction
join
(select id, amount, date(timestamp) as dia
from transaction
order by dia ) as table21
on table21.id = transaction.id
where declined = '0'
group by table21.dia
order by total_dia desc
limit 5;

#Ejercicio 2.2: ¿Cuál es la media de ventas por país? Presentar los resultados ordenados de mayor a menor promedio.

select avg(amount) as media_venta, country
from transaction
join company on transaction.company_id = company.id
where declined = '0'
group by country
order by media_venta desc;

# Ejercicio 2.3: En la empresa se presenta un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a 
# la compañía "Non Institute". Para ello, piden la lista de todas las transacciones realizadas por empresas que están ubicadas
# en el mismo país que esta compañia. 
# Mostrar el listado aplicando JOIN y subconsultas. 
# Mostrar el listado aplicando subconsultas. 

# Usando JOIN y subconsultas:

select * 
from transaction
join
(select id
from company
where country = 
(select country
from company
where company_name = "non institute") and id is not null) as table31
on table31.id = transaction.company_id;

# Usando solo subconsultas:

select * 
from transaction
where company_id 
in (select id
from company
where country = 
(select country
from company
where company_name = "non institute") and id is not null);

# NIVEL 3: -----

# Ejercicio 3.1: 

# Presentar el nombre, teléfono, país, fecha y cantidad de aquellas empresas que realizaron transacciones con un valor 
# comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril del 2021, 20 de julio del 2021 y 13 de marzo
# del 2022. Ordenar los resultados de mayor a menor cantidad.

select company_name, phone, country, date(timestamp), amount
from company c
join transaction t
on c.id = t.company_id
where date(timestamp) in ('2021-04-29', '2021-07-20', '2022-03-13') and
amount between 100 and 200
order by amount desc;

# Ejercicio 3.2: 

# Necesitamos optimizar las asignaciones de los recursos y dependerá de la capacidad operativa que se requiera, por lo que
# nos piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos
# humanos es exigente y quiere un listado de las empresas donde se especifique si tienen más de 4 o menos transacciones. 
# Asumimos que: Se pide considerar todas las transacciones, independientemente de si fueron concretadas o no (declined).

select table321.num_transacciones, company_id, company_name, country,
case 
	when table321.num_transacciones > 4 THEN 'Más de 4 transacciones'
    else 'Menos de 4 transacciones'
end as Cantidad_transacciones
from (select count(id) as num_transacciones, company_id
from transaction 
group by company_id) as table321
join company 
on company.id = table321.company_id
order by num_transacciones;

