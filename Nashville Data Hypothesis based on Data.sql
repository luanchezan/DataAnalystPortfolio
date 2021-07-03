SELECT top 10 *
  FROM [dbo].[Nashville_Housing]

  --Nashville Housing


--------------------------------------------------------------------------
--#Analysis

--Bedroom count vs Price (Grouped by bedroom count)
--Bathroom count vs Price (Grouped by bathroom count)
--Acreage/Squared meters vs Price (Grouped by acreage/squared meters)
--Sold as Vacant vs Price (Grouped by SAV)

--Location(Property Address) vs Price (Grouped by Location)
--Land Use vs Price (Grouped by Land Use)
--Year Build vs Price (Grouped by Year Build)
--Land Use vs City
--Year sold vs City
--Year sold vs Location
--SAV vs City

--#Hypothesis for Data Viz

-- Higher number of bedrooms/bathrooms higher price
-- Higher number of acreage higher price
-- The older the house the higher the price
-- If the availability of moving in is shorter the properties are more expensive 
-- Bigger cities have more expensive properties

-- There are more apartments, PH and condos in bigger cities
-- Smaller cities have older properties
-- People are use to sell their properties to get the money to move out in small cities



/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (10) *
  FROM [Portfolio_Project].[dbo].[Nashville_Housing]

SELECT DISTINCT(PropertySplitCity), Count(PropertySplitCity) As PropertyCityCount
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By PropertySplitCity, OwnerSplitCity

SELECT DISTINCT(OwnerSplitCity), Count(OwnerSplitCity) As OwnerCityCount
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By PropertySplitCity, OwnerSplitCity


SELECT OwnerSplitCity, OwnerSplitCity 
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
WHERE  OwnerSplitCity <> OwnerSplitCity 


--------------------------------------------------------------------------
--Acreage => Convert to squared meters 1 Acre = 4046.86 sqrd meters
--Figure out if the Total Value/ Building Value > Sale Price
--Figure out if year build > year sold

SELECT Acreage, SalePrice, (Acreage*4046.86) As SquaredMeters
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

ALTER TABLE [Nashville_Housing]
ADD SquaredMeters float
--------------------------------------------------------------------------
--Properties classified by bedrooms
SELECT Bedrooms, SalePrice, Count(Bedrooms) AS BedroomCount--, SoldAsVacant, FullBath, HalfBath,Acreage, 
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Where Bedrooms Is Not Null
Group By Bedrooms, SalePrice
Order By Bedrooms

--Properties in the same address
SELECT  Acreage, Count(Acreage) As AcreageCount,SquaredMeters, SalePrice,PropertySplitAddress--, Acreage,Bedrooms, ,FullBath, HalfBath,  SoldAsVacant
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Where Acreage Is Not Null
Group By Acreage,SquaredMeters, SalePrice, PropertySplitAddress
Having Count(Acreage) > 1
Order By AcreageCount DESC, Acreage

--Similar houses in the same neighborhood
SELECT Bedrooms, Count(Bedrooms) As NumOfBedrooms, PropertySplitAddress, PropertySplitAddress --, Acreage,Bedrooms, ,FullBath, HalfBath,  SoldAsVacant
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Where Bedrooms Is Not Null
Group By Bedrooms, PropertySplitAddress
Having Count(PropertySplitAddress) > 1
Order By NumOfBedrooms DESC,Bedrooms

--Price according to location, space and bedrooms
SELECT Acreage, Bedrooms, Count(Bedrooms) As NumOfBedrooms, PropertySplitAddress, PropertySplitCity, SalePrice--, Acreage,Bedrooms, ,FullBath, HalfBath,  SoldAsVacant
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Where Bedrooms Is Not Null
Group By Bedrooms, PropertySplitAddress,PropertySplitCity,Acreage,SalePrice
Having Count(PropertySplitAddress) > 1
Order By PropertySplitCity, NumOfBedrooms DESC,Bedrooms
--------------------------------------------------------------------------


SELECT  PropertySplitCity, LandUse, Count(LandUse) PropertyType
--SoldAsVacant,  DATEPART(Year, SaleDateConverted) as PropertyYearSold
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By LandUse,  PropertySplitCity--, DATEPART(Year, SaleDateConverted)
Order By PropertySplitCity


SELECT LandUse, Count(LandUse) PropertyType
--, SoldAsVacant, PropertySplitCity, DATEPART(Year, SaleDateConverted) as PropertyYearSold
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By LandUse--, SoldAsVacant
Order By PropertyType DESC

SELECT PropertySplitCity, Count(PropertySplitCity) Cities--, SoldAsVacant, PropertySplitCity, DATEPART(Year, SaleDateConverted) as PropertyYearSold
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By PropertySplitCity--, SoldAsVacant
Order By Cities DESC

--------------------------------------------------------------------------
--#Preprocessing
--Acreage => Convert to squared meters 1 Acre = 4046.86 sqrd meters

SELECT Acreage, SalePrice, (Acreage*4046.86) As SquaredMeters
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

ALTER TABLE [Nashville_Housing]
ADD SquaredMeters float

UPDATE [Nashville_Housing]
SET SquaredMeters = Acreage*4046.86

SELECT Acreage, SalePrice, SquaredMeters
FROM [Portfolio_Project].[dbo].[Nashville_Housing]

--------------------------------------------------------------------------

--Changing the properties which have a year of built wrong
SELECT YearBuilt, DATEPART(YEAR, SaleDateConverted) AS PropertyYearSold
FROM [Nashville_Housing]
Where YearBuilt > DATEPART(YEAR, SaleDateConverted) 

Update [Nashville_Housing]
Set YearBuilt = DATEPART(YEAR, SaleDateConverted) 
Where YearBuilt > DATEPART(YEAR, SaleDateConverted) 

SELECT YearBuilt, DATEPART(YEAR, SaleDateConverted) AS PropertyYearSold
FROM [Nashville_Housing]
Where YearBuilt >= DATEPART(YEAR, SaleDateConverted) 

--Figure out if the Total Value/ Building Value > Sale Price
-- Case When SalePrice is lower and when SalePrice is upper than TotalValue
SELECT TotalValue, BuildingValue, SalePrice
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
WHERE TotalValue > SalePrice
OR BuildingValue > SalePrice

ALTER TABLE Nashville_Housing
Add Profit Nvarchar(10);

Update Nashville_Housing
SET Profit = 'Yes'
WHERE TotalValue < SalePrice
OR BuildingValue < SalePrice

Update Nashville_Housing
SET Profit = 'No'
WHERE TotalValue >= SalePrice
OR BuildingValue >= SalePrice

Update Nashville_Housing
SET Profit = 'Yes' 
Where SalePrice > Avg(SalePrice)
Group By PropertySplitCity


Select PropertySplitCity, Count(PropertySplitCity) As PropCount, Avg(SalePrice) AvgSalePrice
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By PropertySplitCity
Order By PropCount Desc


SELECT TotalValue, BuildingValue, LandUse,SalePrice, Profit
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
WHERE Profit Is Not Null
Order By Profit DESC
--------------------------------------------------------------------------
Update [Nashville_Housing]
Set LandUse='VACANT RESIDENTIAL LAND'
Where LandUse = 'VACANT RES LAND'

SELECT LandUse, Count(LandUse) PropertyType--, SoldAsVacant, PropertySplitCity, DATEPART(Year, SaleDateConverted) as PropertyYearSold
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Group By LandUse--, SoldAsVacant
Order By PropertyType DESC

--------------------------------------------------------------------------
--Property type's sale date
Select LandUse, PropertySplitCity, SalePrice, SaleDateConverted
FROM [Portfolio_Project].[dbo].[Nashville_Housing]
Order By SaleDateConverted, LandUse

