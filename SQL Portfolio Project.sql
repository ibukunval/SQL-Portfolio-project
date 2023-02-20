--To view the dataset with the location and date set in an orderly manner. There are 220343 rows
select *
from PortfolioProject.. CovidDeaths
order by 3,4

--To view the dataset, with continent and location set to display the dataset in an orderly manner. There are 220343 rows
select * 
from PortfolioProject..covidVaccinations
order by 2,3

--To view data of interest that is required to carry out the analysis
select continent, location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.. CovidDeaths
order by 1,2

--To view the percentage deaths due to covid in descending order. 
--North Korea had the highest cases of covid deaths.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
order by 5 DESC

--To view % of deaths due to covid in Africa. 
--There were 50913 records of covid cases from Africa with Sudan having the highest deaths % for 7 consecutive days wtihin March, 2020
select continent,location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent like '%africa%'
order by 6 DESC


--To display % of population with covid in world
----Europe had the highest % of number of persons infected with COVID in the world.
--Cyprus and Faeroe Islands being the top 2 within the continent to have covid infected persons
Select continent, Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 6 desc

--To display % of population with covid in Africa
--Seychelles had the highest % of number of persons infected with COVID for 261 days in 2022
Select continent, Location, date, Population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent like '%africa%'
order by 6 desc


-- To view countries with Highest Infection Rate compared to Population
--There were 244 countries reported. Cyprus, Faeroe, San Marino, Gilbraltar and Andorra as top 5 countries with highest rate of infection 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing contintents with the highest death count
--There were 6 continents. North America had the highest number of deaths
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- To view countries with Highest number of Deaths per Population
--231 countries were displayed. USA recorded the highest number of deaths
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by 2 desc

-- WORLD COVID RECORD
--There were 615952344 covid cases and 6507144 deaths globally. 
--Also, there is a chance that one person in every group of 100 persons with covid will die due to covid.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 

-- Total number of COVID cases and deaths per continent in descending order. Africa had the least number of COVID cases while Oceania recorded the least number of deaths
Select continent, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
From PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order  by 2 desc

-- Total covid cases and deaths in each continent. Europe had the highest number of cases and deaths but ranked 3rd as par likely of dying due to covid
Select continent, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2,3

-- the first record of covid cases and death was made in late January, 2020
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by date desc

-- To join the two tables that contain data on deaths and vaccination together, with alias 'cod' and cov'.
select *
From PortfolioProject..CovidDeaths cod
Join PortfolioProject..covidVaccinations cov
On cod.location = cov.location
	and cod.date = cov.date

-- Presents the record of vaccinations done on a daily basis in each location. 207670 records on daily vaccination was displayed
select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations
From PortfolioProject..CovidDeaths cod
Join PortfolioProject..CovidVaccinations cov
On cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null 
order by 2,3

-- 24741000 people had received atleast one type of vaccine
Select MAX(cast(cov.new_vaccinations as int)) as TotalPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths cod
Join PortfolioProject..covidVaccinations cov
On cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null 

-- Afghanistan started giving out vaccines in May,2021 and had a total of 23575 vaccinated by end of Septemeber,2022.
Select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations
, SUM(CONVERT(int,cov.new_vaccinations)) OVER (Partition by cod.Location Order by cod.location, cod.date) as CummulativePeopleVaccinated
From PortfolioProject..CovidDeaths cod
Join PortfolioProject..covidVaccinations cov
On cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null 


-- Using CTE to perform Calculation on Partition By in the above query

With PopVac (continent, location, date, population, new_Vaccinations, CummulativePeopleVaccinated)
as
(
Select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations
, SUM(CONVERT(int,cov.new_vaccinations)) OVER (Partition by cod.Location Order by cod.location, cod.Date) as CummulativePeopleVaccinated
From PortfolioProject..CovidDeaths cod
Join PortfolioProject..CovidVaccinations cov
	On cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null 
)
Select *, (CummulativePeopleVaccinated/Population)*100
From PopVac



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations
, SUM(CONVERT(int,cov.new_vaccinations)) OVER (Partition by cod.Location Order by cod.location, cod.Date) as CummulativePeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths cod
Join PortfolioProject..covidVaccinations cov
	On cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null 