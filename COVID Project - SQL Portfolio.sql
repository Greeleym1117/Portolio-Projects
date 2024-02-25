select * from dbo.CovidVaccine
order by 3,4

select * from dbo.CovidDeaths
order by 3,4

--select data we are using

Select Location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths 
--shows likelihood of dying is you contract covid in your country 

Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases VS Population 
-- what percentage of population got covid

Select Location, date, total_cases, population, 
(total_cases/population)*100 as PercentInfected
from dbo.CovidDeaths
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population


Select Location, population, MAX(total_cases) as HighestInfectionCount,
MAX(total_cases/population)*100 as PercentInfected
from dbo.CovidDeaths
--where location like '%states%'
Group by Location, Population 
order by 1,2

--showing countries with highest death count per population
-- put WHERE CONTINENT IS NOT NULL in order to filter continents numbers out from there
-- use CAST AS INT because there's a problem with varchar


--by country
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount from dbo.CovidDeaths
where continent is not null 
group by Location
Order by TotalDeathCount Desc

--by continent
--Show Continents with Highest Death Count 
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount from dbo.CovidDeaths
where continent is null 
group by Location
Order by TotalDeathCount Desc

-- GLOBAL NUMBERS (total diagnosed, total died, percent diagnosed that died)

Select SUM(new_cases)  as total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercent
from dbo.CovidDeaths
where continent is not null
order by 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations  
from dbo.CovidDeaths dea
join dbo.CovidVaccine vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccine vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccine vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccine vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
order by Location


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccine vac 
	on dea.location = vac.location 
	and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3

Select * from #PercentPopulationVaccinated

