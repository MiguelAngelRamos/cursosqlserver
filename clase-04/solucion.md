
/*
Enunciado: Mostrar únicamente los libros que tienen préstamos registrados,
incluyendo el título, autor, usuario y fecha del préstamo.
*/
SELECT * FROM Libros;
SELECT * FROM Prestamos;
SELECT * FROM Libros WHERE IDLibro = 1;
SELECT * FROM Usuarios WHERE IDUsuario = 106;

SELECT 
	Libros.titulo, Libros.Autor, Usuarios.Nombre, Prestamos.FechaPrestamo
FROM Prestamos 
	INNER JOIN Libros ON Prestamos.IDLibro = Libros.IDLibro
	INNER JOIN Usuarios ON Prestamos.IDUsuario = Usuarios.IDUsuario;

/*
LEFT JOIN: todos los usuarios y sus prestamos
Enunciado: Mostrar todos los usuarios, incluyendo aquellos que nunca han solicitado un libro.
*/
SELECT * FROM Usuarios;
SELECT * FROM Prestamos;

SELECT 
	Usuarios.IDUsuario,
	Usuarios.Nombre,
	Prestamos.FechaPrestamo
FROM Usuarios 
LEFT JOIN Prestamos ON Usuarios.IDUsuario = Prestamos.IDUsuario;

--  LEFT JOIN: libros que nunca han sido prestados
-- Enunciado: Mostrar solamente los libros que no tienen ningún préstamo registrado.

-- para conocer los libros que no han sido prestamos, primero debo conocer aquellos que si han sido prestados
-- de esa forma descarto a los que han sido prestamos y me quedo con los que no han sido prestamos.
SELECT * FROM Libros;

SELECT Libros.IDLibro, Libros.Titulo, Libros.Autor 
FROM Libros LEFT JOIN Prestamos ON Libros.IDLibro = Prestamos.IDLibro
WHERE Prestamos.IDPrestamo IS NULL;

SELECT *
FROM Libros LEFT JOIN Prestamos ON Libros.IDLibro = Prestamos.IDLibro
WHERE Prestamos.IDPrestamo IS NULL;

-- La condición IS NULL permite identificar los libros sin coincidencias en Prestamos.

-- Enunciado: Mostrar todos los libros, incluyendo los que nunca han sido prestados.
-- Right Join
SELECT 
	Libros.titulo, Libros.Autor, Prestamos.FechaPrestamo
FROM Prestamos 
	RIGHT JOIN Libros ON Prestamos.IDLibro = Libros.IDLibro;


-- RIGHT JOIN: Usuarios sin préstamos
-- Enunciado: Utilizar un RIGHT JOIN para encontrar los usuarios que nunca han solicitado un libro.

SELECT * FROM Prestamos;