/* Data Cleaning in SQL */

SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing



-- Standardize Date Format 

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM SQLPortfolio.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



-- Populate Property Address data

SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing
WHERE PropertyAddress is null

SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolio.dbo.NashvilleHousing a
JOIN SQLPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolio.dbo.NashvilleHousing a
JOIN SQLPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null



-- Break out address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM SQLPortfolio.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM SQLPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM SQLPortfolio.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM SQLPortfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing



-- Change Y and N to Yes and No in SoldAsVacant for clarification

SELECT distinct (SoldAsVacant), COUNT(SoldAsVacant)
FROM SQLPortfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM SQLPortfolio.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT distinct SoldAsVacant
FROM SQLPortfolio.dbo.NashvilleHousing



-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (  
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
				 ) row_num
FROM SQLPortfolio.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



-- Delete Unused Columns

ALTER TABLE NashvilleHousing 
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing