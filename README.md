# NFL-Draft-Analysis-SQL-
MySQL analytics project using NFLverse draft and combine data to evaluate player performance, identify draft steals and underperformers, compare combine results, and rank NFL teams by drafting efficiency.


This project uses MySQL and NFLverse data to analyze NFL Draft outcomes from 2000–2020. It combines draft history, career value, and NFL Combine measurements to identify draft steals, underperforming selections, position leaders, college production, athletic-performance trends, and team drafting efficiency. The analysis demonstrates SQL joins, aggregate functions, CASE expressions, CTEs, calculated metrics, and window functions.

The project uses two NFLverse CSV datasets: draft_picks.csv, containing draft information and NFL career outcomes, and combine.csv, containing player measurements and athletic testing results. Both datasets were imported into MySQL and connected using Pro Football Reference player IDs.

## Data Sources

- `draft_picks.csv` — Draft year, round, overall pick, team, college, position, career statistics, and weighted approximate value.
- `combine.csv` — Height, weight, 40-yard dash, bench press, vertical jump, broad jump, cone drill, and shuttle results.

The datasets were obtained from NFLverse and imported into MySQL for analysis.

