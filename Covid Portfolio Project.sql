--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Selecting data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2

--Checking total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Percentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2

--Likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_Percentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2
 
 --Looking at total cases vs population
 --Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

----Showing countries with highest death count per population
SELECT Location, Max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Grouping by continent
SELECT continent, Max(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) AS DeathsPercentage
FROM portfolioproject.dbo.CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Looking at total population vs vaccination

select dea.location, dea.continent, dea.date, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (location, date,population, new_vaccinations, continent, RollingPeopleVaccinated)
AS
(
select dea.location,dea.population, dea.continent, dea.date, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar (255),
RollingPeopleVaccinated numeric,
Date datetime,
Population numeric,
New_Vaccinations numeric)

INSERT INTO #PercentPopulationVaccinated
select dea.location,dea.population, dea.continent, dea.date, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.location,dea.population, dea.continent, dea.date, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3