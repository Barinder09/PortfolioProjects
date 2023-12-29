/*
Created By: Barinder Singh
Date: 25/12/2023
Description: Covid Data Analysis
Raw DataSet Link: https://ourworldindata.org/covid-deaths
*/

/*SELECT * FROM PortfolioProject.DBO.CovidDeaths
WHERE continent is not null
ORDER BY 3,4
*/

SELECT LOCATION,
		date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Deaths Vs Total Cases
SELECT LOCATION,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Total Cases Vs Population
SELECT location,date,total_cases,population,(total_cases/population) AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Countries with Highest InfectionRate
SELECT location,
		population,
		MAX(total_cases) AS HighestInfectionCount,
		MAX((total_cases/population))*100 AS InfectionPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY InfectionPercentage desc

--Countries with highest DeathCount Per Population
SELECT location,
		population,
		MAX(total_deaths) AS TotalDeathCount,
		MAX((total_deaths/population))*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY DeathPercentage desc

--Continents with highest DeathCount Per Population
SELECT location,
		MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE location not like '%income%' AND location not like '%Union%' AND continent is null
GROUP BY location 
ORDER BY TotalDeathCount desc

--Continents with highest DeathRate Per Population
SELECT location,
		MAX(total_deaths) AS TotalDeathCount,
		MAX(total_deaths/population)*100 AS TotalDeathRate
FROM PortfolioProject.dbo.CovidDeaths
WHERE location not like '%income%' AND location not like '%Union%' AND continent is null
GROUP BY location 
ORDER BY TotalDeathCount desc

-- Global Count
SELECT
    --date,
    SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths,
    CASE WHEN SUM(new_cases) <> 0 --To Handle Divide by zero error
         THEN SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100
         ELSE NULL END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null

--CovidVaccinations Data Exploration
--Total Population Vs Total Vaccination
SELECT dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent,
    dea.location,
    dea.date,
    dea.population,
	vac.new_vaccinations
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent,
    dea.location,
    dea.date,
    dea.population,
	vac.new_vaccinations
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PopulationPercentage
--(roll/Population)*100 AS Vaccinated PopulationPercentage
From PopvsVac


--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
locatin nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent,
    dea.location,
    dea.date,
    dea.population,
	vac.new_vaccinations
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PopulationPercentage
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent,
    dea.location,
    dea.date,
    dea.population,
	vac.new_vaccinations
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated