```sql
USE BibliotecaRealCursoTSQL;
/*
  REQUERIMIENTO:
  Determinar cuántos socios existen por categoría y cuántos están activos o
  inactivos, para caracterizar la composición de la comunidad usuaria.
*/

SELECT COUNT(*) FROM Socios;

-- 2000

SELECT 
	Socios.TipoSocio,
	COUNT(*) as CantidadSocios 
FROM Socios
GROUP BY Socios.TipoSocio;


SELECT 
	Socios.TipoSocio,
	CASE WHEN Socios.SocioActivo = 1 THEN N'Activo' ELSE N'Inactivo' END As EstadoSocio,
	COUNT(*) as CantidadSocios 
FROM Socios
GROUP BY 
	Socios.TipoSocio,
	Socios.SocioActivo;

SELECT 
	S.TipoSocio,
	CASE WHEN S.SocioActivo = 1 THEN N'Activo' ELSE N'Inactivo' END As EstadoSocio,
	COUNT(*) as CantidadSocios 
FROM Socios AS S
GROUP BY 
	S.TipoSocio,
	S.SocioActivo;


SELECT 
	S.TipoSocio,
	CASE WHEN S.SocioActivo = 1 THEN N'Activo' ELSE N'Inactivo' END EstadoSocio,
	COUNT(*) CantidadSocios 
FROM Socios S
GROUP BY 
	S.TipoSocio,
	S.SocioActivo
ORDER BY
    S.TipoSocio ASC,
	S.SocioActivo DESC;

-- Autores con mayor cantidad de obras

-- COUNT(*) CantidadObras
SELECT * FROM Autores AS A;

SELECT 
	Autores.AutorIdentificador, 
	Autores.NombreCompleto
FROM Autores
INNER JOIN ObrasAutores 
ON Autores.AutorIdentificador = ObrasAutores.AutorIdentificador;


SELECT 
	Autores.AutorIdentificador, 
	Autores.NombreCompleto,
	COUNT(*) As CantidadObras
FROM Autores
INNER JOIN ObrasAutores 
ON Autores.AutorIdentificador = ObrasAutores.AutorIdentificador
GROUP BY Autores.AutorIdentificador, Autores.NombreCompleto
ORDER BY 
	CantidadObras DESC;


-- Calidad de los datos de contacto
SELECT 
	COUNT(*) TotalSocios,
	SUM(CASE WHEN Socios.CorreoElectronico IS NULL THEN 1 ELSE 0 END) as SinCorreo,
	SUM(CASE WHEN Socios.CorreoElectronico IS NOT NULL THEN 1 ELSE 0 END) AS ConCorreo,
	SUM(CASE WHEN Socios.NumeroTelefono IS NULL THEN 1 ELSE 0 END) AS SinTelefono,
	SUM(CASE WHEN Socios.NumeroTelefono IS NOT NULL THEN 1 ELSE 0 END) AS ConTelefono
FROM Socios;
```