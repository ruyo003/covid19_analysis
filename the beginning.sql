SELECT * 
FROM results_db.new
-- where continent is not null
order by 3,4;

-- SELECT * 
-- FROM results_db.second
-- where continent is not null
-- order by 3,4

-- select data that we will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM results_db.new
where continent is not null
order by 1,2;

-- comparing the total cases versus the deaths
-- shows the likelihood of dying with covid per country
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as deathpercentage
FROM results_db.new
where location like '%kenya%' and continent is not null
order by 1,2;

-- looking at total cases vs population
-- shows the percentage of population that got covid

SELECT location, date, total_cases, population, (total_cases/ population)*100 as percentpopulationinfected
FROM results_db.new
-- where location like '%kenya%'
where continent is not null
order by 1,2;

-- countries with highest infection rate vs population

SELECT location, population, max(total_cases) as highestinfections, max((total_cases/ population))*100 as highestinfectionpercentage
FROM results_db.new
where continent is not null
group by location, population
order by highestinfectionpercentage DESC;

-- showing the countries with the highest death count per population


SELECT location, max(cast(total_cases as float)) as totaldeathcount
FROM results_db.new
where continent is not null
group by location
order by totaldeathcount desc;

-- data by continent

SELECT continent, max(cast(total_cases as float)) as totaldeathcount
FROM results_db.new
where continent is not null
group by continent
order by totaldeathcount desc;

-- breaking into global numbers

SELECT date, sum(new_cases)as newcasescount, sum(new_deaths)as newdeathcount, sum(new_deaths)/sum(new_cases)*100 as deathpercentage
FROM results_db.new
where continent is not null
group by date
order by deathpercentage desc;

-- joining the new and second tables

select n.continent, n.location, n.date, n.population, cast(s.new_vaccinations as float)
from results_db.new n
join results_db.second s
	on n.location = s.location
	and n.date = s.date
where n.continent is not null
order by 5 desc;

-- looking at rolling pplevaccinated

select n.continent, n.location, n.date, n.population, s.new_vaccinations
, sum(cast(s.new_vaccinations as float)) OVER (partition by n.location order by n.location, n.date) as ppvaccinated
from results_db.new n
join results_db.second s
	on n.location = s.location
	and n.date = s.date
where n.continent is not null
order by 2,3;

-- use CTE
with newsecond (continent, location, date, population, new_vaccinations, ppvaccinated)
as
(
select n.continent, n.location, n.date, n.population, s.new_vaccinations
, sum(cast(s.new_vaccinations as float)) OVER (partition by n.location order by n.location, n.date) as ppvaccinated
from results_db.new n
join results_db.second s
	on n.location = s.location
	and n.date = s.date
where n.continent is not null
-- order by 2,3
)
select * , (ppvaccinated/population)*100 as overallpercent
from newsecond


-- temp table , didnt work
drop table if exist #percentofpplevaccinated
Create Table #percentofpplevaccinated
(
continent nvachar(255),
location nvachar(255),
date datetime,
population numeric,
new_vaccinations numeric,
ppvaccinated numeric,
)
insert into #percentofpplevaccinated
select n.continent, n.location, n.date, n.population, s.new_vaccinations
, sum(cast(s.new_vaccinations as float)) OVER (partition by n.location order by n.location, n.date) as ppvaccinated
from results_db.new n
join results_db.second s
	on n.location = s.location
	and n.date = s.date
where n.continent is not null
-- order by 2,3

select * , (ppvaccinated/population)*100 as overallpercent
from #percentofpplevaccinated

-- creating views to store data for later visualisation 

create view percentofpple as 
select n.continent, n.location, n.date, n.population, s.new_vaccinations
, sum(cast(s.new_vaccinations as float)) OVER (partition by n.location order by n.location, n.date) as ppvaccinated
from results_db.new n
join results_db.second s
	on n.location = s.location
	and n.date = s.date
where n.continent is not null
-- order by 2,3





