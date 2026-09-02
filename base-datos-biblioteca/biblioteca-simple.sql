-- Crear la base de datos
CREATE DATABASE Biblioteca_Simple;
GO

-- Seleccionar la base de datos
USE Biblioteca_Simple;
GO


-- Tabla: Libros
CREATE TABLE Libros
(
    IDLibro INT IDENTITY(1,1) NOT NULL,
    Titulo NVARCHAR(200) NOT NULL,
    Autor NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_Libros
        PRIMARY KEY (IDLibro)
);
GO


-- Tabla: Usuarios
CREATE TABLE Usuarios
(
    IDUsuario INT IDENTITY(100,1) NOT NULL,
    Nombre NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_Usuarios
        PRIMARY KEY (IDUsuario)
);
GO


-- Tabla: Prestamos
CREATE TABLE Prestamos
(
    IDPrestamo INT IDENTITY(1,1) NOT NULL,
    IDLibro INT NOT NULL,
    IDUsuario INT NOT NULL,
    FechaPrestamo DATE NOT NULL,

    CONSTRAINT PK_Prestamos
        PRIMARY KEY (IDPrestamo),

    CONSTRAINT FK_Prestamos_Libros
        FOREIGN KEY (IDLibro)
        REFERENCES Libros(IDLibro),

    CONSTRAINT FK_Prestamos_Usuarios
        FOREIGN KEY (IDUsuario)
        REFERENCES Usuarios(IDUsuario)
);
GO
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

-- Nuevos registros de Prestamos

INSERT INTO Prestamos (IDLibro, IDUsuario, FechaPrestamo)
VALUES
(2, 101, '2024-06-05'), -- Juan López, segundo préstamo
(8, 101, '2024-06-10'), -- Juan López, tercer préstamo

(3, 102, '2024-06-15'), -- María Gómez, segundo préstamo

(9, 103, '2024-06-20'), -- Carlos Ramírez, segundo préstamo
(10, 103, '2024-06-25'), -- Carlos Ramírez, tercer préstamo

(4, 106, '2024-07-01'), -- Sofía Torres, segundo préstamo

(6, 107, '2024-07-05'), -- Diego Fernández, primer préstamo
(7, 107, '2024-07-10'), -- Diego Fernández, segundo préstamo

(8, 108, '2024-07-15'); -- Elena Rodríguez, primer préstamo

-- Libros 
INSERT INTO Libros (Titulo, Autor)
VALUES
('El nombre de la rosa', 'Umberto Eco'),
('La sombra del viento', 'Carlos Ruiz Zafón'),
('Un mundo feliz', 'Aldous Huxley'),
('El extranjero', 'Albert Camus'),
('Drácula', 'Bram Stoker'),
('Frankenstein', 'Mary Shelley'),
('Moby Dick', 'Herman Melville'),
('Los miserables', 'Victor Hugo'),
('El retrato de Dorian Gray', 'Oscar Wilde'),
('La naranja mecánica', 'Anthony Burgess'),
('El viejo y el mar', 'Ernest Hemingway'),
('Ensayo sobre la ceguera', 'José Saramago'),
('Pedro Páramo', 'Juan Rulfo');

-- Prestamos Adicionales
INSERT INTO Prestamos (IDLibro, IDUsuario, FechaPrestamo)
VALUES
    (1, 104, '2026-08-20'), -- hace 4 días  -> A tiempo (<=15)
    (2, 105, '2026-08-10'), -- hace 14 días -> A tiempo (<=15)
    (3, 100, '2026-08-05'), -- hace 19 días -> Vencido leve (16 a 22)
    (4, 101, '2026-08-02'), -- hace 22 días -> Vencido leve (límite exacto)
    (5, 102, '2026-07-20'); -- hace 35 días -> Vencido grave
GO