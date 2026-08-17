```sql
SELECT * FROM users;

SELECT COUNT(*) AS TotalUsers FROM users;

-- La función MIN() Y MAX()
-- Obtener el numero total usuarios(users) y el minimo de seguidores (followers)
SELECT COUNT(*) AS TotalUsers, MIN(followers) AS Min_Followers FROM users;

-- Obtener el numero total usuarios(users) y el maximo de seguidores (followers)
SELECT COUNT(*) AS TotalUsers, MAX(followers) AS Max_Followers FROM users;


-- SUB-CONSULTA

SELECT first_name, last_name, followers FROM users WHERE followers = 4;
SELECT first_name, last_name, followers FROM users WHERE followers = (SELECT min(followers) from users);


SELECT first_name, last_name, followers FROM users WHERE followers = 4999;
SELECT first_name, last_name, followers FROM users WHERE followers = (SELECT max(followers) from users);

SELECT 
	COUNT(*) as users, country 
FROM users 
GROUP BY country
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;

```