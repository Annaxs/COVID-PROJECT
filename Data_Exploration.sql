
select * from dbo.CovidDeaths$
where continent is not NULL
order by 3,4;

--select * from dbo.CovidVaccinations$
--order by 3,4;

select Location, date, total_cases, new_cases,total_deaths, population
from dbo.CovidDeaths$
order by 1,2;

--looking at  total cases vs total deaths
--2-4% chance -likelyhood of dying if you get covid
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where location like '%afghanistan%'
order by 1,2;
--total cases vs total population
select Location, date, total_cases, Population,(total_deaths/population)*100 as DeathPercentage
from dbo.CovidDeaths$ where iso_code ='OWID_AFR'
-- where location like '%afghanistan%'
order by 1,2;

SELECT *  from dbo.CovidDeaths$ where iso_code ='AFG'

--TRUNCATE TABLE dbo.CovidDeaths$

--highest infection rates
--looking at countries with highest infection
--highest number of infection count
select Location,Population,max(total_cases)as HighestInfectioCount, Max(total_deaths/population)*100 as PercentagePopulationInfected 
from dbo.CovidDeaths$ 
group by location, population
order by PercentagePopulationInfected desc

--countries showing the highest death count
select Location,Population,max(cast(Total_deaths as int))as TotalDeathCount
from dbo.CovidDeaths$ 
group by location,population
order by TotalDeathCount desc

--lets break things down using continent
select Location,Population,max(cast(Total_deaths as int))as TotalDeathCount
from dbo.CovidDeaths$ 
where continent is not null
group by location,population
order by TotalDeathCount desc


--showing the continents with hightest death count
select Location,Population,max(cast(Total_deaths as int))as TotalDeathCount
from dbo.CovidDeaths$ 
where continent is not null
group by location,Population
order by TotalDeathCount desc

--breaking global numbers
select Location, date,Population,sum(new_cases),sum(new_deaths)--as TotalDeathCount
from dbo.CovidDeaths$ 
where continent is not null
group by location,population,date
order by 1,2
--percentage deaths new deaths --lr
select Location, date,Population,sum(new_cases)as total_cases,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage--as TotalDeathCount
from dbo.CovidDeaths$ 
where continent is not null
group by location,population,date
order by 1,2

select * from dbo.CovidVaccinations$
--where continent is not NULL
order by 3,4;

--joining both the tables
select * 
from dbo.CovidDeaths$ as dea
join dbo.CovidVaccinations$ as vac
  on
  dea.location = vac.location
  and dea.date = vac.date


  --looking at total population vs vaccinations
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  from dbo.CovidDeaths$ as dea
  join dbo.CovidVaccinations$ as vac
  on
  dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3

  --Truncate table dbo.CovidVaccinations$ 


  --how many people are vaccinated 
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
  , SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
  from dbo.CovidDeaths$ as dea
  join dbo.CovidVaccinations$ as vac
  on
  dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3
  --what % of population is vaccinated
  --use CTE------very important role over again if not understood

  --error!!!!!!!!!!!!!!!!!!!!!!!!!!
  With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
 from dbo.CovidDeaths$ as dea
  join dbo.CovidVaccinations$ as vac
  on
	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


  --temp Table
  Drop table if exists #PercentPopulationVaccinated
  create table #PercentPopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  Insert into #PercentPopulationVaccinated
  select dea.continent, dea.locations, dea.date, dea.population, vac.new_vaccinations
  , SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
  from dbo.CovidDeaths$ as dea
  join dbo.CovidVaccinations$ as vac
  on
  dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  
  )

  --creating view for visualizations
