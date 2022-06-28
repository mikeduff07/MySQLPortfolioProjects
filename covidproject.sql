/*
Covid 19 Data Exploration Project

Skills utilized: Joins, temp tables, views, aggregate functions, windows functions

*/

Select *
from covid.coviddeaths
where continent <> ""
order by 3,4;

-- Selecting the data we are going to work with
Select location, date, total_cases, new_cases, total_deaths, population
from covid.coviddeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Canada
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid.coviddeaths
where location = 'Canada'
order by 1,2;

-- Looking at Total Cases vs Population
-- Showing what percentage of Canadian population got covid
Select location, date, total_cases, Population, (total_cases/population)*100 as InfectedPercentage
from covid.coviddeaths
where location = 'Canada'
order by 1,2;

-- Looking at countries with highest infection rate relative to population
Select location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from covid.coviddeaths
group by location, population
order by InfectedPercentage desc;

-- Showing countries with highest death count relative to population
Select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
from covid.coviddeaths
where continent <> ""
group by location
order by TotalDeathCount desc;

-- Breakdown by continent
-- Showing continents with highest death count
Select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
from covid.coviddeaths
where continent <> ""
group by continent
order by TotalDeathCount desc;

-- Global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned))/sum(new_cases)*100 as DeathPercentage
from covid.coviddeaths
where continent <> ""
group by date
order by 1,2;

-- World Death Percentage
Select sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned))/sum(new_cases)*100 as DeathPercentage
from covid.coviddeaths
where continent <> ""
order by 1,2;

-- Looking at total population vs vaccinations
-- Shows number of people that have received at least one Covid vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> ""
order by 2,3;

-- Using Temp Table to perform calculation on partition by with above query
Drop temporary table if exists PercentPopulationVaccinated;
Create Temporary Table PercentPopulationVaccinated 

(Continent nvarchar(255), 
Location nvarchar(255), 
Date nvarchar(255), 
Population numeric, 
New_vaccinations nvarchar(255), 
RollingPeopleVaccinated numeric);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> ""
order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentage
From PercentPopulationVaccinated;

-- Creating Views to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid.coviddeaths dea
join covid.covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent <> "";

Create view ContinentDeathCount as
Select continent, max(cast(total_deaths as unsigned)) as TotalDeathCount
from covid.coviddeaths
where continent <> ""
group by continent;

Create view CountryDeathCount as
Select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
from covid.coviddeaths
where continent <> ""
group by location;

Create view CountryInfectionRate as
Select location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from covid.coviddeaths
group by location, population;