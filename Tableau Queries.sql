/*
Queries used for Tableau Project
*/
-- checking  column "location" 's context
-- SELECT * FROM coviddeaths
-- WHERE continent =''
-- GROUP BY location;

-- Table 1. 
-- (Taking out Africa, Asia, Europe, European Union, International,North America,South America,Oceania,World) We have World results in this way
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS DeathPercentage FROM coviddeaths
WHERE continent <>''
-- GROUP BY date
ORDER BY 1,2;


-- Just a double check based off the data provided, for the world results by using location = 'World'
-- (Numbers are extremely close so we will keep them)
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS DeathPercentage FROM coviddeaths
WHERE location = 'World'
-- GROUP BY date
ORDER BY 1,2;


-- Table 2. 
-- The 5 continents ( Antarctic is not included in the dataset) (European Union is part of Europe)
SELECT location, SUM(new_deaths) AS TotalDeathCount FROM coviddeaths
WHERE continent =''
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Table 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  (MAX(total_cases/population))*100 AS PercentPopulationInfected FROM coviddeaths
-- WHERE location="Greece"
GROUP BY location
ORDER BY PercentPopulationInfected DESC;


-- Table 4.

SELECT location, population, date, total_cases AS HighestInfectionCount, new_cases, (total_cases/population)*100 AS PercentPopulationInfected FROM coviddeaths
-- WHERE location="Greece"
-- GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC, date;



