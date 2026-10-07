with players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
),
 
player_retention as (
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
,  countif(date_diff(date '2017-05-22', assignment_date, day) >= 1) as d1_eligible_players
,  avg(if(date_diff(date '2017-05-22', assignment_date, day) >= 1, d1, null)) as d1_retention
,  countif(date_diff(date '2017-05-22', assignment_date, day) >= 3) as d3_eligible_players
,  avg(if(date_diff(date '2017-05-22', assignment_date, day) >= 3, d3, null)) as d3_retention
,  countif(date_diff(date '2017-05-22', assignment_date, day) >= 7) as d7_eligible_players
,  avg(if(date_diff(date '2017-05-22', assignment_date, day) >= 7, d7, null)) as d7_retention
from player_retention
group by abtest_group
order by abtest_group;
