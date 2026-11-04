USE nfl_draft_analytics;


/* Query 1: Display the 20 highest-performing players 
drafted in rounds 4–7, ranked by weighted career value. */

SELECT
    pfr_player_name, season, round, pick, team, position,
    college,
    w_av
FROM draft_picks
WHERE round BETWEEN 4 AND 7
ORDER BY w_av DESC
LIMIT 20;


/* Query 2: Compare the number of players, 
average weighted career value, and average games played across draft rounds 1–7. */

SELECT
    round,
    COUNT(*) AS player_count,
    ROUND(AVG(w_av), 2) AS average_weighted_value,
    ROUND(AVG(games), 2) AS games_average
FROM draft_picks
WHERE round BETWEEN 1 AND 7
GROUP BY round
ORDER BY round ASC;


/* Query 3: Compare colleges by drafted player count, 
average weighted career value, and 
total weighted career value for draft classes 
from 2000–2020. Only include colleges with at least 20 drafted players. */

SELECT
    college,
    COUNT(*) AS player_count,
    ROUND(AVG(w_av), 2) AS average_career_value,
    SUM(w_av) AS total_w_av
FROM draft_picks
WHERE season BETWEEN 2000 AND 2020
GROUP BY college
HAVING COUNT(*) >= 20
ORDER BY average_career_value DESC;

/* Query 4: Join draft and combine data to display players’ 
draft information, athletic measurements, and weighted career value for the 
2000–2020 draft classes, sorted by highest career value. */
SELECT d.pfr_player_name , c.draft_year, d.position , d.round ,
d.pick , c.forty , c.bench , c.vertical , d.w_av
FROM draft_picks AS d
JOIN combine AS c
ON d.pfr_player_id = c.pfr_id
WHERE d.season BETWEEN 2000 AND 2020
ORDER BY  d.w_av DESC;
/* Query 5: Compare combine performance and NFL career value 
across positions by calculating the number of matched players and 
average 40-yard dash, bench press, vertical jump, and weighted career value for draft classes from
 2000–2020. Only include positions with at least 50 matched players. */
SELECT
    d.position,
    COUNT(d.position) AS matched_players,
    ROUND(AVG(c.forty), 2) AS average_forty,
    ROUND(AVG(c.bench), 2) AS average_bench,
    ROUND(AVG(c.vertical), 2) AS average_vertical,
    ROUND(AVG(d.w_av), 2) AS average_w_av
FROM draft_picks AS d
JOIN combine AS c
    ON d.pfr_player_id = c.pfr_id
WHERE d.season BETWEEN 2000 AND 2020
GROUP BY d.position
HAVING COUNT(*) >= 50
ORDER BY average_w_av DESC;

/* Query 6: Categorize wide receivers by 40-yard-dash speed and 
compare the number of players and average weighted career value in each 
speed category for draft classes from 2000–2020. */
SELECT
    CASE
        WHEN c.forty < 4.40 THEN 'Elite Speed'
        WHEN c.forty < 4.60 THEN 'Average Speed'
        ELSE 'Below Average Speed'
    END AS speed_group,
    COUNT(*) AS player_count,
    ROUND(AVG(d.w_av), 2) AS average_w_av
FROM draft_picks AS d
JOIN combine AS c
    ON d.pfr_player_id = c.pfr_id
WHERE d.season BETWEEN 2000 AND 2020
  AND d.position = 'WR'
  AND c.forty IS NOT NULL
GROUP BY speed_group
ORDER BY average_w_av DESC;


/* Query 7: Categorize drafted offensive and 
defensive linemen by bench-press strength and 
compare player counts and average weighted career value for each strength group from 2000–2020. */
SELECT
    CASE
        WHEN c.bench < 20 THEN 'Below Average Strength'
        WHEN c.bench < 25 THEN 'Average Strength'
        ELSE 'Elite Strength'
    END AS strength_group,
    COUNT(*) AS player_count,
    ROUND(AVG(d.w_av), 2) AS average_w_av
FROM draft_picks AS d
JOIN combine AS c
    ON d.pfr_player_id = c.pfr_id
WHERE d.season BETWEEN 2000 AND 2020
  AND d.category IN ('DL', 'OL')
  AND c.bench IS NOT NULL
GROUP BY strength_group
ORDER BY average_w_av DESC;

/* Query 8: Identify the biggest draft 
steals by comparing each player’s weighted career value with the average weighted 
career value of players selected in the same round from 2000–2020. */
WITH round_averages AS (
	SELECT ROUND , AVG(w_av) AS round_average
    FROM draft_picks AS r
    WHERE season BETWEEN 2000 AND 2020 AND round BETWEEN 1 AND 7
    GROUP BY round)
SELECT d.pfr_player_name , d.season as draft_year, d.team , d.pick, d.position , d.round , d.w_av,
 d.w_av - r.round_average AS value_above_round_average
FROM draft_picks AS d 
JOIN round_averages AS r
    ON d.round = r.round
WHERE d.season BETWEEN 2000 AND 2020 AND r.round BETWEEN 1 AND 7
ORDER BY value_above_round_average DESC
LIMIT 20;    
/* Query 9: Identify the biggest draft 
busts by comparing each player’s weighted career value with the average weighted 
career value of players selected in the same round from 2000–2020. */
WITH round_averages AS (
	SELECT round , AVG(w_av) AS round_average
    FROM draft_picks AS r
    WHERE season BETWEEN 2000 AND 2020 AND round BETWEEN 1 AND 2
    GROUP BY round)
SELECT d.pfr_player_name , d.season as draft_year, d.team , d.pick, d.position , d.round , d.w_av,
 d.w_av - r.round_average AS value_above_round_average
FROM draft_picks AS d 
JOIN round_averages AS r
    ON d.round = r.round
WHERE d.season BETWEEN 2000 AND 2020 AND r.round BETWEEN 1 AND 2
ORDER BY value_above_round_average ASC
LIMIT 20;    

/* Query 10: Rank players within their respective
 positions by weighted career value and display the five highest-ranked
 players at each position from the 2000–2020 draft classes. */
 
WITH ranked_players AS (
SELECT pfr_player_name,
        season, team, pick, position, round, w_av,
        DENSE_RANK() OVER (
    PARTITION BY position
    ORDER BY w_av DESC
) AS position_rank
    FROM draft_picks as r
    WHERE r.season BETWEEN 2000 AND 2020
)
SELECT pfr_player_name , season as draft_year, team , pick, position , round , w_av,
  position_rank
FROM ranked_players 
WHERE season BETWEEN 2000 AND 2020 AND round BETWEEN 1 AND 7 AND position_rank <=5
ORDER BY position ASC, position_rank ASC;

/*  */

/* Query 11: Rank NFL teams by draft efficiency by 
comparing their selections' weighted career value 
with the average value expected from each draft round between 2000 and 2020. */

WITH round_averages AS (
    SELECT
        round,
        AVG(w_av) AS round_average
    FROM draft_picks
    WHERE season BETWEEN 2000 AND 2020
      AND round BETWEEN 1 AND 7
      AND w_av IS NOT NULL
    GROUP BY round
)
SELECT
    d.team,
    COUNT(*) AS num_players_drafted,
    ROUND(AVG(d.w_av), 2) AS avg_career_value,
    ROUND(AVG(d.w_av - r.round_average), 2)
        AS avg_value_above_round_average,
    ROUND(SUM(d.w_av - r.round_average), 2)
        AS total_value_above_round_average
FROM draft_picks AS d
JOIN round_averages AS r
    ON d.round = r.round
WHERE d.season BETWEEN 2000 AND 2020
  AND d.round BETWEEN 1 AND 7
  AND d.w_av IS NOT NULL
  AND d.team IS NOT NULL
GROUP BY d.team
HAVING COUNT(*) >= 50
ORDER BY avg_value_above_round_average DESC;
