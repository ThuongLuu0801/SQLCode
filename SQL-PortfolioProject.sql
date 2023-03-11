CREATE DATABASE PortfolioProject 
USE PortfolioProject 
GO

SELECT * FROM CovidDeaths
WHERE total_cases = 'Column 5'

DELETE CovidDeaths
WHERE total_cases = 'Column 5'

--Change the datatype of some field of CovidDeaths Table
ALTER TABLE CovidVaccination ALTER COLUMN tests_units FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN total_tests_per_thousand FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_tests_per_thousand FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_tests_smoothed FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_tests_smoothed_per_thousand FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN positive_rate FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN tests_per_case FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN total_vaccinations FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN people_vaccinated FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN people_fully_vaccinated FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_vaccinations_smoothed FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN total_vaccinations_per_hundred FLOAT

SELECT handwashing_facilities FROM CovidVaccination
ALTER TABLE CovidVaccination ALTER COLUMN total_boosters FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_vaccinations FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN people_vaccinated_per_hundred FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN people_fully_vaccinated_per_hundred FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN total_boosters_per_hundred FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_vaccinations_smoothed_per_million FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_people_vaccinated_smoothed FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN new_people_vaccinated_smoothed_per_hundred FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN median_age FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN stringency_index FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN aged_65_older FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN aged_70_older FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN gdp_per_capita FLOAT

ALTER TABLE CovidVaccination ALTER COLUMN population FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN excess_mortality_cumulative_absolute FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN excess_mortality_cumulative FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN excess_mortality FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN excess_mortality_cumulative_per_million FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN human_development_index FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN life_expectancy FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN hospital_beds_per_thousand FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN handwashing_facilities FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN male_smokers FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN female_smokers FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN diabetes_prevalence FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN cardiovasc_death_rate FLOAT
ALTER TABLE CovidVaccination ALTER COLUMN extreme_poverty FLOAT

ALTER TABLE CovidVaccination ALTER COLUMN date DATE

ALTER TABLE CovidDeaths ALTER COLUMN date DATE

SELECT population_density FROM CovidDeaths

ALTER TABLE CovidDeaths ALTER COLUMN population_density FLOAT

-- Looking at total Death on total case

SELECT location,date,total_deaths,total_cases,
	(SELECT CASE
	WHEN total_cases = 0
	THEN NULL
	ELSE (total_deaths/total_cases)*100
	END AS 'Percent Deaths on Total Cases') DeathPercentage
FROM CovidDeaths
ORDER BY 1,2

-- Looking at total Death on population

SELECT location,date,total_deaths,population,
	(SELECT CASE
	WHEN population = 0
	THEN NULL
	ELSE (total_deaths/population)*100
	END AS 'Percent Deaths on Total Cases') DeathPercentageOnPop
FROM CovidDeaths
ORDER BY 1,2

SELECT TOP (2) * FROM CovidDeaths
SELECT TOP (2) * FROM CovidVaccination

ALTER TABLE population
ALTER COLUMN date DATE

ALTER TABLE population
ALTER COLUMN population FLOAT

INSERT INTO CovidDeaths
SELECT C.*,P.Population
FROM CovidDeaths C
INNER JOIN Population P
ON C.iso_code = P.iso_code
AND c.date = P.date

ALTER TABLE CovidDeaths
ADD Population FLOAT

INSERT INTO CovidDeaths(Population) 
SELECT population FROM Population
WHERE CovidDeaths.iso_code = Population.iso_code 
AND CovidDeaths.date = Population.date

-- Adding population column to Table CoviDeaths

UPDATE
    CovidDeaths
SET
    CovidDeaths.population = P.population
FROM Population P
	INNER JOIN CovidDeaths C
	ON C.iso_code = P.iso_code
	AND c.date = P.date

SELECT * FROM CovidDeaths

-- Looking at countries with Highest Infection Rate compared to population

WITH TemptTable AS
(SELECT Location, Population,total_Cases,
	CASE
	WHEN population = 0
	THEN NULL
	ELSE (total_Cases/population)*100
	END AS PercentCase
 FROM CovidDeaths)
 SELECT Location, Population,MAX(total_Cases) HighestInfectionCount,MAX(PercentCase) PercentPopulationInfected
 FROM TemptTable
 GROUP BY Location, Population
 ORDER BY PercentPopulationInfected DESC

 -- Showing the country with the highest Death cout per population

 SELECT Location, Population,MAX(total_deaths) TotalDeathCount
 FROM CovidDeaths
 WHERE continent is not null AND continent <>' '
 GROUP BY Location, Population
 ORDER BY TotalDeathCount DESC

 SELECT DISTINCT Location
 FROM CovidDeaths
 WHERE continent is null OR continent =' '

 -- LET'S BREAK DOWN BY CONTINENT
 SELECT continent,MAX(total_deaths) TotalDeathCount   ---MAX trong tất cả các năm
 FROM CovidDeaths
 WHERE continent is not null AND continent <>' '
 GROUP BY continent
 ORDER BY TotalDeathCount DESC

  -- LET'S BREAK DOWN BY CONTINENT
 SELECT location,Population,MAX(total_deaths) TotalDeathCount
 FROM CovidDeaths
 WHERE continent is null OR continent =' '
 GROUP BY location,Population
 ORDER BY TotalDeathCount DESC

--- Is total_case accumulate

-- Showing continent with highest death count per population

SELECT continent, MAX(total_deaths/population)*100 HighestDeathCount
FROM CovidDeaths
WHERE continent is not null AND continent <>' '
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS
SELECT date,total_cases,total_death,

WITH tempt AS
(
SELECT date,new_cases,New_deaths,
 CASE
 WHEN total_cases = 0 THEN NULL
 ELSE (total_Deaths/total_cases)*100
 END AS PercentDeath_OnCases
 FROM CovidDeaths
 WHERE continent is not null and continent <>' '
 )
SELECT Date,SUM(New_cases) AS Totalcases,SUM(New_deaths) AS TotalDeaths--PercentDeath_OnCases
FROM tempt
GROUP BY Date
ORDER BY TotalCases DESC


-- Join 2 table
SELECT C.continent,c.location,c.date,c.Population,V.new_vaccinations
FROM CovidDeaths C
INNER JOIN CovidVaccination V
ON C.location = V.location
AND C.date = V.date
WHERE C.continent is not null and C.continent <>' '
ORDER BY 2,3

-- Looking at total population vs total vaccinations 
WITH Tempt AS
	(
	SELECT C.continent,c.location,c.date,c.Population,V.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY C.location ORDER BY C.location,C.date) AS RunningTotalVaccin
	FROM CovidDeaths C
	INNER JOIN CovidVaccination V
	ON C.location = V.location
	AND C.date = V.date
	WHERE C.continent is not null and C.continent <>' '
	)
SELECT continent,location,date,Population,new_vaccinations,RunningTotalVaccin,(RunningTotalVaccin/Population)*100 PercentVaccinOnPopulation
FROM Tempt
ORDER BY PercentVaccinOnPopulation DESC

--Checking if running total vaccination  > Total Population

SELECT continent,location,RunningTotalVaccin,Population
FROM
    (SELECT C.continent,c.location,c.date,c.Population,V.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY C.location ORDER BY C.location,C.date) AS RunningTotalVaccin
	FROM CovidDeaths C
	INNER JOIN CovidVaccination V
	ON C.location = V.location
	AND C.date = V.date
	WHERE C.continent is not null and C.continent <>' ') sub1
WHERE RunningTotalVaccin>Population


-- Creating View to store date for later visualization 
-- a view is a virtual table based on the result-set of an SQL statement
-- A view contains rows and columns, just like a real table. The fields in a view are fields from one or more real tables in the database.
-- A view always shows up-to-date data

-- Why we need to create view ?
-- >> 1.  Access restriction to a table or anycoum in a table, instead user can only view it
-- >> 2. Showing the summary information from multiple tables

CREATE VIEW PercentVaccinated AS
	(SELECT C.continent,c.location,c.date,c.Population,V.new_vaccinations,
	SUM(new_vaccinations) OVER(PARTITION BY C.location ORDER BY C.location,C.date) AS RunningTotalVaccin
	FROM CovidDeaths C
	INNER JOIN CovidVaccination V
	ON C.location = V.location
	AND C.date = V.date
	WHERE C.continent is not null and C.continent <>' '
	)

SELECT * FROM PercentVaccinated

