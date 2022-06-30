Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- Shows liklehood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at total cases vs population

Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
and continent is not null
Where location like '%Ireland%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%Ireland%'
Group by location, population
order by PercentPopulationInfected Desc

-- Showing countries with highest death count per population

Select location, Max(cast(total_deaths As Int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%Ireland%'
Where continent is not null
Group by location
order by TotalDeathCount Desc

-- Let's break this down by continent
-- Showing the continent with the highest death count per popultaion

Select continent, Max(cast(total_deaths As Int)) As TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%Ireland%'
Where continent is not null
Group by continent
order by TotalDeathCount Desc

-- Global no.

Select Sum(new_cases) As total_cases, Sum(cast(new_deaths As Int)) As total_deaths,  Sum(cast(new_deaths As Int))/sum(new_cases)*100 As DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
-- Group by date
order by 1,2

-- Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations As BigInt)) Over (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations As BigInt)) Over (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp table

-- DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations As BigInt)) Over (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentpopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations As BigInt)) Over (Partition By dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select *
From PercentpopulationVaccinated