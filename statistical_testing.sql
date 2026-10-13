with players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
),

player_metrics as (
  select
     p.playerid
  ,  p.abtest_group
  ,  coalesce(sum(a.purchases), 0) as purchases
  ,  safe_divide(sum(if(date(a.activity_date) > p.assignment_date, a.gameends, 0))
               , countif(date(a.activity_date) > p.assignment_date)) as rounds_per_active_day
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
)

select
   abtest_group
,  count(*) as players
,  avg(purchases) as mean_purchases
,  stddev(purchases) as sd_purchases
,  count(rounds_per_active_day) as players_with_activity
,  avg(rounds_per_active_day) as mean_rounds_per_active_day
,  stddev(rounds_per_active_day) as sd_rounds_per_active_day
from player_metrics
group by abtest_group
order by abtest_group;
