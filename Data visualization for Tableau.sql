--Looking at the total cases, total deaths, and its percentage by the continent
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM ProjectOne..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at total death by its location where the continent isn't 'World', 'European Union' or 'International'
SELECT location, SUM(CAST(new_deaths AS INT)) as TotalDeathCount
FROM ProjectOne..CovidDeaths
WHERE continent IS NULL AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM projectOne..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Looking at countries with highest infection rate compared to population and detailed by date
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM projectOne..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC















-- loking at total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from ProjectOne..CovidDeaths
--where location like '%states%'
order by 1,2

--loking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected 
from projectOne..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--showing the countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from projectOne..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--showing the countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from projectOne..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--showing the continent with the highest death count per polution
--global number
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectOne..CovidDeaths
where continent is not null
group by date
order by 1,2

--show total vaccination by location

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from projectOne..CovidDeaths d
join ProjectOne..CovidVaccinations v
	on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- use cte
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
	select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(cast(v.new_vaccinations as int)) 
			over (partition by d.location order by d.location, d.date) 
			as RollingPeopleVaccinated
	from projectOne..CovidDeaths d
	join ProjectOne..CovidVaccinations v
		on d.location = v.location 
		and d.date = v.date
	where d.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
--order by 1,2

--temp table
create table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(cast(v.new_vaccinations as int)) 
			over (partition by d.location order by d.location, d.date) 
			as RollingPeopleVaccinated
	from projectOne..CovidDeaths d
	join ProjectOne..CovidVaccinations v
		on d.location = v.location 
		and d.date = v.date
	where d.continent is not null

select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--create view to store data for later visualizations
create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(cast(v.new_vaccinations as int)) 
			over (partition by d.location order by d.location, d.date) 
			as RollingPeopleVaccinated
	from projectOne..CovidDeaths d
	join ProjectOne..CovidVaccinations v
		on d.location = v.location 
		and d.date = v.date
	where d.continent is not null

select * from PercentPopulationVaccinated
