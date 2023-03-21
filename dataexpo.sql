select * from PortfolioProject..CovidDeaths$
order by 3, 4

select * from PortfolioProject..CovidVaccinations$
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2;

--total cases vs total deaths

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location = 'India'
order by 1,2;

--totalcases vs population
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
--where location = 'India'
order by 1,2;

--countries with highest infection rate
select location, population,  max(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as PopulationPercentageInfected
from PortfolioProject..CovidDeaths$
--where location = 'India'
group by population, location
order by PopulationPercentageInfected desc;

-- countries with highest death count per population
select location, Max(cast(total_deaths as bigint)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where continent is not null
group by  location
order by TotalDeathCount desc; 

select location, Max(cast(total_deaths as bigint)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where continent is null
group by  location
order by TotalDeathCount desc; 

-- continent with highest death count per population
select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
where continent is not null
group by  continent
order by TotalDeathCount desc;

--Global numbers
select Sum(new_cases) as Total_cases, Sum(cast(new_deaths as int )) as total_deaths, Sum(cast(new_deaths as int ))/Sum(new_cases)*100 DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2;

select * from PortfolioProject..CovidVaccinations$;

-- Total Population vs Vaccinations
select dea.location, dea.date, dea.population, dea.continent, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccinations$ as Vac
on Dea.location = Vac.location
and Dea.Date=Vac.date
where dea.continent is not  null --and  dea.location ='India'
order by 1,2;

-- Use of CTE

with PopvsVac ( location, date, population, continent, new_vaccinations,RollingPeopleVaccinated) 
as
(
select dea.location, dea.date, dea.population, dea.continent, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) over
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccinations$ as Vac
on Dea.location = Vac.location
and Dea.Date=Vac.date
where dea.continent is not  null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.location, dea.date, dea.population, dea.continent, vac.new_vaccinations, Sum(convert(int,vac.new_vaccinations)) over
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ as Dea
join PortfolioProject..CovidVaccinations$ as Vac
on Dea.location = Vac.location
and Dea.date=Vac.date
--where dea.continent is not  null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;







