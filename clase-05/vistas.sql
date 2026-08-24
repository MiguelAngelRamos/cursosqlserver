GO

CREATE VIEW vw_DetallePrestamos
AS
SELECT 
	Libros.titulo, Libros.Autor, Usuarios.Nombre, Prestamos.FechaPrestamo
FROM Prestamos 
	INNER JOIN Libros ON Prestamos.IDLibro = Libros.IDLibro
	INNER JOIN Usuarios ON Prestamos.IDUsuario = Usuarios.IDUsuario;
GO

SELECT * FROM vw_DetallePrestamos;

-- Si quieres puedes filtrar en tus vistas

SELECT * FROM dbo.vw_DetallePrestamos WHERE Nombre = N'Ana Pérez';

GO
CREATE VIEW vw_CantidadPrestamosPorUsuario
AS
SELECT
    U.IDUsuario,
    U.Nombre,
    COUNT(P.IDPrestamo) AS CantidadPrestamos
FROM Usuarios AS U
LEFT JOIN Prestamos AS P
    ON U.IDUsuario = P.IDUsuario
GROUP BY
    U.IDUsuario,
    U.Nombre;
GO

SELECT * FROM vw_CantidadPrestamosPorUsuario WHERE CantidadPrestamos > 2;
