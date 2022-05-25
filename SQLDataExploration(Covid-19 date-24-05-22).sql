/*
Covid-19 Data Exploration

skills used : joins, CTE's, Temp Tables, Windows Functions, aggregate Function, Creating views, Converting data trypes
*/


select *
from project..CovidDeaths
where continent is not null
order by 3,4

--select *
--from project..vacination
--order by 3,4

--Selecting Data 
select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths
where continent is not null
order by 1,2

--looking at total case vs total deaths
--shows likelihood of dying of covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project..CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

--Looking At Total cases Vs Population in India
--shows % of population got covid in India
select location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
from project..CovidDeaths
where location like '%india%'
order by 1,2

--looking at Countries with Highest Infection rate compared to Population
select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as PercentofPopulationInfected
from project..CovidDeaths
group by location, population
order by PercentofPopulationInfected desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from project..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc


--showing continent with the highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from project..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--Global Numbers
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from project..CovidDeaths
where continent is not null
order by 1,2

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from project..CovidDeaths dea
join project..vacination  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using common table expression
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from project..CovidDeaths dea
join project..vacination  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from project..CovidDeaths dea
join project..vacination  vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select*, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store data for later visualization
create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from project..CovidDeaths dea
join project..vacination  vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select*
from percentpopulationvaccinated