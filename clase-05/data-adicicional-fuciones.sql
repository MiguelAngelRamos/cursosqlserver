INSERT INTO Prestamos (IDLibro, IDUsuario, FechaPrestamo)
VALUES
    (1, 104, '2026-08-20'), -- hace 4 días  -> A tiempo (<=15)
    (2, 105, '2026-08-10'), -- hace 14 días -> A tiempo (<=15)
    (3, 100, '2026-08-05'), -- hace 19 días -> Vencido leve (16 a 22)
    (4, 101, '2026-08-02'), -- hace 22 días -> Vencido leve (límite exacto)
    (5, 102, '2026-07-20'); -- hace 35 días -> Vencido grave
GO