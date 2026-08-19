USE Biblioteca_Simple;
GO


/* =====================================================
   INSERTAR 10 LIBROS CON 10 AUTORES DIFERENTES
   ===================================================== */

INSERT INTO Libros (Titulo, Autor)
VALUES
    (N'Cien años de soledad',       N'Gabriel García Márquez'),
    (N'El señor de los anillos',    N'J. R. R. Tolkien'),
    (N'1984',                        N'George Orwell'),
    (N'El principito',               N'Antoine de Saint-Exupéry'),
    (N'Don Quijote de la Mancha',    N'Miguel de Cervantes'),
    (N'Orgullo y prejuicio',         N'Jane Austen'),
    (N'Crimen y castigo',            N'Fiódor Dostoyevski'),
    (N'La metamorfosis',             N'Franz Kafka'),
    (N'Rayuela',                     N'Julio Cortázar'),
    (N'Fahrenheit 451',              N'Ray Bradbury');
GO


/* =====================================================
   INSERTAR 10 USUARIOS
   Los ID se generan desde 100 hasta 109
   ===================================================== */

INSERT INTO Usuarios (Nombre)
VALUES
    (N'Ana Pérez'),        -- IDUsuario 100
    (N'Juan López'),       -- IDUsuario 101
    (N'María Gómez'),      -- IDUsuario 102
    (N'Carlos Ramírez'),   -- IDUsuario 103
    (N'Laura Martínez'),   -- IDUsuario 104
    (N'Pedro Sánchez'),    -- IDUsuario 105
    (N'Sofía Torres'),     -- IDUsuario 106
    (N'Diego Fernández'),  -- IDUsuario 107: sin préstamos
    (N'Elena Rodríguez'),  -- IDUsuario 108: sin préstamos
    (N'Miguel Herrera');   -- IDUsuario 109: sin préstamos
GO


/* =====================================================
   INSERTAR PRÉSTAMOS

   Libros 8, 9 y 10 no han sido prestados.
   Usuarios 107, 108 y 109 no tienen préstamos.
   ===================================================== */

INSERT INTO Prestamos (IDLibro, IDUsuario, FechaPrestamo)
VALUES
    (1, 100, '2024-03-01'),
    (3, 101, '2024-03-05'),
    (2, 102, '2024-03-10'),
    (4, 100, '2024-04-02'), -- Ana Pérez tiene otro préstamo
    (5, 103, '2024-04-15'),
    (6, 104, '2024-05-03'),
    (7, 105, '2024-05-20'),
    (1, 106, '2024-06-01'); -- El libro 1 aparece en otro préstamo
GO