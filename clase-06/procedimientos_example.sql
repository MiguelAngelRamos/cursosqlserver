-- =====================================================================================
-- BIBLIOTECA_SIMPLE - SET DE PROCEDIMIENTOS ADICIONALES (mejores practicas)
-- Curso: Querying Data with Microsoft Transact-SQL (DP-080) - Modulos 15 y 16
--
-- Seis procedimientos en orden de complejidad creciente. Cada uno agrega UNA
-- tecnica nueva respecto al anterior:
--   1. usp_LibrosNuncaPrestados      sin parametros, anti-join NOT EXISTS
--   2. usp_PrestamosDeUsuario        parametro + validacion + OUTPUT
--   3. usp_BuscarLibros              parametros opcionales + regla de negocio
--   4. usp_EstadoPrestamos           umbrales del CASE como parametros
--   5. usp_RegistrarPrestamoMultiple transaccion + WHILE + STRING_SPLIT
--   6. usp_ListarLibros              SQL dinamico seguro (demostracion guiada M15)
--
-- Requiere: SQL Server 2017+ (STRING_AGG) y nivel de compatibilidad >= 130
--           (STRING_SPLIT). La base creada en SQL Server 2025 cumple ambos.
--
-- CATALOGO DE ERRORES DE LA BASE (la condicion define el numero, no el proc):
--   50011 = el/los libro(s) no existe(n)
--   50012 = el usuario no existe
--   50013 = la fecha de prestamo es futura
--   50021 = rango de fechas invalido
--   50022 = busqueda sin ningun criterio
--   50023 = umbrales de clasificacion invalidos
--   50024 = lista de libros vacia
--   50025 = lista de libros con duplicados
--   50026 = lista de libros con valores no numericos
--   50031 = columna de ordenamiento no permitida
-- =====================================================================================

CREATE OR ALTER PROCEDURE dbo.usp_LibrosNuncaPrestados
AS
BEGIN
    SET NOCOUNT ON;

    SELECT l.IDLibro, l.Titulo, l.Autor
    FROM dbo.Libros AS l
    WHERE NOT EXISTS (SELECT 1
                      FROM dbo.Prestamos AS p
                      WHERE p.IDLibro = l.IDLibro)
    ORDER BY l.IDLibro;
END;
GO


GO

-- SEGUNDO usp

CREATE OR ALTER PROCEDURE dbo.usp_PrestamosDeUsuario
    @IDUsuario       INT,
    @TotalPrestamos  INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE IDUsuario = @IDUsuario)
        BEGIN
            DECLARE @Msg NVARCHAR(200) =
                CONCAT(N'El usuario ', @IDUsuario, N' no existe.');
            THROW 50012, @Msg, 1;
        END;

        SELECT p.IDPrestamo,
               l.IDLibro,
               l.Titulo,
               l.Autor,
               p.FechaPrestamo
        FROM dbo.Prestamos AS p
        JOIN dbo.Libros    AS l ON l.IDLibro = p.IDLibro
        WHERE p.IDUsuario = @IDUsuario
        ORDER BY p.FechaPrestamo DESC, p.IDPrestamo DESC;

        SELECT @TotalPrestamos = COUNT(*)
        FROM dbo.Prestamos
        WHERE IDUsuario = @IDUsuario;

        RETURN 0;
    END TRY
    BEGIN CATCH
        SET @TotalPrestamos = NULL;
        THROW;
    END CATCH;
END;
GO
-- LLAMADOR USP 2

DECLARE @Total INT;

EXEC dbo.usp_PrestamosDeUsuario @IDUsuario = 100 , @TotalPrestamos = @Total OUTPUT;

SELECT @Total as TotalDePrestamosUsuario;

-- 3 PROCEDIMIENTO
GO 
CREATE OR ALTER PROCEDURE dbo.usp_BuscarLibros
    @Titulo NVARCHAR(200) = NULL,
    @Autor  NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Titulo IS NULL AND @Autor IS NULL
            THROW 50022, N'Debe indicar al menos un criterio: titulo o autor.', 1;

        SELECT l.IDLibro, l.Titulo, l.Autor
        FROM dbo.Libros AS l
        WHERE (@Titulo IS NULL OR l.Titulo LIKE N'%' + @Titulo + N'%')
          AND (@Autor  IS NULL OR l.Autor  LIKE N'%' + @Autor  + N'%')
        ORDER BY l.Titulo;

        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
-- LLAMADOR
EXEC dbo.usp_BuscarLibros @Autor = N'G';


-- 4 PROCEDIMIENTO
GO
CREATE OR ALTER PROCEDURE dbo.usp_EstadoPrestamos
    @DiasATiempo INT = 15,      -- hasta aqui: 'A tiempo'
    @DiasLeve    INT = 22,      -- hasta aqui: 'Vencido leve'; despues: 'Vencido grave'
    @IDUsuario   INT = NULL     -- NULL = todos los usuarios
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @DiasATiempo IS NULL OR @DiasLeve IS NULL
           OR @DiasATiempo < 1 OR @DiasATiempo >= @DiasLeve
        BEGIN
            DECLARE @MsgUmbral NVARCHAR(200) = CONCAT(
                N'Umbrales invalidos: A tiempo (', @DiasATiempo,
                N') debe ser >= 1 y menor que Vencido leve (', @DiasLeve, N').');
            THROW 50023, @MsgUmbral, 1;
        END;

        IF @IDUsuario IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE IDUsuario = @IDUsuario)
        BEGIN
            DECLARE @MsgUsr NVARCHAR(200) =
                CONCAT(N'El usuario ', @IDUsuario, N' no existe.');
            THROW 50012, @MsgUsr, 1;
        END;

        SELECT p.IDPrestamo,
               u.Nombre AS Usuario,
               l.Titulo,
               p.FechaPrestamo,
               DATEDIFF(DAY, p.FechaPrestamo, CAST(GETDATE() AS DATE))
                   AS DiasTranscurridos,
               CASE
                   WHEN DATEDIFF(DAY, p.FechaPrestamo, CAST(GETDATE() AS DATE))
                        <= @DiasATiempo THEN N'A tiempo'
                   WHEN DATEDIFF(DAY, p.FechaPrestamo, CAST(GETDATE() AS DATE))
                        <= @DiasLeve THEN N'Vencido leve'
                   ELSE N'Vencido grave'
               END AS Estado
        FROM dbo.Prestamos AS p
        JOIN dbo.Usuarios  AS u ON u.IDUsuario = p.IDUsuario
        JOIN dbo.Libros    AS l ON l.IDLibro   = p.IDLibro
        WHERE (@IDUsuario IS NULL OR p.IDUsuario = @IDUsuario)
        ORDER BY DiasTranscurridos DESC, p.IDPrestamo;

        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO

EXEC dbo.usp_EstadoPrestamos @IDUsuario = 100;
-- Cambiamos los UMBRALES
EXEC dbo.usp_EstadoPrestamos @DiasATiempo = 30, @DiasLeve = 60, @IDUsuario = 100;
-- UMBRALES INVALIDOS
EXEC dbo.usp_EstadoPrestamos @DiasATiempo = 100, @DiasLeve = 60;