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

   