-- Cookie Cats A/B test: SQL version
-- Table: cookie_cats (90,189 players)

-- Check 1: Row count (expected 90,189)
SELECT COUNT(*) AS total_players
FROM cookie_cats;

-- Preview: first 5 rows
SELECT *
FROM cookie_cats
LIMIT 5;

-- Check 2: Players per group (expected 44,700 and 45,489)
SELECT version,
       COUNT(*) AS players
FROM cookie_cats
GROUP BY version;

-- Check 3: Retention by group
-- Expected day 7: 19.02% / 18.20%; day 1: 44.82% / 44.23%
SELECT version,
       COUNT(*) AS players,
       SUM(CASE WHEN retention_7 = 'True' THEN 1 ELSE 0 END) AS retained_day7,
       ROUND(100.0 * SUM(CASE WHEN retention_7 = 'True' THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_7_pct,
       SUM(CASE WHEN retention_1 = 'True' THEN 1 ELSE 0 END) AS retained_day1,
       ROUND(100.0 * SUM(CASE WHEN retention_1 = 'True' THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_1_pct
FROM cookie_cats
GROUP BY version;

-- Check 4: Sensitivity check, excluding zero-round players
-- Expected: 42,763 / 43,432 players; day 7: 19.84% / 19.03%
SELECT version,
       COUNT(*) AS players,
       SUM(CASE WHEN retention_7 = 'True' THEN 1 ELSE 0 END) AS retained_day7,
       ROUND(100.0 * SUM(CASE WHEN retention_7 = 'True' THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_7_pct
FROM cookie_cats
WHERE sum_gamerounds > 0
GROUP BY version;

-- Check 5: Data quality and rounds played
-- Expected: 90,189 unique players, min 0, max 49,854, avg 51.87, 3,994 zero-round players, 0 bad values
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT userid) AS unique_players,
       MIN(sum_gamerounds) AS min_rounds,
       MAX(sum_gamerounds) AS max_rounds,
       ROUND(AVG(sum_gamerounds), 2) AS avg_rounds,
       SUM(CASE WHEN sum_gamerounds = 0 THEN 1 ELSE 0 END) AS zero_round_players,
       SUM(CASE WHEN retention_7 NOT IN ('True', 'False') THEN 1 ELSE 0 END) AS bad_retention_values
FROM cookie_cats;

-- Check 6: Guardrail, average rounds by group (with and without the outlier)
-- Expected: all players 52.46 / 51.30; excluding outlier 51.34 / 51.30
SELECT version,
       ROUND(AVG(sum_gamerounds), 2) AS avg_rounds_all,
       ROUND(AVG(CASE WHEN sum_gamerounds < 49854 THEN sum_gamerounds END), 2) AS avg_rounds_excl_outlier
FROM cookie_cats
GROUP BY version;

-- Check 7: Chi-square statistic for 7-day retention
-- Expected: about 10.01 (p = 0.0016 when converted in Excel)
WITH counts AS (
    SELECT version,
           COUNT(*) AS group_n,
           SUM(CASE WHEN retention_7 = 'True' THEN 1 ELSE 0 END) AS retained
    FROM cookie_cats
    GROUP BY version
),
totals AS (
    SELECT SUM(group_n) AS total_n,
           SUM(retained) AS total_retained
    FROM counts
)
SELECT ROUND(SUM(
         (retained - group_n * 1.0 * total_retained / total_n)
       * (retained - group_n * 1.0 * total_retained / total_n)
       / (group_n * 1.0 * total_retained / total_n)
     + ((group_n - retained) - group_n * 1.0 * (total_n - total_retained) / total_n)
       * ((group_n - retained) - group_n * 1.0 * (total_n - total_retained) / total_n)
       / (group_n * 1.0 * (total_n - total_retained) / total_n)
       ), 4) AS chi_square
FROM counts, totals;