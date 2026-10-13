-- Average purchases, all players

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with player_purchases as (
  select
     p.playerid
  ,  p.abtest_group
  ,  coalesce(sum(a.purchases), 0) as purchases
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
)

select
   abtest_group
,  avg(purchases) as avg_purchases_per_player
from player_purchases
group by abtest_group
order by abtest_group;

-- Average purchases, MTX players only

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with player_purchases as (
  select
     p.playerid
  ,  p.abtest_group
  ,  sum(a.purchases) as purchases
  from players as p
  join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
  having sum(a.purchases) > 0
)

select
   abtest_group
,  avg(purchases) as avg_purchases_per_payer
from player_purchases
group by abtest_group
order by abtest_group;

-- Share of MTX purchasers

create temporary table players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
);

with player_purchases as (
  select
     p.playerid
  ,  p.abtest_group
  ,  coalesce(sum(a.purchases), 0) as purchases
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= p.assignment_date
    and date(a.activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
)

select
   abtest_group
,  avg(if(purchases > 0, 1, 0)) as share_paying_players
from player_purchases
group by abtest_group
order by abtest_group;
