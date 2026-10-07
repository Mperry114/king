
WITH players AS (
  SELECT
    distinct playerid,
    abtest_group,
    date(assignment_date) assignment_date
  FROM `king-ds-recruit-candidate-1121.abtest.assignment`
  WHERE date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
),
 
player_metrics AS (
  SELECT
    p.playerid,
    p.abtest_group,
    COUNT(DISTINCT a.activity_date)  AS active_days,
    SUM(a.purchases)    AS purchases,
    SUM(a.gameends)     AS gamerounds
  FROM players AS p
  LEFT JOIN `king-ds-recruit-candidate-1121.abtest.activity` AS a
    ON  a.playerid = p.playerid
    AND date(a.activity_date) >= date(p.assignment_date)
    AND date(activity_date) >= date('2017-05-04') and date(activity_date) <= '2017-05-22'
  GROUP BY p.playerid, p.abtest_group
),
 
with_medians AS (
  SELECT
    distinct abtest_group,
    playerid,
    PERCENTILE_CONT(active_days, 0.5) OVER (PARTITION BY abtest_group) AS median_active_days,
    PERCENTILE_CONT(purchases,   0.5) OVER (PARTITION BY abtest_group) AS median_purchases,
    PERCENTILE_CONT(gamerounds,  0.5) OVER (PARTITION BY abtest_group) AS median_gamerounds
  FROM player_metrics
)
 
SELECT
  abtest_group,
  COUNT(DISTINCT playerid)        AS distinct_players,
  ANY_VALUE(median_active_days)   AS median_active_days,
  ANY_VALUE(median_purchases)     AS median_purchases,
  ANY_VALUE(median_gamerounds)    AS median_gamerounds
FROM with_medians
GROUP BY abtest_group
ORDER BY abtest_group;
