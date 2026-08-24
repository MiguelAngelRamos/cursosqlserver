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