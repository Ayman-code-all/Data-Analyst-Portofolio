-- ARPU

SELECT COUNT(DISTINCT player_id) AS total_players,
ROUND(SUM(amount), 2) AS total_revenue,
ROUND(SUM(amount) / COUNT(DISTINCT player_id), 2) AS ARPU
FROM transactions
WHERE transaction_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20';

-- ARPPU

WITH total_revenue AS (
	SELECT SUM(amount) AS total_revenue
	FROM transactions
	WHERE transaction_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20'
),
total_paid_users AS (
	SELECT COUNT(DISTINCT player_id) AS total_payers
	FROM transactions
	WHERE transaction_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 30 DAY) AND '2024-03-20'
)
SELECT ROUND(total_revenue / total_payers, 2) AS ARPPU
FROM total_revenue, total_paid_users;

-- Whales (Top 5% of spenders)

WITH player_spending AS (
	SELECT player_id, ROUND(SUM(amount), 2) AS total_spending
	FROM transactions
	WHERE transaction_date BETWEEN DATE_SUB('2024-03-20', INTERVAL 60 DAY) AND '2024-03-20'
	GROUP BY player_id
),
ranked_spending AS (
	SELECT player_id, total_spending,
	PERCENT_RANK() OVER (ORDER BY total_spending DESC) AS percentile
	FROM player_spending
)
SELECT player_id, total_spending
FROM ranked_spending
WHERE percentile <= 0.05;
