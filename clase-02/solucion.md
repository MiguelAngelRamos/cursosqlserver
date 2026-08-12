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
```