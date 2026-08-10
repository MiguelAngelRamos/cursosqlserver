USE CursoTSQL;

-- Proyección
SELECT 
	NombreProducto,
	PrecioUnitario,
	CantidadDisponible
FROM dbo.Productos;

-- SELECCION O FILTRADO
SELECT NombreProducto, PrecioUnitario 
FROM dbo.Productos 
WHERE PrecioUnitario > 100000.00 
ORDER BY PrecioUnitario DESC;

SELECT 	
	NombreProducto,
	PrecioUnitario AS PrecioConDescuento
FROM dbo.Productos
WHERE PrecioConDescuento > 100000.00;

-- La MISMA idea, pero usando el alias en el ORDER BY. Esta SI funciona.
--
-- La unica diferencia es el orden logico:
--     WHERE     se evalua ANTES  que SELECT  -->  el alias no existe  -->  error
--     ORDER BY  se evalua DESPUES de SELECT  -->  el alias si existe  -->  funciona
--
-- El par formado por la consulta 2.7 y esta consulta 2.8 es la demostracion
-- central del modulo 2. Si se entiende esto, se entendio el modulo completo.

SELECT 	
	NombreProducto,
	PrecioUnitario AS PrecioConDescuento
FROM dbo.Productos
ORDER BY PrecioConDescuento;

-- Ejercicio quiero utilizar el Alias PrecioConDescuento y quiero filtrar precios con descuento superior a  100000.00;
-- COMO QUEDARIA LA CONSULTA?


SELECT 	
	NombreProducto,
	PrecioUnitario AS PrecioConDescuento
FROM dbo.Productos
WHERE PrecioUnitario > 100000.00
ORDER BY PrecioConDescuento;

/*
 QUE ES NULL

 NULL representa la AUSENCIA de un valor. Significa "no se sabe" o "no aplica".

 NULL no es cero.
 NULL no es una cadena vacia.
 NULL no es un espacio en blanco.

 En la tabla Clientes, Hector Ramirez Vega tiene NULL en CorreoElectronico.
 Eso no significa que su correo sea vacio: significa que la empresa no sabe cual es.
*/

SELECT * FROM Clientes;

-- Cuantos Clientes hay sin correo 

SELECT 
 NombreCompleto,
 CorreoElectronico
FROM Clientes
WHERE CorreoElectronico IS NULL;

-- Cuantos Clientes hay sin Telefono
SELECT 
 NombreCompleto,
 NumeroTelefono
FROM Clientes
WHERE NumeroTelefono IS NULL;

-- UNIR TODO

SELECT 
 NombreCompleto,
 CorreoElectronico,
 NumeroTelefono,
 CASE
	WHEN CorreoElectronico IS NULL AND NumeroTelefono IS NULL THEN 'Sin correo ni telefono'
	WHEN CorreoElectronico IS NULL                            THEN 'Sin correo'
	WHEN NumeroTelefono    IS NULL                            THEN 'Sin telefono'
	ELSE 'Datos completos'
 END AS DatoFaltante
FROM Clientes;


SELECT 
 NombreCompleto,
 CorreoElectronico,
 NumeroTelefono,
 CASE
	WHEN CorreoElectronico IS NULL AND NumeroTelefono IS NULL THEN 'Sin correo ni telefono'
	WHEN CorreoElectronico IS NULL                            THEN 'Sin correo'
	WHEN NumeroTelefono    IS NULL                            THEN 'Sin telefono'
	ELSE 'Datos completos'
 END AS DatoFaltante
FROM Clientes
WHERE CorreoElectronico IS NULL OR NumeroTelefono IS NULL;

/*
La regla que vale la pena dejar grabada WHERE decide que filas ves, CASE decide que texto muestra cada columna,
son responsabilidades separadas
*/