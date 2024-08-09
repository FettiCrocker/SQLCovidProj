
Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Select * 
--From PortfolioProject..CovidVacs
--order by 3,4

-- Select Data we will be using


--cases vs total deaths, shows liklihood of dying if you contract covid in your country

Select Location, date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs. population
-- Shows what percentage of population got covid

Select Location, date, total_cases,population, new_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Highest infection rate compared to population

Select Location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
group by location, population
order by InfectionPercentage desc


-- Showing countries with highest death count per population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
group by location
order by TotalDeathCount desc

-- Break things down by Continent



-- showing continents with highest death count

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as new_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--group by date
order by 1,2


Select dea.continent, dea.location,dea.date,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVacs vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

-- use CTE

With PopvsVac (Continent,location,date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVacs vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated/population)*100
from PopvsVac

--- Temp Table
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVacs vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea	
Join PortfolioProject..CovidVacs vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated