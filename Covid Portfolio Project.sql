
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases,new_cases

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY total_cases,new_cases

SELECT continent, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY continent, date

-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
SELECT continent, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Africa%'
AND continent is not null
ORDER BY continent, date

-- Looking at Total cases vs Population
--Show the persentage of population where Covid was contacted

SELECT continent, date, Population, total_cases, (total_cases/Population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location like '%Africa%'
ORDER BY continent, date

-- Looking at countries with highest Infection rate compared to population

SELECT continent, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/Population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Africa%'
GROUP BY continent, Population DESC

--Showing Countries with Highest Death Count per population

SELECT continent, MAX(CAST(total_deaths AS int) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount


--BREAKING THINGS DOWN BY CONTINENT



--Showing the Continent with the highest death count per Population

SELECT continent, MAX(CAST(total_deaths AS int) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers per Continent

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Africa%'
WHERE continent is not null
GROUP BY date
ORDER BY date,Total_Cases

-- Global Numbers Worldwide

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%Africa%'
WHERE continent is not null
--GROUP BY date
ORDER BY date,Total_Cases


-- Total Population VS Vaccination

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.Location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY CD.location, CD.date

-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.Location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY CD.location, CD.date
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.Location
	AND CD.date = CV.date
--WHERE CD.continent IS NOT NULL


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS 
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(int,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths CD
JOIN PortfolioProject..CovidVaccinations CV
	ON CD.location = CV.Location
	AND CD.date = CV.date
WHERE CD.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated

