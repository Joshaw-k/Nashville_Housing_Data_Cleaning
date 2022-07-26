/* Cleaning Date In SQL Queries */

-- Visual Assessments
SELECT * 
FROM housing1

------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT sales_date, CAST(SaleDate AS DATE) AS Date
FROM housing1

ALTER TABLE housing1 -- creating a new column in the housing table
ADD sales_date DATE;

UPDATE housing1 -- Populating the new column with SaleDate data
SET sales_date = CAST(SaleDate AS DATE)

------------------------------------------------------------------------------------------------------------------

-- Populate Null Property Address Data

SELECT ParcelID,PropertyAddress
FROM housing1
ORDER BY ParcelID
/* Some Properties were sold more than ones, but their PropertyAddress was saved only once */

-- Using Joins to populate null values
SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing1 AS a
LEFT JOIN housing1 b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

ALTER TABLE housing1
ADD Property_Address TEXT

UPDATE housing1 AS a  -- Updating the propertyaddress null values
LEFT JOIN housing1 as b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)

------------------------------------------------------------------------------------------------------------------

-- Breaking Up PropertyAddress Into Individual Columns

SELECT PropertyAddress,
		SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) AS Address,
		SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1,LENGTH(PropertyAddress)) AS City
FROM housing1

ALTER TABLE housing1
ADD Address TEXT;

UPDATE housing1
SET Address = SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1)

ALTER TABLE housing1
ADD City TEXT;

UPDATE housing1
SET City = SUBSTRING(PropertyAddress,LOCATE(',',PropertyAddress)+1,LENGTH(PropertyAddress))


SELECT OwnerAddress,
		SUBSTRING_INDEX(OwnerAddress,',',1) AS Address,
		SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
		SUBSTRING_INDEX(OwnerAddress,',',-1) AS State
FROM housing1

ALTER TABLE housing1
ADD Owner_Address TEXT;

UPDATE housing1
SET  Owner_Address = SUBSTRING_INDEX(OwnerAddress,',',1)

ALTER TABLE housing1
ADD Owner_City TEXT;

UPDATE housing1
SET Owner_City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)

ALTER TABLE housing1
ADD Owner_State TEXT;

UPDATE housing1
SET Owner_State = SUBSTRING_INDEX(OwnerAddress,',',-1)

------------------------------------------------------------------------------------------------------------------

-- Change Y and N to YES and NO in "SoldAsVacant" field

SELECT DISTINCT SoldAsVacant
FROM housing1

SELECT DISTINCT (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SoldAsVacant = 'N' THEN 'No'
		 		ELSE SoldAsVacant END)
FROM housing1

UPDATE housing1
SET SoldAsVacant = (CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
		 					ELSE SoldAsVacant END)
		 					
------------------------------------------------------------------------------------------------------------------

-- Removing duplicates

WITH duply AS (
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SaleDate,
		SalePrice,
		LegalReference 
		ORDER BY ParcelID) dup
FROM housing1
)
DELETE 
FROM duply
WHERE dup > 1

------------------------------------------------------------------------------------------------------------------

-- Removing Unused Columns

ALTER TABLE housing1
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict,SaleDate