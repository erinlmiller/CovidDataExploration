--View CovidDeaths full table
SELECT *
FROM CovidProject..CovidDeaths
ORDER BY 3,4;

--View CovidVaccinations full table
SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4;

--View CovdDeaths data we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
ORDER BY 1,2;

--Total Cases vs. Total Deaths in United States
--Likelihood of dying from Covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2;

--Total Cases vs. Population
--Percentage of population that contracted Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 as PercentPopInfected
FROM CovidProject..CovidDeaths
WHERE location LIKE 'United States'
ORDER BY 1,2;

--Countries with highest infection rates
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopInfected
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopInfected DESC;

--Countries with highest death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Death count by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Death count by continent (INCORRECT!)
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as GlobalDeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Total population vs. vaccinations

--Using CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as VaccinationPercent
FROM PopVsVac;

--Using a temp table
DROP TABLE IF EXISTS #PercentPopVaccinated;
CREATE TABLE #PercentPopVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric);

INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT *, (RollingPeopleVaccinated/population) * 100 as VaccinationPercent
FROM #PercentPopVaccinated;

--Creating views for later visualization

CREATE VIEW PercentPopVaccinated2 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopVaccinated2;
