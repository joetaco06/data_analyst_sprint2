SELECT * 
FROM company;

SELECT * 
FROM transaction;

SELECT declined, count(id)
FROM transaction 
GROUP BY declined;

# NIVEL 1: -----

#Ejercicio 1:
 # Revisar PDF adjunto. *Actualizado utilizando Reverse Engineer del WorkBench *

#Ejercicio 1.2:
# 1.2.A - Listado de paises que están haciendo compras. Asumimos 2 cosas: (1) Una compra se entiende como una transacción
# concretada (declined = 0) y (2) Que en el listado no se repitan los países (distinct)

SELECT DISTINCT country FROM company
JOIN transaction
WHERE declined = '0'
ORDER BY country ASC;


# 1.2.B - Desde cuántos países se realizan compras.
#*Actualizado: Se ha incluido la condición de unión entre las tablas a través del uso de ON*

SELECT COUNT(DISTINCT company.country) FROM company
JOIN transaction ON company.id = transaction.company_id
WHERE transaction.declined = '0';


# 1.2.C - Compañía con mayor media de ventas:
#*Actualizado: Se ha dado más claridad al código utilizando más alías para identificar a los campos y sus tablas *

SELECT t.company_id, c.company_name, AVG(t.amount) AS media_ventas
FROM transaction t
JOIN company c
ON c.id = t.company_id
WHERE t.declined = '0'
GROUP BY t.company_id, c.company_name
ORDER BY media_ventas DESC
LIMIT 1;


# Ejercicio 3: Subqueries - Utilizar solo subconsultas (no utilizar JOIN). 
# Con transacción asumimos que se pide tratar todo aquel registro (con id) en la tabla
# transaction; indistintamente de si fue declinada o no.

# 1.3.A - Transacciones realizadas por empresas de Alemania. 

SELECT *
FROM transaction 
WHERE company_id
IN (SELECT id
FROM company
WHERE company.country = 'Germany') ;


# 1.3.B - Lista de empresas que han realizado transacciones por una cantidad superior a la media de todas las transacciones.
# * Actualizado: se ha incluido toda la información de las empresas en la query *

select id, company_name, phone, email, country, website 
from company 
where id in (SELECT company_id
			FROM transaction
			WHERE amount >= 
							(SELECT AVG(transaction.amount)
							FROM transaction) 
GROUP BY company_id)
;

# Media de transacciones:

SELECT AVG(transaction.amount)
FROM transaction;


# 1.3.C - Eliminar del sistema las empresas que carecen de transacciones registradas, entregar el listado de tales empresas:
# * Actualizado: Se ha obviado el uso de DISTINCT e incluido la clausula WHERE dentro de la subquery *

SELECT company_name
FROM company c
WHERE NOT EXISTS
(SELECT company_id
FROM transaction t
WHERE c.id = t.company_id  );


# NIVEL 2: -----

# Ejercicio 2.1: Identificar los 5 días que se generó la mayor cantidad de ingresos en la empresa por ventas. Mostrar la
# fecha de cada transacción junto con el total de las ventas.
# * Actualización: Se ha eliminado el uso del JOIN y la subquery por sugerencia, ya que realmente no eran necesarios. Ahora
# tenemos una versión más directa y optimizada del código. 

SELECT SUM(transaction.amount) AS total_dia, DATE(transaction.timestamp) AS dia
FROM transaction
WHERE declined = '0'
GROUP BY DATE(transaction.timestamp)
ORDER BY total_dia DESC
LIMIT 5;

#Ejercicio 2.2: ¿Cuál es la media de ventas por país? Presentar los resultados ordenados de mayor a menor promedio.
# Actualización: Ya que declined es un campo booleano, se utlizará la condición declined = 0. Observamos una ganancia 
# en rendimiento frente al inicial declined = '0'. Asumimos que se entiende por ventas a las transacciónes efectivamente
# concretadas.

SELECT AVG(amount) AS media_venta, country
FROM transaction
JOIN company ON transaction.company_id = company.id
WHERE declined = 0
GROUP BY country
ORDER BY media_venta DESC;

# Ejercicio 2.3: En la empresa se presenta un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a 
# la compañía "Non Institute". Para ello, piden la lista de todas las transacciones realizadas por empresas que están ubicadas
# en el mismo país que esta compañia. 
# Mostrar el listado aplicando JOIN y subconsultas. 
# Mostrar el listado aplicando subconsultas. 

# Usando JOIN y subconsultas:
# *Actualización: Se elimina el uso del AND id IS NOT NULL al ser redundante. id al ser primary key no puede ser
# NULL por definición. También se elimina subconsulta innecesaria, reduciendo el código.

SELECT *
FROM transaction
JOIN company ON company.id = transaction.company_id
WHERE company.country = (SELECT country FROM company WHERE company_name = 'non institute');

# Usando solo subconsultas:
# Actualización: Se elimina el uso del AND id IS NOT NULL al ser redundante, al igual que en la consulta anterior.

SELECT * 
FROM transaction
WHERE company_id 
IN (SELECT id
FROM company
WHERE country = 
(SELECT country
FROM company
WHERE company_name = "non institute") )
;

# NIVEL 3: -----

# Ejercicio 3.1: 

# Presentar el nombre, teléfono, país, fecha y cantidad de aquellas empresas que realizaron transacciones con un valor 
# comprendido entre 100 y 200 euros y en alguna de estas fechas: 29 de abril del 2021, 20 de julio del 2021 y 13 de marzo
# del 2022. Ordenar los resultados de mayor a menor cantidad.

SELECT company_name, phone, country, DATE(timestamp), amount
FROM company c
JOIN transaction t
ON c.id = t.company_id
WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13') AND
amount BETWEEN 100 AND 200
ORDER BY amount DESC;


# Ejercicio 3.2: 

# Necesitamos optimizar las asignaciones de los recursos y dependerá de la capacidad operativa que se requiera, por lo que
# nos piden la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos
# humanos es exigente y quiere un listado de las empresas donde se especifique si tienen más de 4 o menos transacciones. 
# Asumimos que: Se pide considerar todas las transacciones, independientemente de si fueron concretadas o no (declined).

SELECT table321.num_transacciones, company_id, company_name, country,
CASE 
	WHEN table321.num_transacciones > 4 THEN 'Más de 4 transacciones'
    ELSE 'Menos de 4 transacciones'
END AS Cantidad_transacciones
FROM (SELECT count(id) AS num_transacciones, company_id
FROM transaction 
GROUP BY company_id) AS table321
JOIN company 
ON company.id = table321.company_id
ORDER BY num_transacciones;

