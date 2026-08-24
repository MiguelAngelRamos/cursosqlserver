-- TVF
/*
Quiero una función que reciba el ID de un usuario 
y me devuelva todos los libros que ha solicitado.
*/
GO
CREATE FUNCTION dbo.fn_PrestamosPorUsuario
(
	@IDUsuario INT
)
RETURNS TABLE
AS
RETURN (
	SELECT 
		P.IDPrestamo, 
		L.Titulo, 
		L.Autor, 
		P.FechaPrestamo 
FROM Prestamos P
INNER JOIN Libros L ON P.IDLibro = L.IDLibro 
WHERE P.IDUsuario = @IDUsuario
);
GO

-- EDITAR LA FUNCION

GO
ALTER FUNCTION dbo.fn_PrestamosPorUsuario
(
	@IDUsuario INT
)
RETURNS TABLE
AS
RETURN (
	SELECT 
		P.IDPrestamo, 
		L.Titulo, 
		L.Autor, 
		P.FechaPrestamo 
FROM Prestamos P
INNER JOIN Libros L ON P.IDLibro = L.IDLibro 
WHERE P.IDUsuario = @IDUsuario
);
GO