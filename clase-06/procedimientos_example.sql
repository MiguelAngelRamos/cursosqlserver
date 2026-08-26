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
