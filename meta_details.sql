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
  ,  count(distinct a.activity_date)          as active_days
  ,  sum(a.purchases)                         as purchases
  ,  sum(a.gameends)                          as gamerounds
  ,  if(sum(a.purchases) > 0, 1, 0)           as is_payer
  from players as p
  left join `king-ds-recruit-candidate-1121.abtest.activity` as a
    on  a.playerid = p.playerid
    and date(a.activity_date) >= date(p.assignment_date)
    and date(activity_date) >= date('2017-05-04') and date(activity_date) <= '2017-05-22'
  group by p.playerid, p.abtest_group
),
 
medians as (
  select
     distinct *
  ,  percentile_cont(active_days, 0.5) over (partition by abtest_group) as median_active_days
  ,  percentile_cont(purchases,   0.5) over (partition by abtest_group) as median_purchases
  ,  percentile_cont(gamerounds,  0.5) over (partition by abtest_group) as median_gamerounds
  from player_metrics
)
 
select
   abtest_group
  ,  count(distinct playerid)        as distinct_players
  ,  count(distinct if(is_payer = 1, playerid,0)) as paying_players
  ,  count(distinct if(is_payer = 1, playerid,0))/count(distinct playerid) as share_paying_players
  ,  any_value(median_active_days)   as median_active_days
  ,  any_value(median_purchases)     as median_purchases
  ,  any_value(median_gamerounds)    as median_gamerounds
from medians
group by abtest_group
order by abtest_group;
 
