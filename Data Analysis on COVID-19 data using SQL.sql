-- Covid 19 Data Exploration 

-- Overview of tables

Select top 1000 *
From Project..CovidDeaths

Select top 1000 *
From Project..CovidVaccinations

-- Countries where the data is taken from

Select Distinct Location
From Project..CovidDeaths
Order by location

-- Death percentage or likelihood in India

Select Location, Date, total_deaths, total_cases, (total_deaths/total_cases)*100 as Death_Percentage
From Project..CovidDeaths
Where location like '%India%' And total_cases is not Null
Order by 1,2

-- Total Cases Vs Population in India

Select location, date, population, total_cases, (total_cases/population)*100 as total_cases_vs_population
From Project..CovidDeaths
Where location like '%India%' And total_cases is not Null
Order by 1,2

-- Percentage of Population Infected

Select location, population, Max(total_cases) as MaxCases, Max(total_cases/population)*100 as MaxPercentage
From Project..CovidDeaths
Group by location, population
Order by MaxPercentage Desc

-- Death Count for each counties

Select location, Max(Cast(total_deaths as int)) as TotalDeaths
From Project..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeaths Desc


-- Death Count for each counties from each continent

Select location, Max(Cast(total_deaths as int)) as TotalDeaths
From Project..CovidDeaths
Where continent like '%america%' --'asia'
Group by location
Order by TotalDeaths Desc


-- Death Count for each continent

Select tab.continent, Sum(Cast(tab.TotalDeaths as int)) as TotalDeaths
From (Select location, continent, Max(Cast(total_deaths as int)) as TotalDeaths
	 From Project..CovidDeaths
	 Where continent is not null
	 Group by location, continent) as tab
Where continent is not null
Group by continent
Order by TotalDeaths Desc

-- Total People Vaccinated in each country

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
and dea.location = 'India'
order by 2,3

-- Using a CTE(Common Table Expression) to find Percentage Vaccinated

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (TotalPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac
Where New_Vaccinations is not null


-- Using a Temp Table to find Percentage Vaccinated

Drop Table if exists #Temp_table
Create Table #Temp_table(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	total_people_vaccinated numeric, 
)
Insert into #Temp_table
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *, (total_people_vaccinated/population)*100 as PercentageVaccinated
From #Temp_table


-- Creating View to store data for later visualizations

Create View percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From percent_population_vaccinated

