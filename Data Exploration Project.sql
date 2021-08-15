--Creating covid_deaths table to match covid_deaths.csv columns

CREATE TABLE covid_deaths(
	iso_code VARCHAR(50),
	continent VARCHAR(150),
	location VARCHAR(150),
	date DATE,
	population BIGINT,
	total_cases NUMERIC,
	new_cases NUMERIC,
	new_cases_smoothed NUMERIC(10,3),
	total_deaths NUMERIC,
	new_deaths NUMERIC,
	new_deaths_smoothed NUMERIC(10,3),
	total_cases_per_million NUMERIC(10,3),
	new_cases_per_million NUMERIC(10,3),
	new_cases_smoothed_per_million NUMERIC(10,3),
	total_deaths_per_million NUMERIC(10,3),
	new_deaths_per_million NUMERIC(10,3),
	new_deaths_smoothed_per_million NUMERIC(10,3),
	reproduction_rate NUMERIC(10,3),
	icu_patients NUMERIC,
	icu_patients_per_million NUMERIC(10,3),
	hosp_patients NUMERIC,
	hosp_patients_per_million NUMERIC(10,3),
	weekly_icu_admissions NUMERIC,
	weekly_icu_admissions_per_million NUMERIC(10,3),
	weekly_hosp_admissions NUMERIC,
	weekly_hosp_admissions_per_million NUMERIC(10,3),
	population_density NUMERIC(10,3),
	median_age NUMERIC(10,3),
	aged_65_older NUMERIC(10,3),
	aged_70_older NUMERIC(10,3),
	gdp_per_capita NUMERIC(10,3),
	extreme_poverty NUMERIC(10,3),
	cardiovasc_death_rate NUMERIC(10,3),
	diabetes_prevalence NUMERIC(10,3),
	female_smokers NUMERIC(10,3),
   	male_smokers NUMERIC(10,3),
	handwashing_facilities NUMERIC(10,3),
	hospital_beds_per_thousand NUMERIC(10,3),
	life_expectancy NUMERIC(10,3),
	human_development_index NUMERIC(10,3),
	excess_mortality NUMERIC(10,3)
);

--Importing covid_deaths data from covid_deaths.csv

COPY covid_deaths
FROM 'C:\Data\covid_deaths.csv'
DELIMITER ','
CSV HEADER;

-- Adding ID column as primary key

ALTER TABLE covid_deaths
ADD COLUMN id SERIAL PRIMARY KEY;

-- Creating covid_vaccinations table to match covid_vaccinations.csv columns

CREATE TABLE covid_vaccinations(
	iso_code VARCHAR(50),
	continent VARCHAR(150),
	location VARCHAR(150),
	date DATE,
	new_tests NUMERIC,
	total_tests NUMERIC,
	total_tests_per_thousand NUMERIC(10,3),
	new_tests_per_thousand NUMERIC(10,3),
	new_tests_smoothed NUMERIC,
	new_tests_smoothed_per_thousand NUMERIC(10,3),
	positive_rate NUMERIC(10,3),
	tests_per_case NUMERIC(7,2),
	tests_units VARCHAR(250),
	total_vaccinations NUMERIC,
	people_vaccinated NUMERIC,
	people_fully_vaccinated NUMERIC,
	new_vaccinations NUMERIC,
	new_vaccinations_smoothed NUMERIC,
	total_vaccinations_per_hundred NUMERIC(7,2),
	people_vaccinated_per_hundred NUMERIC(7,2),
	people_fully_vaccinated_per_hundred NUMERIC(7,2),
	new_vaccinations_smoothed_per_million NUMERIC,
	stringency_index NUMERIC(10,3),
	population_density NUMERIC(10,3),
	median_age NUMERIC(7,2),
	aged_65_older NUMERIC(10,3),
	aged_70_older NUMERIC(10,3),
	gdp_per_capita NUMERIC(10,3),
	extreme_poverty NUMERIC(7,2),
	cardiovasc_death_rate NUMERIC(10,3),
	diabetes_prevalence NUMERIC(10,3),
	female_smokers NUMERIC(7,2),
	male_smokers NUMERIC(7,2),
	handwashing_facilities NUMERIC(10,3),
	hospital_beds_per_thousand NUMERIC(7,2),
	life_expectancy NUMERIC(10,3),
	human_development_index NUMERIC(10,3),
	excess_mortality NUMERIC(7,2)
);

--Importing covid_vaccinations data from covid_vaccinations.csv

COPY covid_vaccinations
FROM 'C:\Data\covid_vaccinations.csv'
DELIMITER ','
CSV HEADER;

--Adding ID column as foreign key reference

ALTER TABLE covid_vaccinations
ADD COLUMN id SERIAL REFERENCES covid_deaths(id);

--Selecting all data from covid_deaths

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL;

--Selecting relevant data to work with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE location like 'Can%';

--Likelihood of dying if you catch COVID in Canada
--(total_deaths vs total_cases)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_of_death
FROM covid_deaths
WHERE location = 'Canada'
ORDER BY date;

--Percentage of Canada's population infected with COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_rate_per_population
FROM covid_deaths
WHERE location = 'Canada'
ORDER BY date;

--Highest number of cases per country

SELECT location, population, MAX(total_cases) AS total_case_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_cases) IS NOT NULL
ORDER BY total_case_count DESC;

--Highest infection rate (total_cases per population)

SELECT location, population, MAX((total_cases/population)*100) AS max_infection_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((total_cases/population)*100) IS NOT NULL
ORDER BY max_infection_rate DESC;

--Highest number of deaths per country

SELECT location, population, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY total_death_count DESC;

--Highest number of deaths per continent

SELECT continent, MAX(total_deaths) AS cont_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY cont_death_count DESC;

--Highest death rate (death per population)

SELECT location, population, MAX((total_deaths/population)*100) AS max_death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((total_deaths/population)*100) IS NOT NULL
ORDER BY max_death_rate DESC;

--Highest death rate per continent

SELECT continent, MAX(total_deaths/population) AS cont_death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent;

--Global death rate

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS percentage_of_death 
FROM covid_deaths;

--Global death rate per day

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS percentage_of_death 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER by date;

--Rolling sum of global vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_sum_vaccinations
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.continent, cd.location, cd.date;

--Percentage of vaccinated population

DROP TABLE IF EXISTS global_vaccinations;
CREATE TEMP TABLE global_vaccinations AS
SELECT
	cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_sum_vaccinations
	FROM covid_deaths cd
	INNER JOIN covid_vaccinations cv
	ON cd.location = cv.location and cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	ORDER BY cd.continent, cd.location, cd.date;

SELECT continent, location, date, rolling_sum_vaccinations,
	(rolling_sum_vaccinations/population)*100 AS percentage_vaccination
FROM global_vaccinations;

--Creating views to store data for visualization

CREATE VIEW case_count_per_country AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_sum_vaccinations
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.continent, cd.location, cd.date;

CREATE VIEW infection_rate_per_country AS
SELECT location, population, MAX((total_cases/population)*100) AS max_infection_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((total_cases/population)*100) IS NOT NULL
ORDER BY max_infection_rate DESC;

CREATE VIEW deaths_per_country AS
SELECT location, population, MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY total_death_count DESC;

CREATE VIEW deaths_per_continent AS
SELECT continent, MAX(total_deaths) AS cont_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY cont_death_count DESC;

CREATE VIEW death_rate_per_country AS
SELECT location, population, MAX((total_deaths/population)*100) AS max_death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX((total_deaths/population)*100) IS NOT NULL
ORDER BY max_death_rate DESC;

CREATE VIEW death_rate_per_continent AS
SELECT continent, MAX(total_deaths/population) AS cont_death_rate
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY continent;

CREATE VIEW death_rate_global AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS percentage_of_death 
FROM covid_deaths;

CREATE VIEW global_vaccinations AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS rolling_sum_vaccinations
FROM covid_deaths cd
INNER JOIN covid_vaccinations cv
ON cd.location = cv.location and cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY cd.continent, cd.location, cd.date;
