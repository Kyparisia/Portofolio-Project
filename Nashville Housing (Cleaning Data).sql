/*
Cleaning Data in SQL Queries
*/

SELECT * FROM nashville;
----------------------------------------------------

-- Standardize Date Format
SELECT SaleDate FROM nashville;

ALTER TABLE nashville
ADD SaleDateConverted date;
UPDATE nashville
SET SaleDateConverted = str_to_date(SaleDate,'%M %d,%Y');

SELECT SaleDateConverted FROM nashville;

----------------------------------------------------

-- Populate Property Address data
SELECT * FROM nashville
-- WHERE PropertyAddress = ''
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IF(a.PropertyAddress= '', b.PropertyAddress, a.PropertyAddress)  FROM nashville a
JOIN nashville b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

UPDATE nashville a 
JOIN nashville b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IF(a.PropertyAddress= '', b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '';

----------------------------------------------------

-- Breaking out PropertyAddress into Individual Columns (Address, City, State)
SELECT PropertyAddress FROM nashville;

SELECT SUBSTRING(PropertyAddress, 1, POSITION("," IN PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, POSITION("," IN PropertyAddress) +1, LENGTH(PropertyAddress)) AS City
FROM nashville;

ALTER TABLE nashville
ADD PropertySplitAddress nvarchar(255), ADD PropertySplitCity nvarchar(255);

UPDATE nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION("," IN PropertyAddress) -1);
UPDATE nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION("," IN PropertyAddress) +1, LENGTH(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity FROM nashville;

-- Breaking out OwnerAddress into Individual Columns (Address, City, State)
SELECT OwnerAddress FROM nashville;

SELECT SUBSTRING_INDEX(OwnerAddress, ',',1), 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2), ',', -1) , 
SUBSTRING_INDEX(OwnerAddress, ',',-1)  FROM nashville;

ALTER TABLE nashville
ADD OwnerSplitAddress nvarchar(255), ADD OwnerSplitCity nvarchar(255), ADD OwnerSplitState nvarchar(255);

UPDATE nashville
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',',1);
UPDATE nashville
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2), ',', -1);
UPDATE nashville
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',',-1);

SELECT OwnerSplitAddress, OwnerSplitCity,OwnerSplitState FROM nashville;

----------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) FROM nashville
GROUP BY SoldAsVacant;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
END
FROM nashville;

UPDATE nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END;
	
----------------------------------------------------

-- Find Duplicates

WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num  FROM nashville
)
SELECT * FROM RowNumCTE
WHERE row_num>1;

-- REMOVE Duplicates
WITH RowNumCTE AS (
SELECT *, ROW_NUMBER() OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num  FROM nashville
)
DELETE FROM nashville USING nashville JOIN RowNumCTE ON nashville.UniqueID = RowNumCTE.UniqueID
WHERE row_num>1;

----------------------------------------------------

-- Delete Unused Columns (DON T DO IT ON THE ORIGINAL DATA!!)
SELECT * FROM nashville;

ALTER TABLE nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAdress, SaleDate;


----------------------------------------------------

