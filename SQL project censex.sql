select * from project.dbo.Data1;

select * from project.dbo.Data2;

-- number of rows into our dataset

select count(*) from project..Data1
select count(*) from project..Data2

-- dataset for jharkhand and bihar

select * from project..Data1 where [State ] in ('Jharkhand' ,'Bihar')

-- population of India

select sum(population) as Population from project..Data2

-- avg growth 

select [State ],avg(growth)*100 avg_growth from project..Data1 group by [State ];

-- avg sex ratio

select [State ],round(avg(sex_ratio),0) avg_sex_ratio from project..Data1 group by [State ] order by avg_sex_ratio desc;

-- avg literacy rate
 
select [State ],round(avg(literacy),0) avg_literacy_ratio from project..Data1 
group by [State ] having round(avg(literacy),0)>90 order by avg_literacy_ratio desc ;

-- top 3 state showing highest growth ratio

select  [State ],avg(growth)*100 avg_growth from project..Data1 group by [State ] order by avg_growth desc 

--bottom 3 state showing lowest sex ratio

select top 3 [State ],round(avg(sex_ratio),0) avg_sex_ratio from project..Data1 group by [State ] order by avg_sex_ratio asc;

-- top and bottom 3 states in literacy state

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstate float

  )

insert into #topstates
select [State ],round(avg(literacy),0) avg_literacy_ratio from project..Data1 
group by [State ] order by avg_literacy_ratio desc;



select top 3 * from #topstates order by #topstates.topstate desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select [State ],round(avg(literacy),0) avg_literacy_ratio from project..Data1 
group by [State ] order by avg_literacy_ratio desc;


select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;

--union opertor

select * from (
select top 3 * from #topstates order by #topstates.topstate desc) a

union

select * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;

-- states starting with letter a

select distinct [State ] from project..Data1 where lower([State ]) like 'a%' or lower([State ]) like 'b%'

select distinct [State ] from project..Data1 where lower([State ]) like 'a%' and lower([State ]) like '%m'

-- joining both table

--total males and females

select d.state,sum(d.males) total_males,sum(d.females) total_females from
(select c.district,c.[State ] state,round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district,a.[State ],a.sex_ratio/1000 sex_ratio,b.population from project..Data1 a inner join project..data2 b on a.district=b.[District ] ) c) d
group by d.state;

-- total literacy rate


select c.[State ],sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 
(select d.district,d.[State ],round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)* d.population,0) illiterate_people from
(select a.district,a.[State ],a.literacy/100 literacy_ratio,b.population from project..Data1 a 
inner join project..Data2 b on a.district=b.[District ]) d) c
group by c.[State ]

-- population in previous census


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..Data1 a inner join project..Data2 b on a.district=b.[District ]) d) e
group by e.state)m

-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from (

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from(
select e.[State ],sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.[State ],round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.[State ],a.growth growth,b.population from project..Data1 a inner join project..Data2 b on a.district=b.[District ]) d) e
group by e.[State ])m) n) q inner join (

select '1' as keyy,z.* from (
select SUM (area_km2)total_area from project..Data2)z) r on q.keyy=r.keyy)g

--window 

output top 3 districts from each state with highest literacy rate


select a.* from
(select district,[State ],literacy,rank() over(partition by state order by literacy desc) rnk from project..Data1) a

where a.rnk in (1,2,3) order by [State ]