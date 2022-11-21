select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at the total cases vs total deaths 
-- shows likelyhood of dying if you contact covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentagedeath
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- looking at the total cases vs the population
-- shows what percentage of population got infected
select Location, date, population, total_cases, (total_cases/population)*100 as populationinfected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select Location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as populationinfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by Location, population
order by populationinfected desc

-- showing countries with highest death count per population

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by Location
order by TotalDeathCount desc

-- lets break thing down by continent 
-- showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
-- global death percentage 
select date, sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentageDeathGlobal
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- global death count
select sum(new_cases) as NewCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as PercentageDeathGlobal
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--loooking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
	
-- population of vaccinated people using CTE
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PopvsVac

-- population of vaccinated people using Temp table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from #PercentagePopulationVaccinated

-- creating view to store data later visualization

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
from PercentagePopulationVaccinated
