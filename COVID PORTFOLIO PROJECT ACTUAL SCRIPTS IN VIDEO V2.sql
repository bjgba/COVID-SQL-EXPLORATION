select *
from coviddeath


ALTER TABLE COVIDDEATH
ALTER COLUMN LOCATION NVARCHAR(150)

ALTER TABLE COVIDVACCINATION
ALTER COLUMN NEW_VACCINATIONS NVARCHAR(255)

WHERE continent IS NOT NULL
order by 3,4

--select *
--from covidvaccination
--order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

--looking at total cases vs total death
--shows likelihood of dying if you have covid in your country

SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,(CAST(total_deaths as float)/CAST(total_cases as float))*100 as deathpercentage
FROM COVIDDEATH
where location like '%state%'
AND continent IS NOT NULL
ORDER BY 1,2

---TOTAL CASES VS POPULATION

SELECT LOCATION,DATE,POPULATION,TOTAL_CASES,(total_cases/population)*100 AS PERCENTPOPULATIONINFECTED
FROM coviddeath
--WHERE location LIKE '%STATE%'
ORDER BY 1,2

-----COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT LOCATION,POPULATION,MAX(TOTAL_CASES) AS HIGHESTINFECTIONCOUNT,MAX((TOTAL_CASES/POPULATION))*100 AS PERCENTPOPULATIONINFECTED
FROM coviddeath
where continent is not null
GROUP BY LOCATION,population
ORDER BY 4 DESC


--SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT LOCATION,MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--right one
SELECT location,MAX(CAST( TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM coviddeath
WHERE  continent IS NULL
GROUP BY location
ORDER BY 2 DESC

---BREAKING THINGS DOWN BY CONTINENT

---SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT CONTINENT,MAX(CAST( TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNT
FROM coviddeath
WHERE  continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


--GLOBAL NUMBER,DEALTH PERCENTAGE

SELECT date, SUM(NEW_CASES),SUM(NEW_DEATHS),
CASE
WHEN SUM(NEW_CASES)=0 THEN NULL
ELSE SUM(new_deaths)/SUM(NEW_CASES)*100
END AS DEALTHPERCENTAGE
FROM COVIDDEATH
where continent IS NOT NULL AND new_cases IS NOT NULL
group by date
order by 1,2



---total population vs vaccination
select dea.continent,dea.location,dea.date,population,new_vaccinations,sum(cast(new_vaccinations as int))
from coviddeath as dea
join covidvaccination as vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,population,new_vaccinations

WITH CTE_EXPRESS AS
(
select dea.continent,dea.location,dea.date,population,new_vaccinations,sum(cast(VAC.new_vaccinations as bigint)) over (partition by dea.location ORDER 
BY DEA.location,DEA.DATE) AS ROLLINGPEOPLEVACCINATED
from coviddeath as dea
join covidvaccination as vac
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null

)

SELECT *,(ROLLINGPEOPLEVACCINATED/POPULATION)*100 AS PERCENTPOPULATIONVACCINATED
FROM CTE_EXPRESS


--TEMP TABLE
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(150),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATION NUMERIC,
ROLLINGPEOPLEVACCINATED NUMERIC
)


INSERT INTO #PERCENTPOPULATIONVACCINATED
select dea.continent,dea.location,dea.date,population,new_vaccinations,sum(cast(VAC.new_vaccinations as bigint)) over (partition by dea.location ORDER 
BY DEA.location,DEA.DATE) AS ROLLINGPEOPLEVACCINATED
from coviddeath as dea
join covidvaccination as vac
on dea.location=vac.location 
and dea.date=vac.date 
--where dea.continent is not null
--ORDER BY 2,3

SELECT *,(ROLLINGPEOPLEVACCINATED/POPULATION)*100 AS PERCENTPOPULATIONVACCINATED
FROM #PERCENTPOPULATIONVACCINATED

--CREATE VIEW TO STORE FOR LATER VISUALIZATION

CREATE VIEW PERCENTPOPULATIONVACCINATED AS
select dea.continent,dea.location,dea.date,population,new_vaccinations,sum(cast(VAC.new_vaccinations as bigint)) over (partition by dea.location ORDER 
BY DEA.location,DEA.DATE) AS ROLLINGPEOPLEVACCINATED
from coviddeath as dea
join covidvaccination as vac
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PERCENTPOPULATIONVACCINATED