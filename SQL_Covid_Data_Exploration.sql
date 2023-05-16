SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths'



--Total cases vs total deaths

ALTER TABLE PortfolioProject..CovidDeaths
ADD total_cases_numeric NUMERIC(10,0),
	total_deaths_numeric NUMERIC (10,0)

UPDATE PortfolioProject..CovidDeaths
SET total_cases_numeric = CAST(total_cases AS NUMERIC(10,0))

UPDATE PortfolioProject..CovidDeaths
SET total_deaths_numeric = CAST(total_deaths AS NUMERIC(10,0))



SELECT location, date, total_cases, total_deaths, (total_deaths_numeric/total_cases_numeric)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
AND continent IS NOT NULL
ORDER BY 1,2



--Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases_numeric/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Canada'
ORDER BY 1,2



--Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases_numeric) AS HighestInfectionCount, Max((total_cases_numeric/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



--Countries with Highest Covid Death Count per Population

SELECT location, population, MAX(total_deaths_numeric) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC



--Showing continents with highest death count per population

SELECT continent, MAX(total_deaths_numeric) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global numbers

ALTER TABLE PortfolioProject..CovidDeaths
ADD new_cases_numeric NUMERIC(10,0),
	new_deaths_numeric NUMERIC (10,0)

UPDATE PortfolioProject..CovidDeaths
SET new_cases_numeric = CAST(new_cases AS NUMERIC(10,0))

UPDATE PortfolioProject..CovidDeaths
SET new_deaths_numeric = CAST(new_deaths AS NUMERIC(10,0))

UPDATE PortfolioProject..CovidDeaths
SET new_deaths_numeric = null WHERE new_deaths_numeric = 0

SELECT date, SUM(new_cases_numeric) AS total_Cases, SUM(new_deaths_numeric) AS total_Deaths, (SUM(new_deaths_numeric)/SUM(new_cases_numeric)*100) AS GlobalDeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



--Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PopVacPercentage 
FROM PopvsVac



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PopVacPercentage 
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated