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
  ,  p.assignment_date
  ,  coalesce(sum(a.purchases), 0) as purchases
  ,  coalesce(sum(a.gameends), 0) as gamerounds
  ,  count(distinct date(a.activity_date)) as active_days
  ,  max(if(date_diff(date(a.activity_date), p.assignment_date, day) = 1, 1, 0)) as d1
  ,  max(if(date_diff(date(a.activity_date), p.assignment_date, day) = 3, 1, 0)) as d3
  ,  max(if(date_diff(date(a.activity_date), p.assignment_date, day) = 7, 1, 0)) as d7
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group, p.assignment_date
)

select
   abtest_group
,  count(*) as players
,  avg(purchases) as mean_purchases
,  stddev(purchases) as sd_purchases
,  avg(gamerounds) as mean_gamerounds
,  stddev(gamerounds) as sd_gamerounds
,  avg(active_days) as mean_active_days
,  stddev(active_days) as sd_active_days
,  countif(date_diff(date '2017-05-22', assignment_date, day) >= 1) as d1_eligible
,  sum(if(date_diff(date '2017-05-22', assignment_date, day) >= 1, d1, 0)) as d1_returned
,  countif(date_diff(date '2017-05-22', assignment_date, day) >= 3) as d3_eligible
,  sum(if(date_diff(date '2017-05-22', assignment_date, day) >= 3, d3, 0)) as d3_returned
,  countif(date_diff(date '2017-05-22', assignment_date, day) >= 7) as d7_eligible
,  sum(if(date_diff(date '2017-05-22', assignment_date, day) >= 7, d7, 0)) as d7_returned
from player_metrics
group by abtest_group
order by abtest_group;
