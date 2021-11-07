SELECT * FROM ProjectOne..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectOne..CovidDeaths
ORDER BY 1,2

--Looking at the total cases, total deaths, and its percentage
--shows likelihood of dying in country which has states word in the name
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectOne..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at the total cases, total deaths, and its percentage
--shows likelihood of dying in every country
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectOne..CovidDeaths
ORDER BY 1,2

--Loking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM projectOne..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM projectOne..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM projectOne..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the continent with the highest death count per population per date
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM ProjectOne..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Show total vaccination by location
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM projectOne..CovidDeaths d
JOIN ProjectOne..CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3

--Use common table expression
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CAST(v.new_vaccinations AS INT)) 
			OVER (partition by d.location order by d.location, d.date) 
			AS RollingPeopleVaccinated
	FROM projectOne..CovidDeaths d
	JOIN ProjectOne..CovidVaccinations v
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--create temp table
CREATE TABLE #PercentPopulationVaccinated (
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

--insert data into temp table
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CAST(v.new_vaccinations as int)) 
			OVER (partition by d.location order by d.location, d.date) 
			AS RollingPeopleVaccinated
	FROM projectOne..CovidDeaths d
	JOIN ProjectOne..CovidVaccinations v
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Create view to store data for later visualizations
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(cast(v.new_vaccinations as int)) 
			OVER (partition by d.location order by d.location, d.date) 
			AS RollingPeopleVaccinated
	FROM projectOne..CovidDeaths d
	JOIN ProjectOne..CovidVaccinations v
		on d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL
GO
-- test the view
SELECT * FROM PercentPopulationVaccinated
