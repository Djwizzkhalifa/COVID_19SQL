select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Selecting Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Seeing Total cases vs Total deaths
--Death Rate of covid affected patients


Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%india%'
order by 1,2

--Checking the total cases vs the populaion
--Infected Percentage



Select Location, date, population, total_cases , (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths$
Where location like '%india%'
order by 1,2


--Seeing the coutries with highest infection rate compared to the population


Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100
as PercentInfected
from PortfolioProject..CovidDeaths$
--Where location like '%india%'
Group by location,population
order by PercentInfected desc

--Checking countries with highest death count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Showing continents with highest death count

Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc

--Global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 
from PortfolioProject..CovidDeaths$
--Where location like '%india%'
where continent is not null
--group by date
order by 1,2
-------------------
select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date

--Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by
dea.location,dea.date) as rolling_Vac_count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
where dea.continent is not null
and dea.date=vac.date
order by 2,3

--Using CTE

With PopvsVacs (Continent, location,date,population,new_vaccinations,rolling_Vac_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by
dea.location,dea.date) as rolling_Vac_count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
)

select *, (rolling_Vac_count/population)*100
from PopvsVacs

--Using Temp table
drop table if exists #PercentagePopVaccinated

Create table #PercentagePopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by
dea.location,dea.date) as rolling_Vac_count
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
--where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopVaccinated

--Creating a view to store data for tableau visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, new_vaccinations)) over (partition by dea.location order by
dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated