select * 
from company;

select * 
from transaction;

# NIVEL 1: -----

#Ejercicio 1:
 # También revisar PDF adjunto.

#Ejercicio 2:
# 2.1 - Listado de paises que están haciendo compras. Asumimos que lo más lógico es que no se repitan los países:

select distinct country from company
order by country asc;

# 2.2 - Desde cuántos países se realizan compras. (Asumimos que se pide sin repetición).

select count(distinct country) from company;

# 2.3 - Compañía con mayor media de ventas:

select company_id, company_name, avg(amount) as media_ventas
from transaction
join company 
on company.id = transaction.company_id
group by company_id
order by avg(amount) desc
limit 1;

#Ejercicio 3: Subqueries - Utilizar solo subconsultas (no utilizar JOIN)
# 3.1 - Transacciones realizadas por empresas de Alemania.

select *
from transaction 
where company_id
in (select id
from company
where company.country = 'Germany') ;


# 3.2 - Lista de empresas que han realizado transacciones por una cantidad superior a la media de todas las transacciones.

select distinct company_id, amount
from transaction
where amount >= 
	(select avg(transaction.amount)
	from transaction);
        
# 3.3 - Eliminar del sistema las empresas que carecen de transacciones registradas, entregar el listado de tales empresas:

delete from transaction
where id is null;


select *
from transaction
where transaction.id is null;

# NIVEL 2: -----

# Ejercicio 1: Identificar los 5 días que se generó la mayor cantidad de ingresos en la empresa por ventas. Mostrar la
# fecha de cada transacción junto con el total de las ventas.

select sum(transaction.amount) as total_dia, dia
from transaction
join
(select id, amount, date(timestamp) as dia
from transaction
order by dia ) as table21
on table21.id = transaction.id
group by table21.dia
order by total_dia desc
limit 5;

#Ejercicio 2: ¿Cuál es la media de ventas por país? Presentar los resultados ordenados de mayor a menor promedio.

select avg(amount) as media_venta, country
from transaction
join company on transaction.company_id = company.id
group by country
order by media_venta desc;

# Ejercicio 3: En la empresa se presenta un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a 
# la compañía "Non Institute". Para ello, piden la lista de todas las transacciones realizadas por empresas que están ubicadas
# en el mismo país que esta compañia. 
# Mostrar el listado aplicando JOIN y subconsultas. 
# Mostrar el listado aplicando subconsultas. 

# Usando JOIN:

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

# Ejercicio 1: 

# Presentar el nombre, teléfono, país, fecha y cantidad de aquellas empresas que realizaron transacciones con un valor 
# comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril del 2021, 20 de julio del 2021 y 13 de marzo
# del 2022. Ordenar los resultados de mayor a menor cantidad.

select company_name, phone, country, dia, amount
from company
join 
(select id, company_id, amount, date(timestamp) as dia
from transaction
where date(timestamp) in ('2021-04-29', '2021-07-20', '2022-03-13') and
100 < amount and amount < 200 ) as table311
on company.id = table311.company_id
order by amount desc;


# Ejercicio 2: 

# Necesitamos optimizar las asignaciones de los recursos y dependerá de la capacidad operativa que se requiera, por lo que
# nos piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos
# humanos es exigente y quiere un listado de las empresas donde se especifique si tienen más de 4 o menos transacciones.

