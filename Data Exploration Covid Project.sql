
Select *
From PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4
--Select the data that we are going to work with
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--this shows the likelyhood of dying if you tract covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Malaysia%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

SELECT Location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%Malaysia%'
order by 1,2

--Looking at countries with the highest infection rate compared to the population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Malaysia%'
group by location, population
order by PopulationPercentageInfected desc

--Showing Countries with the highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Malaysia%'
where continent is not NULL
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Malaysia%'
where continent is not NULL
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
				SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Malaysia%'
where continent is not Null
--group by date
order by 1,2

--Looking at Total Population vs Vaccination
-- new vac convert to bigint instead opf int because sum values exceed limit
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated

FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE to perform further calculations

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, CummulativePeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)

Select *, (CummulativePeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated

FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select *, (CummulativePeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated

FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

select *
from PercentPopulationVaccinated
