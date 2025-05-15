-- Daily Active Users
SELECT session_date, COUNT(DISTINCT player_id) AS DAU
FROM game_sessions
WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20'
GROUP BY session_date
ORDER BY session_date;

-- Weekly Active Users
SELECT '2024-03-20' AS end_date,
COUNT(DISTINCT player_id) AS WAU
FROM game_sessions
WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 7 DAY) AND '2024-03-20';

-- Monthly Active Users
SELECT COUNT(DISTINCT player_id) AS MAU
FROM game_sessions
WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20';

-- Stickiness Ratio
WITH daily_active_users AS (
	SELECT session_date, COUNT(DISTINCT player_id) AS DAU
	FROM game_sessions
	WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20'
	GROUP BY session_date
),
monthly_active_users AS (
	SELECT COUNT(DISTINCT player_id) AS MAU
	FROM game_sessions
	WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20'
)
SELECT ROUND(AVG(DAU) / (SELECT MAU FROM monthly_active_users), 2) AS Stickiness_ratio
FROM daily_active_users;

-- High Engagement Players
SELECT player_id AS High_Engagement_players_id, COUNT(DISTINCT session_date) AS sessions_counts
FROM game_sessions
WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 60 DAY) AND '2024-03-20'
GROUP BY player_id
HAVING sessions_counts >= 10;

-- Player classification (Whales, Paying, Casual, etc.)
WITH player_engagement AS (
	SELECT player_id, COUNT(DISTINCT session_date) AS sessions_count
	FROM game_sessions
	WHERE session_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 60 DAY) AND '2024-03-20'
	GROUP BY player_id
),
player_spending AS (
	SELECT player_id, ROUND(SUM(amount), 2) AS total_spending
	FROM transactions
	WHERE transaction_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 60 DAY) AND '2024-03-20'
	GROUP BY player_id
),
classified_players AS (
	SELECT pe.player_id, pe.sessions_count, ps.total_spending,
		CASE
			WHEN ps.total_spending >= (SELECT MAX(amount) * 0.05 FROM transactions) THEN 'Whale'
			WHEN ps.total_spending > 0 THEN 'Paying'
			WHEN pe.sessions_count >= 10 THEN 'High Engagement'
			WHEN pe.sessions_count < 5 THEN 'Casual'
			ELSE 'Others'
		END AS Player_classification
	FROM player_engagement pe
	LEFT JOIN player_spending ps ON pe.player_id = ps.player_id
)
SELECT player_id, sessions_count, Player_classification
FROM classified_players;
