-- First 20 rows
-- Primeras 20 filas de la base de datos
SELECT *
FROM "Covid"."covid-deaths"
LIMIT 20;

-- locations disregarding whole continents and the whole world
-- Locaciones sin tomar en cuenta continentes y todo el mundo
Select *
From "Covid"."covid-deaths"
Where continent NOT LIKE ''
Order By 1,3;

-- locations containing whole continents' data but disregarding the whole world's data
-- Locaciones solo de datos de continentes sin tomar en cuenta datos de todo el mundo
Select *
From "Covid"."covid-deaths"
Where continent LIKE ''
AND location NOT LIKE 'World'
Order By 3 DESC;

-- locations containing the whole world's data only
-- Locaciones solo de datos de todo el mundo
Select *
From "Covid"."covid-deaths"
WHERE location LIKE 'World'
Order By 3 DESC;

-- Select data that we are going to be starting with ordered by location and date
-- Seleccionando los datos más relevantes ordenado por locación y fecha

Select location, datetime, total_cases, new_cases, total_deaths, population
From "Covid"."covid-deaths"
Where continent NOT LIKE '' 
Order By 1,2;


-- Total Cases vs Total Deaths
-- Total de casos vs Total de muertes

-- Shows likelihood of dying if you contract Covid in US
-- Muestra la probabilidad de morir si se contrae Covid en EEUU
	
Select location, datetime, total_cases,total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From "Covid"."covid-deaths"
Where total_deaths not like ''
And total_cases > 0
And location like 'United States'
Order By datetime;

-- Shows likelihood of dying if you contract Covid in Colombia
-- Muestra la probabilidad de morir si se contrae Covid en Colombia
Select location, datetime, total_cases,total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From "Covid"."covid-deaths"
Where total_deaths not like ''
And total_cases > 0
And location like 'Colombia'
Order By datetime;

-- Total Cases vs Population
-- Total de casos vs Población

-- Shows what percentage of population infected with Covid in the US and Colombia
-- Muestra el porcentajde población que ha contraído Covid en EEUU y Colombia

Select location, datetime, population, total_cases, 
(cast(total_cases as float)/population)*100  as PercentPopulationInfected
From "Covid"."covid-deaths"
Where population > 0
And location like '%States'
Or location like 'Colombia'
Order By 1,2;

-- Countries with Highest Infection Rate compared to Population
-- Países con la tasa de infección más alta por población

Select location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((Cast(total_cases as float)/population))*100 as PercentPopulationInfected
From "Covid"."covid-deaths"
Where population > 0
-- Where location like '%States'
-- Where location like 'Colombia'
Group by location, Population
Order By HighestInfectionCount Desc, PercentPopulationInfected Desc;

-- Countries with Highest Death Count per Population
-- Países con la tasa de mortalidad más alta por población

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From "Covid"."covid-deaths"
-- Where location like '%States'
-- Where location like 'Colombia'
Where population > 0
And total_deaths Not Like ''
And continent Is Not null 
Group by location
Order By TotalDeathCount Desc;

-- BREAKING THINGS DOWN BY CONTINENT
-- MOSTRANDO DATA DE CONTINENTES ENTEROS

-- Showing contintents with the highest death count per population
-- Mostrando continentes con el número mas alto por población

Select location as Continent, MAX(Cast(Total_deaths As int)) As TotalDeathCount
From "Covid"."covid-deaths"
-- Where location like '%states%'
-- Where location like 'Colombia'
Where continent Like ''
And total_deaths Not Like ''
Group by location
Order By TotalDeathCount Desc;

-- GLOBAL NUMBERS
-- CIFRAS GLOBALES

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From "Covid"."covid-deaths"
-- Where location like 'States%'
-- Where location like 'Colombia'
where continent Not Like ''
And total_deaths Not Like ''
And new_deaths Not Like ''
--Group By datetime
Order By 1,2

-- Elderly people are more likely to die from Covid so life expectancy probably needs to be recalculated
-- Personas ancianas tienen más probabilidades de morir de Covid por lo 
-- que la esperanza de vida probablemente deba ser recalculada

Select continent, location, population, MAX(life_expectancy) as HighestLifeExpectancy
From "Covid"."covid-deaths"
Where population > 0
-- Where location like '%States'
-- Where location like 'Colombia'
Group by continent, location, population
Order By HighestLifeExpectancy Desc;


-- Total Population vs Vaccinations
-- Población total vs Vacunados

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Muestra el porcentaje de la población que ha recibido la vacuna del Covid

Select dea.continent, dea.location, dea.datetime, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations::integer) 
OVER (Partition by dea.Location Order by dea.location, dea.datetime) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From "Covid"."covid-deaths"  dea
Join "Covid"."covid-vaccinated" vac
	On dea.location = vac.location
	and dea.datetime = vac.datetime
where dea.continent Not Like '' 
And vac.new_vaccinations Not Like ''
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
-- Usando CTE para calcular sobre la partición de la consuolta anterior

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.datetime, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations::float) 
OVER (Partition by dea.Location Order by dea.location, dea.datetime) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From "Covid"."covid-deaths" dea
Join "Covid"."covid-vaccinated" vac
	On dea.location = vac.location
	And dea.datetime = vac.datetime
where dea.continent Not Like '' 
And vac.new_vaccinations Not Like ''
)
Select *, (RollingPeopleVaccinated/population)*100 As PercentagePeopleVaccinated
From PopvsVac
where population > 0


-- Creating View to store data of daily deceased population according to the daily death count´s statitics
-- Creando Vista para almacenar datos de la población que ha fallecido en la estadística de personas fallecidas

Create View "Covid".RollingDeathPeople as
Select continent, location, datetime, population, new_deaths, SUM(new_deaths::integer) 
OVER (Partition by Location Order by location, datetime) As RollingPeopleVaccinated
From "Covid"."covid-deaths"
where continent Not Like ''
And new_deaths::integer > 0

-- Creating View to store data of daily vaccinated population 
-- Creando Vista para almacenar datos de la población vacunada a diario

Create View "Covid".PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.datetime, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations::float) 
OVER (Partition by dea.Location Order by dea.location, dea.datetime) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From "Covid"."covid-deaths" dea
Join "Covid"."covid-vaccinated" vac
	On dea.location = vac.location
	And dea.datetime = vac.datetime
where dea.continent Not Like '' 
And vac.new_vaccinations Not Like ''





