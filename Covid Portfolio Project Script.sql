SELECT *
  FROM PortfolioProject..[CovidDeaths]
  Where continent is not null
  order by 3,4

  --SELECT *
  --FROM PortfolioProject..[CovidVaccinations]
  --order by 3,4


  -- Select Data that we are going to be using

  Select location, date, total_cases, new_cases,total_deaths, population
  FROM PortfolioProject..[CovidDeaths]
  order by 1,2

  -- Looking at Total Cases VS Total Deaths
  -- Shows likelihood of dying if you contact covid in your country
  Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  FROM PortfolioProject..[CovidDeaths]
  where location like '%states%'
  order by  1,2


  -- Looking at the Total Cases vs Population
  -- Shows what percentage of population got covid

  Select location, date, Population, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
  FROM PortfolioProject..[CovidDeaths]
  where location like '%states%'
  order by  1,2

  -- Looking at countries with Highest Infection Rate compared to Population

  Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths/total_cases)*100 as PercentPopulationInfected
  FROM PortfolioProject..[CovidDeaths]
  -- where location like '%states%'
  Group by Location, Population
  order by  PercentPopulationInfected desc

  -- Showing the countries with the highest Death Count per Population

  Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
  FROM PortfolioProject..[CovidDeaths]
  -- where location like '%states%'
   Where continent is not null
  Group by Location
  order by  TotalDeathCount desc

  -- LET'S BREAK THINGS DOWN BY CONTINENT

    Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
  FROM PortfolioProject..[CovidDeaths]
  -- where location like '%states%'
   Where continent is not null
  Group by Continent
  order by  TotalDeathCount desc


  -- Showing the continet wwith highest DeathCount

      Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
  FROM PortfolioProject..[CovidDeaths]
  -- where location like '%states%'
   Where continent is not null
  Group by Continent
  order by  TotalDeathCount desc

  -- GLOBAL NUMBERS

   Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_Cases)*100 as DeathPercentage
  FROM PortfolioProject..[CovidDeaths]
  -- where location like '%states%'
   Where continent is not null
   --Group by date
  order by  1,2

 -- Looking at Total Population VS Vacination

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVacinated
  --,(RollingPeopleVacinated/population)*100
   from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
  on dea.location =vac.location
  and dea.date = vac.date
    Where dea.continent is not null
    order by  2,3

	--USE CTE

	With PopVsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeoleVcinated)
	as
	(
	  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVacinated
  --,(RollingPeopleVacinated/population)*100
   from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
  on dea.location =vac.location
  and dea.date = vac.date
    Where dea.continent is not null
    --order by  2,3
	)
	Select *, (RollingPeoleVcinated/Population)*100
	from PopVsVac

	-- TEMP TABLE

	DROP TABLE if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVacinated
  --,(RollingPeopleVacinated/population)*100
   from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
  on dea.location =vac.location
  and dea.date = vac.date
    Where dea.continent is not null
    --order by  2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	from #PercentPopulationVaccinated



	--Creating view to store data for later visualiztion

	Create View PercentPopulationVaccinated as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location,
  dea.Date) as RollingPeopleVacinated
  --,(RollingPeopleVacinated/population)*100
   from PortfolioProject..CovidDeaths dea
  join PortfolioProject..CovidVaccinations vac
  on dea.location =vac.location
  and dea.date = vac.date
    Where dea.continent is not null
    --order by  2,3


	Select * 
	from [PercentPopulationVaccinated]
