--Select *
--From PortfolioProject..CovidDeaths
--Order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3, 4

--Select all Locations, total and new cases, total deaths and population
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

--Looking at total cases vs total deaths
--Shows likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date

--Looking at total cases vs Population
--Shows what percentage of population got Covid 
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS CasesVSPopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%canada'
ORDER BY location, date

--Looking at countries with highest infection rate comparet to population
SELECT location, population, MAX(total_cases) AS TotalCases,  MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with highest death count per population
SELECT location, MAX(total_deaths) AS TotalDeathsCounted
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCounted DESC

--Breaking down by greatest parts
SELECT location, MAX(total_deaths) AS TotalDeathsCounted
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathsCounted DESC

--Showing continents with highest death count per population
SELECT continent, MAX(total_deaths) AS TotalDeathsCounted
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCounted DESC

--Global numbers
SELECT MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, MAX(total_deaths)/MAX(total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1, 2

--Looking at Total Population vs Vacconations
SELECT deaths.continent, deaths.location, deaths.date, population, new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS totalVaccinationsToDate
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
 ON deaths.location = vacc.location
 AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
AND vacc.new_vaccinations IS NOT NULL
--AND deaths.location = 'Canada'
ORDER BY 2, 3

-- USE CTE
-- calculate the percentage of people vaccinated to date
WITH PopulationVSVaccinations (continent, location, date, population, new_vaccinations, totalVaccinationsToDate)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, population, new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS totalVaccinationsToDate
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
 ON deaths.location = vacc.location
 AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
AND vacc.new_vaccinations IS NOT NULL
--AND deaths.location = 'Canada'
--ORDER BY 2, 3
)
SELECT *, (totalVaccinationsToDate/population)*100 AS VaccinationsPercentage
FROM PopulationVSVaccinations

-- USE Temp Table
-- calculate the percentage of people vaccinated to date
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
totalVaccinationsToDate float
)
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, population, new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS totalVaccinationsToDate
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
 ON deaths.location = vacc.location
 AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
AND vacc.new_vaccinations IS NOT NULL
--AND deaths.location = 'Canada'
--ORDER BY 2, 3

SELECT *, (totalVaccinationsToDate/population)*100 AS VaccinationsPercentage
FROM #PercentPopulationVaccinated

-----------------------------------------------------------------
--CREATING VIEW to store data for later visualizations
-----------------------------------------------------------------
/*
USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, population, new_vaccinations
, SUM(CONVERT(float, vacc.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS totalVaccinationsToDate
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vacc
 ON deaths.location = vacc.location
 AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
AND vacc.new_vaccinations IS NOT NULL
--AND deaths.location = 'Canada'
--ORDER BY 2, 3
*/

SELECT *
FROM PercentPopulationVaccinated