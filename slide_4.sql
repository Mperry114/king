-- Average rounds per active player

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

select
   p.abtest_group
,  date_diff(date(a.activity_date), p.assignment_date, day) as day_since_assignment
,  count(distinct a.playerid) as active_players
,  safe_divide(sum(a.gameends), count(distinct a.playerid)) as avg_gamerounds_per_active_player
from players as p
join `king-ds-recruit-candidate-1121.abtest.activity` as a
  on  a.playerid = p.playerid
  and date(a.activity_date) >= p.assignment_date
  and date(a.activity_date) <= '2017-05-22'
group by p.abtest_group, day_since_assignment
order by p.abtest_group, day_since_assignment;
