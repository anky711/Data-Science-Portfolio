use portfoliodb;
select * from coviddeaths
where continent <> ''
order by 3,4;

-- select * from covidvaccinations
-- order by 3,4;

select 
location , date , total_cases, new_cases, total_deaths , population 
from coviddeaths
where continent <> ''
order by 1,2;

-- Looking at the total_cases vs total_deaths
-- Shows likelihood of dying if you contract covid in US
select 
Location , date , total_cases, total_deaths , 
round((total_deaths/total_cases)*100,2) as "Death Percentage"
from coviddeaths
where location like "India" and  continent <> ''
order by 1,2;

-- Total cases vs Population
-- Shows what % of population got covid
select 
Location , date , Population ,total_cases,  
round((total_cases/population)*100,2) as "% of population infected"
from coviddeaths
where location like "India" and  continent <> ''
order by 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT 
    Location, 
    Population, 
    MAX(total_cases) as "Most infected country",  
    MAX(ROUND((total_cases/population)*100, 2)) as "% of population infected"
FROM coviddeaths
WHERE continent <> ''
-- WHERE location LIKE "India"   -- Uncomment if you want to filter by location
GROUP BY Location, Population
ORDER BY MAX(ROUND((total_cases/population)*100, 2)) DESC;


-- Showing the countries with highest death count
select 
Location , MAX(CAST(total_deaths AS SIGNED)) as totaldeaths
from coviddeaths
-- Where location  like "India"
where continent is not null
group by location
order by totaldeaths  desc ;

-- BREAKING UP BY CONTINENTS

select 
continent , MAX(CAST(total_deaths AS SIGNED)) as TotalDeathsCount
from coviddeaths
-- Where location  like "India"
where continent <> ''
group by continent
order by TotalDeathsCount desc ;

-- Showing contintents with highest death count per population
select 
location , MAX(CAST(total_deaths AS SIGNED)) as TotalDeathsCount
from coviddeaths
-- Where location  like "India"
where continent = ''
group by Location
order by TotalDeathsCount desc ;


-- Global Numbers
SELECT 
   --  date,
    SUM(cast(new_cases as signed)) AS total_cases, 
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
   SUM(CAST(new_deaths AS SIGNED))/SUM(cast(new_cases as signed)) *100 AS Death_Percentage
FROM

    coviddeaths
WHERE
    continent IS NOT NULL
-- GROUP BY 
   --  date
ORDER BY 
   1,2;
   
   -- Looking at Total Population vs Vaccinations


WITH PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.population,
        DATE_FORMAT(dea.date, '%d-%m-%Y') AS date,
        CAST(vac.new_vaccinations AS SIGNED) AS new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, DATE_FORMAT(dea.date, '%d-%m-%Y')) AS rollingpeoplevaccinated
    FROM
        coviddeaths dea
    JOIN
        covidvaccinations vac ON DATE_FORMAT(dea.date, '%d-%m-%Y') = vac.date AND dea.location = vac.location
    WHERE
        dea.continent <> ''
    ORDER BY
        dea.location, date
)
SELECT *, (rollingpeoplevaccinated/population)*100 FROM PopvsVac;

-- Temp Table
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
-- Create temporary table
-- CREATE TEMPORARY TABLE PercentPopulationVaccinated (
--     Continent nvarchar(255),
--     Location nvarchar(255),
--     Date DATE,
--     Population nvarchar(255),
--     rollingpeoplevaccinated nvarchar(255),
--     new_vaccinated nvarchar(255)
-- );

-- -- Insert data into temporary table
-- -- Example of chunk processing
-- -- Adjust the chunk size based on your dataset and server capacity
-- SET SESSION max_execution_time = 1000;

-- INSERT INTO PercentPopulationVaccinated
-- SELECT
--         dea.continent,
--         dea.location,
--         dea.population,
--         DATE_FORMAT(dea.date, '%d-%m-%Y') AS date,
--         CAST(vac.new_vaccinations AS SIGNED) AS new_vaccinations,
--         SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, DATE_FORMAT(dea.date, '%d-%m-%Y')) AS rollingpeoplevaccinated
--     FROM
--         coviddeaths dea
--     JOIN
--         covidvaccinations vac ON DATE_FORMAT(dea.date, '%d-%m-%Y') = vac.date AND dea.location = vac.location
--     WHERE
--         dea.continent <> ''
CREATE VIEW  PERCENTPOPULATIONVACCINATED AS 
SELECT
        dea.continent,
        dea.location,
        dea.population,
        DATE_FORMAT(dea.date, '%d-%m-%Y') AS date,
        CAST(vac.new_vaccinations AS SIGNED) AS new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, DATE_FORMAT(dea.date, '%d-%m-%Y')) AS rollingpeoplevaccinated
    FROM
        coviddeaths dea
    JOIN
        covidvaccinations vac ON DATE_FORMAT(dea.date, '%d-%m-%Y') = vac.date AND dea.location = vac.location
    WHERE
        dea.continent <> ''

