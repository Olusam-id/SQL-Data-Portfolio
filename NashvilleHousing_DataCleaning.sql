-- Cleaning Data in SQL Queries
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- Standardize date format
SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE;

--PUPOLATE MISSING PROPERTY ADDRESS
--identify missing values
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress is null;

-- Assuming we have a table with ParcelID and corresponding PropertyAddress
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

-- Reference table with ParcelID and PropertyAddress using self join to populate missing addresses
SELECT h.ParcelID, h.PropertyAddress, r.PropertyAddress AS ReferenceAddress, ISNULL(h.PropertyAddress, r.PropertyAddress) AS UpdatedPropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing h
LEFT JOIN PortfolioProject.dbo.NashvilleHousing r
ON h.ParcelID = r.ParcelID
WHERE h.PropertyAddress IS NULL AND r.PropertyAddress IS NOT NULL;

-- Update missing PropertyAddress using the reference table
UPDATE h
SET PropertyAddress =ISNULL(h.PropertyAddress, r.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing h
LEFT JOIN PortfolioProject.dbo.NashvilleHousing r
ON h.ParcelID = r.ParcelID
WHERE h.PropertyAddress IS NULL AND r.PropertyAddress IS NOT NULL;

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

-- Verify address update
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD streetAddress VARCHAR(255),
	city VARCHAR(100);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET streetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
	city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- SPLIT OWNER ADDRESS INTO OWNER STREET ADDRESS, OWNER CITY, OWNER STATE
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM PortfolioProject.dbo.NashvilleHousing;

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerStreetAddress VARCHAR(255),
	OwnerCity VARCHAR(100),
	OwnerState VARCHAR(50);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-- FIND AND REPLACE Y AND N TO YES AND NO IN THE SoldAsVacant COLUMN
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant);

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

-- REMOVE DUPLICATE ROWS
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				propertyAddress,
				SaleDate,
				LegalReference
	ORDER BY SaleDate DESC) AS rn

FROM PortfolioProject.dbo.NashvilleHousing)

DELETE
FROM RowNumCTE
WHERE rn > 1;

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				propertyAddress,
				SaleDate,
				LegalReference
	ORDER BY SaleDate DESC) AS rn

FROM PortfolioProject.dbo.NashvilleHousing)

SELECT *
FROM RowNumCTE
WHERE rn > 1;

-- DELETE UNNECESSARY COLUMNS
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress;

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;