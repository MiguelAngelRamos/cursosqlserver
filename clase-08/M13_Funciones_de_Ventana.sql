/* ============================================================================
   MÓDULO 13 · FUNCIONES DE CLASIFICACIÓN, DESPLAZAMIENTO Y AGREGACIÓN
   Querying Data with Microsoft Transact-SQL · Kibernum IT Academy

   Base de datos: Biblioteca_Simple
   23 libros · 10 usuarios (100 a 109) · 22 préstamos

   Todos los resultados documentados en este script fueron verificados
   contra los datos reales de la base.
   ============================================================================ */

USE Biblioteca_Simple;
GO


/* ============================================================================
   0. EL FUNDAMENTO: QUÉ ES UNA VENTANA
   ============================================================================

   Una "ventana" es el conjunto de filas que una función puede VER para
   calcular su resultado en la fila actual.

   La estructura general es siempre la misma:

       FUNCION() OVER (
           PARTITION BY  columna    -- separa los datos en grupos
           ORDER BY      columna    -- ordena las filas dentro de cada grupo
           ROWS / RANGE  ...        -- acota el marco dentro de ese orden
       )

   Las tres cláusulas son opcionales. OVER () vacío significa
   "la ventana es TODO el conjunto de resultados".

   ---------------------------------------------------------------------------
   DÓNDE SE EVALÚA (enlace con el Módulo 2)

       FROM -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY
                                                 ^
                                       aquí se evalúa OVER

   Consecuencia práctica: NO se puede filtrar por una función de ventana en
   el WHERE de la misma consulta, porque en ese momento la columna todavía
   no existe. Para filtrarla hay que envolver la consulta en una CTE.
   ============================================================================ */


/* ============================================================================
   1. ROW_NUMBER() — NUMERAR FILAS
   ============================================================================
   Asigna un correlativo. NUNCA repite un número y NUNCA deja huecos.
   ============================================================================ */

-- 1.A  SIN PARTITION BY: una sola ventana con los 22 préstamos.
SELECT
    p.IDPrestamo,
    u.Nombre,
    l.Titulo,
    p.FechaPrestamo,

    ROW_NUMBER() OVER (
        -- Al no haber PARTITION BY, la ventana es el conjunto completo:
        -- la numeración corre de 1 a 22 sin reiniciarse nunca.
        ORDER BY p.FechaPrestamo, p.IDPrestamo
        -- El desempate por IDPrestamo NO es opcional en la práctica:
        -- si dos filas empataran en fecha, el orden sería indeterminado
        -- y el resultado podría cambiar entre ejecuciones.
    ) AS NumeroGlobal

FROM dbo.Prestamos AS p
INNER JOIN dbo.Usuarios AS u  ON u.IDUsuario = p.IDUsuario
INNER JOIN dbo.Libros   AS l  ON l.IDLibro   = p.IDLibro
ORDER BY NumeroGlobal;

/*  Devuelve 22 filas numeradas de 1 a 22.
    Las primeras: 2024-03-01 = 1, 2024-03-05 = 2, 2024-03-10 = 3,
                  2024-04-02 = 4, 2024-04-15 = 5 ...                        */


-- 1.B  CON PARTITION BY: una ventana independiente por cada usuario.
SELECT
    u.Nombre,
    l.Titulo,
    p.FechaPrestamo,

    ROW_NUMBER() OVER (
        PARTITION BY p.IDUsuario   -- <<< reinicia el conteo en cada usuario
        ORDER BY p.FechaPrestamo, p.IDPrestamo
    ) AS NroPrestamoUsuario

FROM dbo.Prestamos AS p
INNER JOIN dbo.Usuarios AS u  ON u.IDUsuario = p.IDUsuario
INNER JOIN dbo.Libros   AS l  ON l.IDLibro   = p.IDLibro
ORDER BY
    u.Nombre,
    NroPrestamoUsuario;

/*  Lectura literal de la cláusula:
    "Para cada usuario, ordena sus préstamos por fecha y numéralos desde 1."

    Ana Pérez (100), 3 filas:
        Cien años de soledad      2024-03-01   ->  1
        El principito             2024-04-02   ->  2
        1984                      2026-08-05   ->  3

    Juan López (101), 4 filas:
        1984                      2024-03-05   ->  1
        El señor de los anillos   2024-06-05   ->  2
        La metamorfosis           2024-06-10   ->  3
        El principito             2026-08-02   ->  4

    OJO: la consulta devuelve 22 filas, no 23. Miguel Herrera (109) NO
    aparece porque el INNER JOIN lo elimina: no tiene ningún préstamo.     */


/* ============================================================================
   2. RANK() Y DENSE_RANK() — CLASIFICAR CON EMPATES
   ============================================================================
   Aquí está el corazón del módulo. La diferencia entre estas funciones SOLO
   se ve cuando hay empates, y en esta base los hay de sobra.
   ============================================================================ */

SELECT
    u.Nombre,
    COUNT(p.IDPrestamo) AS CantidadPrestamos,
    -- COUNT(columna) ignora los NULL -> Miguel Herrera obtiene 0.
    -- Con COUNT(*) obtendría 1, porque contaría la fila que el LEFT JOIN
    -- genera con NULLs. Es el error más frecuente de todo el curso.

    ROW_NUMBER() OVER (ORDER BY COUNT(p.IDPrestamo) DESC, u.IDUsuario) AS NumeroFila,
    -- Correlativo puro: rompe los empates de forma arbitraria.

    RANK()       OVER (ORDER BY COUNT(p.IDPrestamo) DESC)              AS Rango,
    -- Repite el número en los empates y luego SALTA tantas posiciones
    -- como filas empatadas hubo. Es el "podio deportivo".

    DENSE_RANK() OVER (ORDER BY COUNT(p.IDPrestamo) DESC)              AS RangoDenso,
    -- Repite el número pero NO salta. Cuenta NIVELES distintos de valor,
    -- no filas.

    NTILE(3)     OVER (ORDER BY COUNT(p.IDPrestamo) DESC, u.IDUsuario) AS Tercio
    -- Reparte las 10 filas en 3 grupos lo más parejos posible: 4, 3 y 3.

FROM dbo.Usuarios AS u
LEFT JOIN dbo.Prestamos AS p
    -- LEFT JOIN, no INNER: así Miguel Herrera SÍ entra en la clasificación.
    ON p.IDUsuario = u.IDUsuario
GROUP BY
    u.IDUsuario,   -- se agrupa también por ID porque Nombre no es UNIQUE:
    u.Nombre       -- dos usuarios homónimos se fundirían en una sola fila
ORDER BY
    CantidadPrestamos DESC,
    u.IDUsuario;

/*  ¿POR QUÉ SE PUEDE ESCRIBIR COUNT() DENTRO DE OVER()?

    Porque las funciones de ventana se evalúan DESPUÉS de GROUP BY. Cuando
    RANK entra en acción, cada grupo ya se redujo a una sola fila y
    COUNT(p.IDPrestamo) ya es un valor calculado, no una agregación pendiente.

    ---------------------------------------------------------------------------
    RESULTADO REAL (10 filas):

    Nombre              Cantidad  NumeroFila  Rango  RangoDenso  Tercio
    ------------------------------------------------------------------
    Juan López               4         1        1        1         1
    Ana Pérez                3         2        2        2         1
    María Gómez              3         3        2        2         1
    Carlos Ramírez           3         4        2        2         1
    Laura Martínez           2         5        5        3         2
    Pedro Sánchez            2         6        5        3         2
    Sofía Torres             2         7        5        3         2
    Diego Fernández          2         8        5        3         3   <<<
    Elena Rodríguez          1         9        9        4         3
    Miguel Herrera           0        10       10        5         3

    LAS TRES LECTURAS QUE HAY QUE FORZAR EN CLASE:

    1) RANK salta: 1, 2, 2, 2, 5, 5, 5, 5, 9, 10.
       Los números 3, 4, 6, 7 y 8 NO EXISTEN. Hay tres segundos lugares,
       así que el siguiente es el quinto.

    2) DENSE_RANK no salta: 1, 2, 2, 2, 3, 3, 3, 3, 4, 5.
       Responde "¿cuántos niveles distintos hay?" (cinco), no "¿en qué
       posición está esta fila?".

    3) NTILE PARTE EL EMPATE. Diego Fernández tiene los mismos 2 préstamos
       que Laura, Pedro y Sofía, pero cae en el tercio 3 mientras ellos
       quedan en el 2. NTILE cuenta FILAS, no VALORES, y no respeta empates.
       Es el punto que más confusión genera del módulo.                      */


/* ============================================================================
   3. FILTRAR POR UNA FUNCIÓN DE VENTANA
   ============================================================================ */

-- 3.A  ESTO FALLA. Descomentar solo para mostrar el error en clase.
/*
SELECT
    u.Nombre,
    RANK() OVER (ORDER BY COUNT(p.IDPrestamo) DESC) AS Rango
FROM dbo.Usuarios AS u
LEFT JOIN dbo.Prestamos AS p ON p.IDUsuario = u.IDUsuario
GROUP BY u.IDUsuario, u.Nombre
WHERE Rango <= 3;      -- Error: WHERE se evalúa ANTES que el SELECT
*/

-- 3.B  LA FORMA CORRECTA: cerrar el cálculo en una CTE y filtrar afuera.
WITH PrestamosPorUsuario AS
(
    -- ETAPA 1: se calcula el conteo por usuario.
    SELECT
        u.IDUsuario,
        u.Nombre,
        COUNT(p.IDPrestamo) AS CantidadPrestamos
    FROM dbo.Usuarios AS u
    LEFT JOIN dbo.Prestamos AS p
        ON p.IDUsuario = u.IDUsuario
    GROUP BY u.IDUsuario, u.Nombre
),
Ranking AS
(
    -- ETAPA 2: se aplica la ventana y su resultado queda como una columna
    -- normal del conjunto, ya disponible para filtrar.
    SELECT
        Nombre,
        CantidadPrestamos,
        DENSE_RANK() OVER (ORDER BY CantidadPrestamos DESC) AS RangoDenso
    FROM PrestamosPorUsuario
)
-- ETAPA 3: ahora sí se puede filtrar con un WHERE corriente.
SELECT
    Nombre,
    CantidadPrestamos,
    RangoDenso
FROM Ranking
WHERE RangoDenso <= 2
ORDER BY RangoDenso, Nombre;

/*  Devuelve 4 filas: Juan López (nivel 1) y Ana Pérez, Carlos Ramírez y
    María Gómez (nivel 2).

    DECISIÓN DE NEGOCIO, NO DE SINTAXIS:
    Con DENSE_RANK <= 2 se obtienen los 4 usuarios de los dos mejores
    niveles. Con ROW_NUMBER <= 2 se obtendrían exactamente 2 filas,
    cortando el bloque de empatados de forma arbitraria. Elegir uno u otro
    depende de si se pide "los mejores" o "dos registros".                  */


/* ============================================================================
   4. LAG() Y LEAD() — MIRAR LA FILA ANTERIOR Y LA SIGUIENTE
   ============================================================================
       LAG  <- mira hacia atrás
       LEAD -> mira hacia adelante
   ============================================================================ */

SELECT
    u.Nombre,
    l.Titulo,
    p.FechaPrestamo,

    LAG(p.FechaPrestamo) OVER (
        PARTITION BY p.IDUsuario
        ORDER BY p.FechaPrestamo, p.IDPrestamo
    ) AS PrestamoAnterior,
    -- Devuelve NULL en la PRIMERA fila de cada partición, porque no existe
    -- una fila anterior. Un tercer argumento fija un valor por defecto:
    --     LAG(p.FechaPrestamo, 1, p.FechaPrestamo)

    LEAD(p.FechaPrestamo) OVER (
        PARTITION BY p.IDUsuario
        ORDER BY p.FechaPrestamo, p.IDPrestamo
    ) AS PrestamoSiguiente,
    -- Devuelve NULL en la ÚLTIMA fila de cada partición.

    DATEDIFF(
        DAY,
        LAG(p.FechaPrestamo) OVER (
            PARTITION BY p.IDUsuario
            ORDER BY p.FechaPrestamo, p.IDPrestamo
        ),
        p.FechaPrestamo
    ) AS DiasDesdeAnterior
    -- La expresión LAG(...) se repite completa: no se puede reutilizar el
    -- alias PrestamoAnterior porque, en el orden lógico, todas las columnas
    -- del SELECT se evalúan en el mismo paso.

FROM dbo.Prestamos AS p
INNER JOIN dbo.Usuarios AS u  ON u.IDUsuario = p.IDUsuario
INNER JOIN dbo.Libros   AS l  ON l.IDLibro   = p.IDLibro
ORDER BY
    u.Nombre,
    p.FechaPrestamo;

/*  RESULTADO REAL para Ana Pérez (100):

    Fecha        Anterior     Siguiente    DiasDesdeAnterior
    ---------------------------------------------------------
    2024-03-01   NULL         2024-04-02        NULL
    2024-04-02   2024-03-01   2026-08-05          32
    2026-08-05   2024-04-02   NULL               855

    Y para Juan López (101):

    2024-03-05   NULL         2024-06-05        NULL
    2024-06-05   2024-03-05   2024-06-10          92
    2024-06-10   2024-06-05   2026-08-02           5
    2026-08-02   2024-06-10   NULL               783

    ADVERTIR EN CLASE el salto de 855 y 783 días: la base mezcla préstamos
    de 2024 con los cinco cargados en 2026. No es un error de cálculo.      */


/* ============================================================================
   5. AGREGACIÓN CON OVER — CALCULAR SIN PERDER LAS FILAS
   ============================================================================
   GROUP BY colapsa las filas. OVER las conserva y agrega en paralelo.
   ============================================================================ */

SELECT
    u.Nombre,
    l.Titulo,
    p.FechaPrestamo,

    COUNT(*) OVER (PARTITION BY u.IDUsuario) AS ConteoConAsterisco,
    -- Cuenta FILAS de la partición, incluida la fila con NULLs que genera
    -- el LEFT JOIN. Para Miguel Herrera devuelve 1, que es INCORRECTO.

    COUNT(p.IDPrestamo) OVER (PARTITION BY u.IDUsuario) AS ConteoCorrecto
    -- Cuenta VALORES NO NULOS. Para Miguel Herrera devuelve 0, que es
    -- lo correcto.

FROM dbo.Usuarios AS u
LEFT JOIN dbo.Prestamos AS p  ON p.IDUsuario = u.IDUsuario
LEFT JOIN dbo.Libros    AS l  ON l.IDLibro   = p.IDLibro
ORDER BY
    u.Nombre,
    p.FechaPrestamo;

/*  Devuelve 23 filas: los 22 préstamos más la fila de Miguel Herrera.

    Nombre            Titulo   ConteoConAsterisco   ConteoCorrecto
    --------------------------------------------------------------
    Ana Pérez         ...              3                  3
    ...
    Miguel Herrera    NULL             1                  0    <<<

    Las tres filas de Ana Pérez repiten el valor 3. Con GROUP BY se habría
    obtenido UNA sola fila con el 3; con OVER se conserva el detalle y el
    agregado viaja junto a él.

    Esta diferencia entre COUNT(*) y COUNT(columna) es exactamente la misma
    que se evalúa en el examen final.                                       */


/* ============================================================================
   6. COMPARAR CADA USUARIO CON EL TOTAL DE LA BIBLIOTECA
   ============================================================================ */

SELECT
    u.Nombre,
    COUNT(p.IDPrestamo) AS PrestamosUsuario,

    SUM(COUNT(p.IDPrestamo)) OVER () AS TotalBiblioteca,
    -- Doble nivel de cálculo:
    --   COUNT(...)  -> agrega dentro de cada grupo del GROUP BY
    --   SUM(...) OVER () -> suma esos resultados sobre TODAS las filas
    -- OVER() vacío significa "la ventana es el conjunto completo".

    CAST(
        100.0 * COUNT(p.IDPrestamo) / SUM(COUNT(p.IDPrestamo)) OVER ()
        AS DECIMAL(5,2)
    ) AS PorcentajeDelTotal
    -- 100.0 y no 100: con enteros SQL Server haría división ENTERA y todos
    -- los porcentajes saldrían 0.

FROM dbo.Usuarios AS u
LEFT JOIN dbo.Prestamos AS p
    ON p.IDUsuario = u.IDUsuario
GROUP BY
    u.IDUsuario,
    u.Nombre
ORDER BY
    PrestamosUsuario DESC,
    u.IDUsuario;

/*  RESULTADO REAL (10 filas). TotalBiblioteca = 22 en todas.

    Juan López         4    22    18.18
    Ana Pérez          3    22    13.64
    María Gómez        3    22    13.64
    Carlos Ramírez     3    22    13.64
    Laura Martínez     2    22     9.09
    Pedro Sánchez      2    22     9.09
    Sofía Torres       2    22     9.09
    Diego Fernández    2    22     9.09
    Elena Rodríguez    1    22     4.55
    Miguel Herrera     0    22     0.00                                     */


/* ============================================================================
   7. MARCO DE VENTANA: ROWS vs RANGE
   ============================================================================
   El punto más importante y el error silencioso más común del módulo.
   ============================================================================ */

WITH PrestamosPorUsuario AS
(
    SELECT
        u.IDUsuario,
        u.Nombre,
        COUNT(p.IDPrestamo) AS Total
    FROM dbo.Usuarios AS u
    LEFT JOIN dbo.Prestamos AS p
        ON p.IDUsuario = u.IDUsuario
    GROUP BY u.IDUsuario, u.Nombre
)
SELECT
    Nombre,
    Total,

    SUM(Total) OVER (
        ORDER BY Total DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS AcumuladoRange,
    -- RANGE opera sobre VALORES: absorbe de golpe todas las filas empatadas
    -- en el mismo valor. Es además el marco POR DEFECTO cuando se escribe
    -- OVER (ORDER BY col) sin especificar nada.

    SUM(Total) OVER (
        ORDER BY Total DESC, IDUsuario
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS AcumuladoRows
    -- ROWS opera sobre POSICIONES FÍSICAS: avanza fila a fila.

FROM PrestamosPorUsuario
ORDER BY
    Total DESC,
    IDUsuario;

/*  RESULTADO REAL:

    Nombre             Total   AcumuladoRange   AcumuladoRows
    ----------------------------------------------------------
    Juan López           4            4               4
    Ana Pérez            3           13               7
    María Gómez          3           13              10
    Carlos Ramírez       3           13              13
    Laura Martínez       2           21              15
    Pedro Sánchez        2           21              17
    Sofía Torres         2           21              19
    Diego Fernández      2           21              21
    Elena Rodríguez      1           22              22
    Miguel Herrera       0           22              22

    RANGE repite 13 en las tres filas empatadas en 3, y 21 en las cuatro
    empatadas en 2. ROWS avanza de a una: 4, 7, 10, 13, 15, 17, 19, 21.

    REGLA PRÁCTICA: DECLARAR SIEMPRE EL MARCO DE FORMA EXPLÍCITA.
    Si se omite, SQL Server aplica RANGE UNBOUNDED PRECEDING. Con empates
    en la columna de orden el acumulado sale distinto de lo esperado y el
    error NO produce ningún mensaje: la consulta simplemente devuelve otra
    cosa. Además, RANGE fuerza un spool en disco en muchos planes de
    ejecución, mientras que ROWS usa un spool en memoria.

    NOTA PARA EL RELATOR: este contraste NO se puede demostrar usando
    FechaPrestamo, porque las 22 fechas de la base son todas distintas y
    sin empates ambos marcos entregan exactamente el mismo resultado.       */


/* ============================================================================
   8. ACUMULADO CRONOLÓGICO (aplicación práctica de ROWS)
   ============================================================================ */

SELECT
    p.IDPrestamo,
    u.Nombre,
    p.FechaPrestamo,

    COUNT(*) OVER (
        ORDER BY p.FechaPrestamo, p.IDPrestamo
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS PrestamosAcumulados
    -- "Desde la primera fila de la ventana hasta la fila actual."
    -- Responde: ¿cuántos préstamos llevaba la biblioteca en esta fecha?

FROM dbo.Prestamos AS p
INNER JOIN dbo.Usuarios AS u
    ON u.IDUsuario = p.IDUsuario
ORDER BY
    p.FechaPrestamo,
    p.IDPrestamo;

/*  Devuelve 22 filas con el acumulado creciendo de 1 a 22.

    2024-03-01 -> 1     2024-04-15 -> 5     2024-06-10 -> 10
    2024-03-05 -> 2     2024-05-03 -> 6     ...
    2024-03-10 -> 3     2024-05-20 -> 7     2026-08-20 -> 22
    2024-04-02 -> 4     2024-06-01 -> 8                                     */


/* ============================================================================
   RESUMEN

   TIPO             FUNCIONES                              REQUIERE ORDER BY
   ---------------------------------------------------------------------------
   Clasificación    ROW_NUMBER, RANK, DENSE_RANK, NTILE    Sí, obligatorio
   Desplazamiento   LAG, LEAD                              Sí, obligatorio
   Agregación       COUNT, SUM, AVG, MIN, MAX              No

   PARTITION BY  ->  separa los datos en grupos independientes
   ORDER BY      ->  ordena las filas dentro de cada grupo
   ROWS / RANGE  ->  acota el marco dentro de ese orden

   TRES ERRORES QUE HAY QUE EVITAR:
   1. Filtrar por una función de ventana en el WHERE. Hay que usar una CTE.
   2. Omitir el desempate en el ORDER BY de ROW_NUMBER: resultado no determinista.
   3. No declarar el marco: el RANGE por defecto rompe los acumulados si hay empates.
   ============================================================================ */
