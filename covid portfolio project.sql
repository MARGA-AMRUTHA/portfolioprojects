select * from PortfolioProject..[covid death]
WHERE continent IS NOT NULL
order by 3,4



select * from PortfolioProject..[covid vaccination]
order by 3,4

select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..[covid death]
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date, total_cases,new_cases,total_deaths,isnull([total_deaths]/nullif([total_cases],0),0)*100 as DeathPercentage
from PortfolioProject..[covid death]
where location like '%China%'
order by 1,2

--looking at Total Cases vs Population
--shows that percentage of people got covid 
select location,date, total_cases,population,total_deaths,isnull([total_deaths]/nullif([population],0),0) as PercentPopulationInfec
from PortfolioProject..[covid death]
where location like '%China%'
order by 1,2

select location,population, MAX(total_cases) as HightestInfectionCount,Max( isnull([total_deaths]/nullif([population],0),0))*100 as PercentPopulationInfec
from PortfolioProject..[covid death]
group by location,population
order by PercentPopulationInfec desc


--showing countries with highest death count per population

--select location,Max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..[covid death]
select location,Max((total_deaths)) as TotalDeathCount
from PortfolioProject..[covid death]
--where location like '%China%'
WHERE CONTINENT IS NOT NULL
group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWNN BY CONTINENT

--SHOWING CONTINENT WITH HIGHEST DEATH RATE

select continent,Max((total_deaths)) as TotalDeathCount
from PortfolioProject..[covid death]
--where location like '%China%'
WHERE CONTINENT IS NOT NULL
group by CONTINENT
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(isnull([new_deaths]/nullif([new_cases],0),0))*100 as DeathPercentage
from PortfolioProject..[covid death]
where continent is not null
group by date
order by 1,2

--LOOKING TOTAL POPULATIO VS VACCINNATIONS

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations from PortfolioProject..[covid death] dea
 join PortfolioProject..[covid vaccination] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
order by 2,3

--ROLLING CASTE

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..[covid death] dea
 join PortfolioProject..[covid vaccination] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
order by 2,3

--CTE(common table expression)

WITH PopvsVac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..[covid death] dea
 join PortfolioProject..[covid vaccination] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 
)
select * ,(Rollingpeoplevaccinated/population)*100 as percentpopulationvaccinated
from PopvsVac

--TEMP TEMPORARY TABLE

CREATE TABLE Percentofpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)
insert into Percentofpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..[covid death] dea
 join PortfolioProject..[covid vaccination] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null

 select * ,(Rollingpeoplevaccinated/population)*100 as percentpopulationvaccinated
from Percentofpopulationvaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
GO
CREATE VIEW
Percentpopvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from PortfolioProject..[covid death] dea 
 join PortfolioProject..[covid vaccination] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
GO 
