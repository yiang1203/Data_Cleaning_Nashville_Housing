  
/*
Cleaning Data in SQL Queries
*/

USE PortfolioProject;

SELECT *
FROM NashvilleHousing;

-- Standardized Date Format

SELECT CONVERT(date,SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDate_Converted date;

UPDATE NashvilleHousing
SET SaleDate_Converted = CONVERT(date, SaleDate);

-- Using ALTER TABLE to change data type of specific column

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date;

SELECT SaleDate, SaleDate_Converted
FROM NashvilleHousing;


------------------------------------------------

-- Populate Property Address Data

SELECT PropertyAddress
FROM NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;
-- You will see there are lots of the same addresses with different unique_id

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

----------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

-- We have to add two columns to take our separated values
ALTER TABLE NashvilleHousing
ADD Split_Address nvarchar(255);

UPDATE NashvilleHousing
SET Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD Split_City nvarchar(255);

UPDATE NashvilleHousing
SET Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM NashvilleHousing;

-- A simpler way to make this happen

SELECT OwnerAddress
FROM NashvilleHousing;

-- PARSENAME parses string from backwards
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD Owner_Split_Address nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD Owner_Split_City nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD Owner_Split_State nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT * FROM NashvilleHousing;

----------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END); 

SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing;


-------------------------------------------------------------------

--Remove Duplicates
WITH cte AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
		UniqueID) AS row_num
FROM NashvilleHousing)

SELECT * FROM cte
WHERE row_num > 1;


------------------------------------------------------------

-- DELETE unused columns
-- Normally happens in Views, not in your raw data!!!

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

SELECT *
FROM  NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;