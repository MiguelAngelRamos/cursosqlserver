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


-- Fechas
GO
CREATE FUNCTION dbo.EstadoPrestamo(@FechaPrestamo DATE, @DiasPlazo INT)
RETURNS NVARCHAR(20)
AS
BEGIN
	-- DECLARAR UNA VARIABLE
	DECLARE @DiasTranscurridos INT = DATEDIFF(DAY, @FechaPrestamo, GETDATE());
	DECLARE @Estado NVARCHAR(20);

	IF @DiasTranscurridos <= @DiasPlazo
		SET @Estado = N'A tiempo';
	ELSE IF @DiasTranscurridos <= @DiasPlazo + 7
		SET @Estado = N'Vencido Leve';
	ELSE 
	    SET @Estado = N'Vencido grave';
	RETURN @Estado;
END;
GO

SELECT IDPrestamo, FechaPrestamo, dbo.EstadoPrestamo(FechaPrestamo, 15) as Estado FROM Prestamos;

