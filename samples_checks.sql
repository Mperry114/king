-- Player belong to only one group

SELECT playerid
  , count(distinct abtest_group) assignment_groups
FROM `king-ds-recruit-candidate-1121.abtest.assignment`
group by 1
order by 2 desc

-- 20:80 ratio assigned as intended

SELECT distinct abtest_group
  , safe_divide(count(distinct playerid) over(partition by abtest_group)
    ,count(distinct playerid) over()
   ) player_count
FROM `king-ds-recruit-candidate-1121.abtest.assignment`

-- Average days install to assignment

with players as (
  select
     distinct playerid
  ,  abtest_group
  ,  date(install_date) install_date
  ,  date(assignment_date) assignment_date
  from `king-ds-recruit-candidate-1121.abtest.assignment`
  where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
)

select
   abtest_group
,  count(*) as players
,  avg(date_diff(assignment_date, install_date, day)) as avg_days_install_to_assignment
,  approx_quantiles(date_diff(assignment_date, install_date, day), 2)[offset(1)] as median_days_install_to_assignment
,  avg(if(install_date >= '2017-05-04', 1, 0)) as share_new_installs
,  countif(install_date > assignment_date) as installed_after_assignment
from players
group by abtest_group
order by abtest_group;

-- Day 1 assignment rate

select
   abtest_group
,  count(distinct playerid) as players
,  avg(if(date(assignment_date) = '2017-05-04', 1, 0)) as share_assigned_day_one
from `king-ds-recruit-candidate-1121.abtest.assignment`
where date(assignment_date) >= '2017-05-04' and date(assignment_date) <= '2017-05-22'
group by abtest_group
order by abtest_group;
