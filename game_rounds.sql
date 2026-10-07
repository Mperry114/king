with players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
  -- optional fixed cohort, so every day has the same players:
  -- and date(assignment_date) <= '2017-05-06'
),
 
daily_activity as (
  select
     p.abtest_group
  ,  date_diff(date(a.activity_date), p.assignment_date, day) as day_since_assignment
  ,  count(distinct a.playerid) as active_players
  ,  sum(a.gameends) as gamerounds
  from players as p
  join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) >= '2017-05-04' and date(a.activity_date) <= '2017-05-22'
  group by p.abtest_group, day_since_assignment
),
 
eligible_players as (
  select
     p.abtest_group
  ,  day_since_assignment
  ,  count(distinct p.playerid) as eligible_players
  from players as p
  cross join unnest(generate_array(0, date_diff(date '2017-05-22', p.assignment_date, day))) as day_since_assignment
  group by p.abtest_group, day_since_assignment
)
 
select
   e.abtest_group
,  e.day_since_assignment
,  e.eligible_players
,  d.active_players
,  safe_divide(d.active_players, e.eligible_players) as active_rate
,  safe_divide(d.gamerounds, d.active_players) as avg_gamerounds_per_active_player
from eligible_players as e
left join daily_activity as d
  on  d.abtest_group = e.abtest_group
  and d.day_since_assignment = e.day_since_assignment
order by e.abtest_group, e.day_since_assignment;
