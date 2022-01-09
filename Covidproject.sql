select * from PortfolioProject.. CovidDeaths
order by 3,4

-- selecting data required from the table

select location,date, population,total_cases, new_cases,total_deaths
from PortfolioProject.. CovidDeaths
order by 1,2

--percentage population infected from covid each day
select location,date, population,total_cases, (total_cases/population*100) as percentageinfected
from PortfolioProject.. CovidDeaths
order by 1,2 


-- percentage of people died from Covid in India(likelihood of dying of people contracted from covid)

select location,date, population,total_cases,total_deaths, Round(total_deaths/total_cases*100, 3) as deathpercentage
from PortfolioProject.. CovidDeaths
where location= 'India'
order by 1,2 

--finding highest infection rate on any day

select location, population,Max(total_cases) as Max_cases,Round(Max(total_cases)/population*100,5) as percentageinfected
from PortfolioProject.. CovidDeaths
group by location, population
order by percentageinfected desc

--countries with highest death count wrt population on a single day

select location, population, Max(cast(total_deaths as int)) as max_deathcount 
-- Round(Max(total_deaths)/population*100, 3) as deathpercentage
from PortfolioProject.. CovidDeaths
where continent is not NULL 
group by location, population
order by max_deathcount desc



--breaking it down by continent
--showing highest death count per population


select continent, SUM(population) as totalpopulation, SUM(total) as Totaldeaths, SUM(total)/SUM(population) deathrate
from (
	select continent,location,population, Max(cast(total_deaths as int)) as 'total' 
	from PortfolioProject.. CovidDeaths
	where continent is not null
	group by continent,location, population  --Gives the total death count of each location in the continent
	--order by total desc
	) as t
group by continent
order by deathrate desc


select location, Max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject.. CovidDeaths
where continent is null
group by location
order by totaldeathcount desc


--global number: total cases, total deaths, death percentage each day

select date, SUM(total_cases) as Totalcases,SUM(cast(total_deaths as int)) as Totaldeaths, Round(SUM(cast(total_deaths as int))/SUM(total_cases)*100, 3) as deathpercentage
from PortfolioProject.. CovidDeaths
group by date
order by 1 


--taking in COVIDVACCINATION TABLE also

--joining the two tables
select * 
from PortfolioProject.. CovidDeaths cd
join PortfolioProject.. CovidVaccination cv
on cd.location=cv.location and cd.date=cv.date

--getting totalvaccinated at each location each day

with cte as(
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations, Sum(convert(bigint,cv.new_vaccinations)) over (PARTITION by cd.location order by cd.location, cd.date )  totalvaccinated
from PortfolioProject.. CovidDeaths cd
join PortfolioProject.. CovidVaccination cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null --and cd.location='Albania'
--group by cd.location, cd.population
--order by 2,3
)


select *,totalvaccinated/population*100 percentagevaccinated from cte


--creating view for later visualisation

create view totalsview as
select date, SUM(total_cases) as Totalcases,SUM(cast(total_deaths as int)) as Totaldeaths, Round(SUM(cast(total_deaths as int))/SUM(total_cases)*100, 3) as deathpercentage
from PortfolioProject.. CovidDeaths
group by date
--order by 1