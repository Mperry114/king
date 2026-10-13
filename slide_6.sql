-- Purchase uplift by day since assigment

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with daily as (
  select
     p.abtest_group
  ,  date_diff(date(a.activity_date), p.assignment_date, day) as day_since_assignment
  ,  safe_divide(sum(a.purchases), count(distinct a.playerid)) as purchases_per_active_player
  from players as p
  join `king-ds-recruit-candidate-1121.abtest.assignment` as s
    on  s.playerid = p.playerid
  join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  where date(s.install_date) < '2017-05-04'
  group by p.abtest_group, day_since_assignment
)

select
   day_since_assignment
,  max(if(abtest_group = 'A', purchases_per_active_player, null)) as control
,  max(if(abtest_group = 'B', purchases_per_active_player, null)) as test
,  safe_divide(max(if(abtest_group = 'B', purchases_per_active_player, null))
             , max(if(abtest_group = 'A', purchases_per_active_player, null))) - 1 as test_uplift
from daily
group by day_since_assignment
order by day_since_assignment;


-- Purchase uplift by player type, whole test

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with segment as (
  select
     p.abtest_group
  ,  if(date(s.install_date) >= '2017-05-04', 'new install', 'existing') as player_type
  ,  safe_divide(sum(a.purchases), count(distinct concat(cast(a.playerid as string), cast(date(a.activity_date) as string)))) as purchases_per_active_player_day
  from players as p
  join `king-ds-recruit-candidate-1121.abtest.assignment` as s
    on  s.playerid = p.playerid
  join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.abtest_group, player_type
)

select
   player_type
,  safe_divide(max(if(abtest_group = 'B', purchases_per_active_player_day, null))
             , max(if(abtest_group = 'A', purchases_per_active_player_day, null))) - 1 as test_uplift
from segment
group by player_type
order by player_type;
