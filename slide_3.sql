-- Retention rate

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with player_retention as (
  select
     p.playerid
  ,  p.abtest_group
  ,  p.assignment_date
  ,  max(if(date_diff(date(a.activity_date), p.assignment_date, day) = 1, 1, 0)) as d1
  ,  max(if(date_diff(date(a.activity_date), p.assignment_date, day) = 3, 1, 0)) as d3
  ,  max(if(date_diff(date(a.activity_date), p.assignment_date, day) = 7, 1, 0)) as d7
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) > p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group, p.assignment_date
)

select
   abtest_group
,  avg(if(date_diff(date '2017-05-22', assignment_date, day) >= 1, d1, null)) as d1_retention
,  avg(if(date_diff(date '2017-05-22', assignment_date, day) >= 3, d3, null)) as d3_retention
,  avg(if(date_diff(date '2017-05-22', assignment_date, day) >= 7, d7, null)) as d7_retention
from player_retention
group by abtest_group
order by abtest_group;


-- Average game rounds per player

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with player_rounds as (
  select
     p.playerid
  ,  p.abtest_group
  ,  coalesce(sum(a.gameends), 0) as gamerounds
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
)

select
   abtest_group
,  avg(gamerounds) as avg_gamerounds_per_player
from player_rounds
group by abtest_group
order by abtest_group;


-- Average active days per player

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with player_days as (
  select
     p.playerid
  ,  p.abtest_group
  ,  count(distinct date(a.activity_date)) as active_days
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
)

select
   abtest_group
,  avg(active_days) as avg_active_days_per_player
from player_days
group by abtest_group
order by abtest_group;
