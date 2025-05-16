-- Max install and last active dates

SELECT MAX(install_date) AS latest_install FROM Practice.players;
SELECT MAX(last_active_date) AS latest_activity FROM Practice.players;

-- Players who installed between 14 and 7 days ago

SELECT COUNT(DISTINCT player_id) AS Previous_week_active_players
FROM Practice.players
WHERE install_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 14 DAY)
	AND DATE_SUB('2024-03-20', INTERVAL 7 DAY);

-- Of those players, who were active in the last 7 days

SELECT COUNT(DISTINCT player_id) AS Retained_players
FROM Practice.players
WHERE last_active_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 7 DAY) AND '2024-03-20'
AND player_id IN (
	SELECT player_id
	FROM Practice.players
	WHERE install_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 14 DAY)
	AND DATE_SUB('2024-03-20', INTERVAL 7 DAY)
);

-- 7-day retention rate

WITH Previous_week_active_players AS (
	SELECT COUNT(DISTINCT player_id) AS Previous_week_active_players
	FROM Practice.players
	WHERE install_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 14 DAY)
	AND DATE_SUB('2024-03-20', INTERVAL 7 DAY)
),
Retained_players AS (
	SELECT COUNT(DISTINCT player_id) AS Retained_players
	FROM Practice.players
	WHERE last_active_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 7 DAY)
	AND '2024-03-20'
	AND player_id IN (
		SELECT player_id
		FROM Practice.players
		WHERE install_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 14 DAY)
		AND DATE_SUB('2024-03-20', INTERVAL 7 DAY)
	)
)
SELECT ROUND((Retained_players / Previous_week_active_players) * 100, 2) AS retention_rate
FROM Previous_week_active_players, Retained_players;

-- 30-day retention rate

WITH D30_install AS (
	SELECT COUNT(DISTINCT player_id) AS D30_install_players
	FROM Practice.players
	WHERE install_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-19'
),
D30_retained AS (
	SELECT COUNT(DISTINCT player_id) AS D30_retained_players
	FROM Practice.players
	WHERE last_active_date BETWEEN '2024-03-20' AND DATE_ADD('2024-03-19', INTERVAL 30 DAY)
	AND player_id IN (
		SELECT player_id
		FROM Practice.players
		WHERE install_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY)
		AND '2024-03-19'
	)
)
SELECT ROUND((D30_retained_players / D30_install_players) * 100, 2) AS retention_rate
FROM D30_install, D30_retained;

-- D7 Retention per install date

SELECT install_date, COUNT(DISTINCT player_id) AS total_installs,
COUNT(DISTINCT CASE WHEN last_active_date >= install_date + INTERVAL 7 DAY THEN player_id END) AS retained_players,
ROUND(COUNT(DISTINCT CASE WHEN last_active_date >= install_date + INTERVAL 7 DAY THEN player_id END) * 100.0 / COUNT(DISTINCT player_id), 2) AS D7_retention
FROM players
GROUP BY install_date
ORDER BY install_date;
