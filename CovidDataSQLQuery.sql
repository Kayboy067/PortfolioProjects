Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths

--Looking at Total Cases vs Total Death
--Shows the likelihood of dying if you contact covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got covid
Select Location, date, population, total_cases, (total_cases/population)*100 PopulationPercentageInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) HighestInfectionCount, MAX(total_cases/population)*100 PopulationPercentageInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by 4 desc

--Looking at countries with highest death rate compared to population
Select Location, population, MAX(total_deaths) HighestInfectionCount, MAX(total_deaths/population)*100 PercentPopulationDeathRate
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by 4 desc

--Let's break things down by continent

--Showing the continents with highest deat count per population
Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
Select Sum(new_cases) NewCases, Sum(cast(new_deaths as int)) NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Getting percentage of RollingPeopleVaccinate against the population

--Method one USE CTE

With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVaccinatedPercent
From PopvsVac

--Method two TEMP TABLE

--if there is need to alter the table the query below should be maintain on the code
DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Content nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_caccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100 PercentPopulationVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * From PercentPopulationVaccinated


Create View PercentPopulationInfected as
Select Location, population, MAX(total_cases) HighestInfectionCount, MAX(total_cases/population)*100 PopulationPercentageInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
--order by 4 desc

select * from PercentPopulationInfected
order by 1

Create View PercentPopulationDeathRate as
Select Location, population, MAX(total_deaths) HighestInfectionCount, MAX(total_deaths/population)*100 PercentPopulationDeathRate
From PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
--order by 4 desc

select * from PercentPopulationDeathRate
order by 1

Create View TotalDeathPerContinent as
Select continent, MAX(cast(total_deaths as int)) TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
--order by TotalDeathCount desc

select * from TotalDeathPerContinent
order by 2 desc