/* =====================================================
   PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
   Un procedimiento es un bloque de código T-SQL guardado
   con nombre, que se ejecuta con EXEC.

   Diferencias clave con una función (UDF):
   - Puede hacer INSERT / UPDATE / DELETE (una función no)
   - Puede tener varias sentencias, transacciones, TRY/CATCH
   - Puede devolver 0, 1 o varios result sets (con SELECT)
   - Puede tener parámetros de salida (OUTPUT)
   - NO se puede usar dentro de un SELECT como una función
     (dbo.Funcion(x)); se ejecuta aparte con EXEC

   Sintaxis general:

   CREATE PROCEDURE dbo.sp_NombreProcedimiento
       @parametro TIPO,
       @otroParametro TIPO = valor_por_defecto
   AS
   BEGIN
       -- lógica
   END;
   ===================================================== */

      GO

   CREATE PROCEDURE dbo.sp_BuscarLibroPorTitulo
        @Texto NVARCHAR(200)
   AS
   BEGIN
        SELECT IDLibro, Titulo, Autor 
        FROM Libros
        WHERE Titulo LIKE N'%' + @Texto + N'%';

   END;

   GO
   -- USO: 
   EXEC dbo.sp_BuscarLibroPorTitulo @Texto = N'quijote';


   -- Funciones, vistas y Procedimientos almacenado

   -- Cual de estos 3 objetos puede realizar INSERT, UPDATE Y DELETE? - PROCEDIMIENTOS.

   -- Cual de estos 3 objetos no puede recibir parametros. - vistas. - CORRECTO.


   -- PROCEDIMIENTO CON LOGICA CONDICIONAL
  GO
  
  CREATE PROCEDURE dbo.usp_RegistrarPrestamo
      @IDLibro INT,
      @IDUsuario INT,
      @FechaPrestamo DATE
  AS 
  BEGIN
      -- Verifica que el libro exista
      IF NOT EXISTS (SELECT 1 FROM Libros WHERE IDLibro = @IDLibro)
      BEGIN
          PRINT 'Error: el Libro no existe.';
          RETURN;
      END 
      -- Verifica que el usuario exista
      IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE IDUsuario = @IDUsuario)
      BEGIN
          PRINT 'Error: el usuario no existe.';
          RETURN;
      END;

      INSERT INTO Prestamos
      (
          IDLibro, 
          IDUsuario, 
          FechaPrestamo
      )
      VALUES 
      (
          @IDLibro,
          @IDUsuario,
          @FechaPrestamo
      )

  END;
  GO