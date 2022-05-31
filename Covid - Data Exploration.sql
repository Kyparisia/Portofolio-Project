/* 
Covid-19 Data Exploration

Skills used: Joins, CTE, Window Functions, Aggregate Functions, Creating Views

*/

-- 1. Cleaning data
DELETE FROM coviddeaths
WHERE location='Upper middle income' OR location='High income' OR location='Lower middle income' OR location='Low income';

-- 2. Taking out Africa, Asia, Europe, European Union, International,North America,South America,Oceania,World) We have World results in this way
SELECT * FROM coviddeaths
WHERE continent <>'';


-- 3. Total Cases vs Total Deaths per day
-- Likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage FROM coviddeaths
WHERE continent <>''
-- WHERE location="Greece"
ORDER BY location, date;

-- 4. Total Cases vs Population per day
-- The percentage of population infected with covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage FROM coviddeaths
WHERE continent <>''
-- WHERE location="Greece"
ORDER BY location, date;


-- 5. Countries(Location) with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected FROM coviddeaths
WHERE continent <>''
GROUP BY location
ORDER BY PercentPopulationInfected DESC;

-- 6. Countries(Location) with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount FROM coviddeaths
WHERE continent <>''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- 7. Continents(continent) with Highest Death Count per Population
SELECT continent, MAX(total_deaths) as TotalDeathCount FROM coviddeaths
WHERE continent <>''
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- 8. GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage FROM coviddeaths
WHERE  continent <>'';
GROUP BY date
-- ORDER BY date;

-- 9. Showing the RollingPeopleVaccinated every day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated FROM coviddeaths dea
JOIN covidvaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE  dea.continent <>''
ORDER BY 2,3;


-- Showing the percent of people who have been vaccinated to this day
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated FROM coviddeaths dea
JOIN covidvaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE  dea.continent <>''
ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100 FROM PopVsVac;



-- Creating Views
CREATE VIEW PopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated FROM coviddeaths dea
JOIN covidvaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE  dea.continent <>''
ORDER BY 2,3;

SELECT * FROM populationvaccinated;

CREATE VIEW PercentPopulationVaccinated AS
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac ON dea.location=vac.location AND dea.date=vac.date
WHERE  dea.continent <>''
ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100 FROM PopVsVac;

SELECT * FROM Percentpopulationvaccinated;
