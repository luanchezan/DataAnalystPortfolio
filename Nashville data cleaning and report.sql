/****** Script for SelectTopNRows command from SSMS  ******/
SELECT top 10 *  FROM [Portfolio_Project].[dbo].[Nashville_Housing]
--------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate
--saleDateConverted
, CONVERT(Date,SaleDate)
From Portfolio_Project.dbo.Nashville_Housing

Update Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)


-- If it doesn't Update properly

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


Select SaleDate,
SaleDateConverted
--, CONVERT(Date,SaleDate)
From Portfolio_Project.dbo.Nashville_Housing
--------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Portfolio_Project.dbo.Nashville_Housing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Select *
From Portfolio_Project.dbo.Nashville_Housing
Where PropertyAddress is null
order by ParcelID
--------------------------------------------------------------------------------------------------


-- Populate Property Address data


Select *
From Portfolio_Project.dbo.Nashville_Housing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
/*
-- Populate Owner Address data

Select a.ParcelID, a.OwnerAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.OwnerAddress,b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.OwnerAddress is null

Update a
SET OwnerAddress = ISNULL(a.OwnerAddress,b.PropertyAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.OwnerAddress is null

*/
--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolio_Project.dbo.Nashville_Housing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.Nashville_Housing;


ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select PropertySplitCity, PropertySplitAddress
--, *
From Portfolio_Project.dbo.Nashville_Housing


Select OwnerAddress
From Portfolio_Project.dbo.Nashville_Housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio_Project.dbo.Nashville_Housing


ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
--*
From Portfolio_Project.dbo.Nashville_Housing


--------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.Nashville_Housing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio_Project.dbo.Nashville_Housing


Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio_Project.dbo.Nashville_Housing
--order by ParcelID
)
Select *
--Delete
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Portfolio_Project.dbo.Nashville_Housing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE Portfolio_Project.dbo.Nashville_Housing
DROP COLUMN TaxDistrict, PropertyAddress, SaleDate
--,OwnerAddress

Select *
From Portfolio_Project.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------

Select a.UniqueID, a.OwnerSplitAddress, b.ParcelID, b.PropertySplitAddress, ISNULL(a.OwnerSplitAddress,b.PropertySplitAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.[UniqueID ] = b.[UniqueID]
Where a.OwnerSplitAddress is null

Update a
SET OwnerSplitAddress = ISNULL(a.OwnerSplitAddress,b.PropertySplitAddress)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.[UniqueID ] = b.[UniqueID]
Where a.OwnerSplitAddress is null


Select a.UniqueID, a.OwnerSplitCity, b.ParcelID, b.PropertySplitCity, ISNULL(a.OwnerSplitCity,b.PropertySplitCity)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.[UniqueID ] = b.[UniqueID]
Where a.OwnerSplitCity is null
 
Update a
SET OwnerSplitCity = ISNULL(a.OwnerSplitCity,b.PropertySplitCity)
From Portfolio_Project.dbo.Nashville_Housing a
JOIN Portfolio_Project.dbo.Nashville_Housing b
	on a.[UniqueID ] = b.[UniqueID]
Where a.OwnerSplitCity is null

Select 
--OwnerSplitAddress, count(OwnerSplitAddress)
OwnerSplitCity, count(OwnerSplitCity)
From Portfolio_Project.dbo.Nashville_Housing a
Where OwnerSplitCity is null
--Where OwnerSplitAddress is null
Group By OwnerSplitCity
--Group By OwnerSplitAddress
--------------------------------------------------------------------------------------------------
Select OwnerSplitState, count(OwnerSplitState)
From Portfolio_Project.dbo.Nashville_Housing 
Group by OwnerSplitState 

UPDATE Nashville_Housing
SET OwnerSplitState = 'TN'
From Portfolio_Project.dbo.Nashville_Housing 


ALTER TABLE Portfolio_Project.dbo.Nashville_Housing
DROP COLUMN OwnerAddress

Select *
From Nashville_Housing


