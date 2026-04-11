DROP TABLE CovidVaccination;

CREATE TABLE CovidVaccination (
	iso_code varchar(40),
	continent varchar(40),
	location varchar(40),
	record_date date,
	new_tests int,
	total_tests int,
	total_tests_per_thousand numeric,
	new_tests_per_thousand numeric,
	new_tests_smoothed numeric,
	new_tests_smoothed_per_thousand numeric,
	positive_rate numeric,
	tests_per_case numeric,
	tests_units varchar,
	total_vaccinations numeric,
	people_vaccinated int,
	people_fully_vaccinated int,
	new_vaccinations int,
	new_vaccinations_smoothed int,
	total_vaccinations_per_hundred numeric,
	people_vaccinated_per_hundred numeric,
	people_fully_vaccinated_per_hundred numeric,
	new_vaccinations_smoothed_per_million numeric,
	stringency_index numeric,
	population_density numeric,
	median_age numeric,
	aged_65_older numeric,
	aged_70_older numeric,
	gdp_per_capita numeric,
	extreme_poverty numeric,
	cardiovasc_death_rate numeric,
	diabetes_prevalence numeric,
	female_smokers numeric, 
	male_smokers numeric,
	handwashing_facilities numeric,
	hospital_beds_per_thousand numeric,
	life_expectancy numeric,
	human_development_index numeric
);

DROP TABLE covid_deaths;

CREATE TABLE covid_deaths (
    iso_code VARCHAR(40),
    continent VARCHAR(50),
    location VARCHAR(100),
    record_date DATE,
    population BIGINT,
    total_cases INT,
    new_cases INT,
    new_cases_smoothed NUMERIC,
    total_deaths BIGINT,
    new_deaths BIGINT,
    new_deaths_smoothed NUMERIC,
    total_cases_per_million NUMERIC,
    new_cases_per_million NUMERIC,
    new_cases_smoothed_per_million NUMERIC,
    total_deaths_per_million NUMERIC,
    new_deaths_per_million NUMERIC,
    new_deaths_smoothed_per_million NUMERIC,
    reproduction_rate NUMERIC,
    icu_patients NUMERIC,
    icu_patients_per_million NUMERIC,
    hosp_patients NUMERIC,
    hosp_patients_per_million NUMERIC,
    weekly_icu_admissions NUMERIC,
    weekly_icu_admissions_per_million NUMERIC,
    weekly_hosp_admissions NUMERIC,
    weekly_hosp_admissions_per_million NUMERIC
);


SELECT *
FROM covid_deaths;


SELECT *
FROM covidvaccination;

SELECT location, record_date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY location, record_date;

-- Looking at the death rate percentage
-- Shows the likelihood of death when contacted with Covid in Nigeria
SELECT location,
	record_date,
	total_cases,
	total_deaths,
	(total_deaths * 100.0 /total_cases) :: FLOAT4 AS death_rate
FROM covid_deaths
WHERE location = 'Nigeria'
ORDER BY location, record_date;

-- Looking total case vs population
-- shows percentage of population that contracted Covid
SELECT location,
	record_date,
	population,
	total_cases,
	(total_cases * 100.0 /population) :: FLOAT4 AS population_contract_percent
FROM covid_deaths
--WHERE location = 'Nigeria'
ORDER BY location, record_date;

-- Countries with the highest infected rate
SELECT location, population, record_date, MAX(total_cases) AS Highest_infected_Countries, MAX(total_cases * 100.0 /population) :: FLOAT4 AS percent_population_infected
FROM covid_deaths
WHERE location NOT IN ('World', 'European Union', 'International', 'Europe', 'Africa', 'Oceania', 'Asia', 'North America', 'South America')
GROUP BY location, population, record_date
ORDER BY percent_population_infected DESC, highest_infected_countries DESC;

--Continent covered
SELECT DISTINCT continent
FROM covid_deaths;

--Showing countries with highest death count
SELECT location, MAX(total_deaths) AS Total_deaths_count
FROM covid_deaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY Total_deaths_count DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing countries with the highest death count
SELECT location, MAX(total_deaths) AS Total_deaths_count
FROM covid_deaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY Total_deaths_count DESC;

--Showing continent with the highest death count
SELECT continent, MAX(total_deaths) AS Total_deaths_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_deaths_count DESC;

--Showing continent only with the highest death count
SELECT location, MAX(total_deaths) AS Total_deaths_count
FROM covid_deaths
WHERE total_deaths IS NOT NULL AND continent IS NULL
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY Total_deaths_count DESC;

--STATS GLOBALLY
--The global statistics of new case and death by date
SELECT record_date, 
	SUM(new_cases) AS total_new_cases,
	SUM(new_deaths) AS total_new_death, 
	SUM(new_deaths * 100.0)/SUM(new_cases) :: FLOAT4 AS Death_rate_percent
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY record_date
ORDER BY 2;

-- The global statistics summed for all new cases and death as at the last date of the dataset records.
SELECT --record_date, 
	SUM(new_cases) AS total_new_cases,
	SUM(new_deaths) AS total_new_death, 
	SUM(new_deaths * 100.0)/SUM(new_cases) :: FLOAT4 AS Death_rate_percent
FROM covid_deaths
WHERE continent IS NOT NULL
--GROUP BY record_date
ORDER BY 1;

--Comparison of vaccination to the population of each country
SELECT Infected.continent,
	Infected.location,
	Infected.record_date,
	population,
	Vaccine.new_vaccinations,
	SUM(Vaccine.new_vaccinations) OVER(
		PARTITION BY Infected.location
		ORDER BY Infected.location, Infected.record_date) AS Rolling_Total_Vaccinated
FROM covid_deaths AS Infected
JOIN covidvaccination AS Vaccine
	ON Infected.location =Vaccine.location
	AND Infected.record_date = Vaccine.record_date
WHERE Infected.continent IS NOT NULL
	AND Vaccine.new_vaccinations IS NOT NULL
ORDER BY Infected.location, Infected.record_date;

-- Using CTE to obtain percentage of population that are vaccinated.
WITH RollingPeopleVaccinated AS (
	SELECT Infected.continent,
	Infected.location,
	Infected.record_date,
	population,
	Vaccine.new_vaccinations,
	SUM(Vaccine.new_vaccinations) OVER(
		PARTITION BY Infected.location
		ORDER BY Infected.location, Infected.record_date) AS Rolling_Total_Vaccinated
FROM covid_deaths AS Infected
JOIN covidvaccination AS Vaccine
	ON Infected.location =Vaccine.location
	AND Infected.record_date = Vaccine.record_date
WHERE Infected.continent IS NOT NULL
	AND Vaccine.new_vaccinations IS NOT NULL
ORDER BY Infected.location, Infected.record_date
)
SELECT *, (Rolling_Total_Vaccinated * 100.0/population) :: FLOAT4 AS PercentPopulationVaccinated
FROM RollingPeopleVaccinated;

-- TEMPORARY TABLE
DROP TABLE IF EXISTS PopulationVaccinatedPercent;

CREATE TEMP TABLE PopulationVaccinatedPercent (
	continent VARCHAR(50),
	location VARCHAR(50),
	record_date DATE,
	population BIGINT,
	new_vaccination BIGINT,
	Rolling_Total_Vaccinated BIGINT,
	PercentPopulationVaccinated NUMERIC
);

INSERT INTO PopulationVaccinatedPercent (
	WITH RollingPeopleVaccinated AS (
	SELECT Infected.continent,
	Infected.location,
	Infected.record_date,
	population,
	Vaccine.new_vaccinations,
	SUM(Vaccine.new_vaccinations) OVER(
		PARTITION BY Infected.location
		ORDER BY Infected.location, Infected.record_date) AS Rolling_Total_Vaccinated
FROM covid_deaths AS Infected
JOIN covidvaccination AS Vaccine
	ON Infected.location =Vaccine.location
	AND Infected.record_date = Vaccine.record_date
WHERE Infected.continent IS NOT NULL
	AND Vaccine.new_vaccinations IS NOT NULL
ORDER BY Infected.location, Infected.record_date
)
SELECT *, (Rolling_Total_Vaccinated * 100.0/population) :: FLOAT4 AS PercentPopulationVaccinated
FROM RollingPeopleVaccinated
);

SELECT * FROM PopulationVaccinatedPercent;


-- CREATE MATERIALIZED VIEW TO STORE ON DISK
CREATE MATERIALIZED VIEW PopulationVaccinatedPercent AS
	WITH RollingPeopleVaccinated AS (
	SELECT Infected.continent,
	Infected.location,
	Infected.record_date,
	population,
	Vaccine.new_vaccinations,
	SUM(Vaccine.new_vaccinations) OVER(
		PARTITION BY Infected.location
		ORDER BY Infected.location, Infected.record_date) AS Rolling_Total_Vaccinated
	FROM covid_deaths AS Infected
	JOIN covidvaccination AS Vaccine
		ON Infected.location =Vaccine.location
		AND Infected.record_date = Vaccine.record_date
	WHERE Infected.continent IS NOT NULL
		AND Vaccine.new_vaccinations IS NOT NULL
	ORDER BY Infected.location, Infected.record_date
	)
	SELECT *, (Rolling_Total_Vaccinated * 100.0/population) :: FLOAT4 AS PercentPopulationVaccinated
	FROM RollingPeopleVaccinated;