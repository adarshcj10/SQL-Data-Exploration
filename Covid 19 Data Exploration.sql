--1 Load the query
SELECT *
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
ORDER BY 3,4;

SELECT *
FROM `lunar-caster-321515.Covid_19.Covid_Vaccinations`
WHERE continent is not null 
ORDER BY 3,4;

--2. Likelihood of People dying from Covid in India 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE location like '%India%'
ORDER BY 1,2;

--3. Looking at Total cases v/s Population(Shows what % of population got Covid)

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
ORDER BY 1,2;

--4. Looking at Countries with highest infection rate compared to its population.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

--5. Showing countries with Highest Death Count as of its Population

SELECT location, MAX(CAST(total_deaths as int64)) as TotalDeathCount
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT location, MAX(CAST(total_deaths as int64)) as TotalDeathCount
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount DESC;

--7. Showing continets with the highest death counts.

SELECT continent, MAX(CAST(total_deaths as int64)) as TotalDeathCount
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--8. Global count

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int64)) AS total_deaths, SUM(CAST(new_deaths as int64))/SUM(new_cases)*100 AS DeathPercentage
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int64)) AS total_deaths, SUM(CAST(new_deaths as int64))/SUM(new_cases)*100 AS DeathPercentage
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`
WHERE continent is not null 
ORDER BY 1,2;

--9. Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM `lunar-caster-321515.Covid_19.Covid_Deaths` dea
JOIN `lunar-caster-321515.Covid_19.Covid_Vaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3;

--Partitiong by location 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as int64)) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `lunar-caster-321515.Covid_19.Covid_Deaths` dea
JOIN `lunar-caster-321515.Covid_19.Covid_Vaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--10. Using a CTE(common expression table)

WITH PopVsVac as 
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as int64)) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `lunar-caster-321515.Covid_19.Covid_Deaths` dea
JOIN `lunar-caster-321515.Covid_19.Covid_Vaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac;

--11. Creating tables

Create Table `lunar-caster-321515.Covid_19.` .PercentPopulationVaccinated
(
Continent  STRING,
Location  STRING,
Date datetime,
Population   NUMERIC,
New_vaccinations   NUMERIC,
RollingPeopleVaccinated   NUMERIC
);

--Inserting values into PercentPopulationVaccinated

INSERT INTO `lunar-caster-321515.Covid_19.PercentPopulationVaccinated`
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(new_vaccinations as int64)) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `lunar-caster-321515.Covid_19.Covid_Deaths` dea
JOIN `lunar-caster-321515.Covid_19.Covid_Vaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM `lunar-caster-321515.Covid_19.PercentPopulationVaccinated`;

--12. Creating VIEW to store data for visualisations.

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM `lunar-caster-321515.Covid_19.Covid_Deaths`;

Select location, SUM(cast(new_deaths as int64)) as TotalDeathCount
From `lunar-caster-321515.Covid_19.Covid_Deaths`
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `lunar-caster-321515.Covid_19.Covid_Deaths`
Group by Location, Population
order by PercentPopulationInfected desc;

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From `lunar-caster-321515.Covid_19.Covid_Deaths`
Group by Location, Population, date
order by PercentPopulationInfected desc
