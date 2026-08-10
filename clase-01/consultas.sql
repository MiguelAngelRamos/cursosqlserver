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


