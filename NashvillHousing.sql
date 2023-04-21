/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing


-- Changing Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

/*

Changing the Date Format Using 'CONVERT()' Then updating the Column in Dataset using 'UPDATE' and ADDING Data using 'ADD'.

*/


--Population property ADDRESS data


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/*
 
The first statement selects all columns and orders the results by "ParcelID". 
The second statement joins rows where ParcelID is the same but PropertyAddress is missing, 
and the third statement updates missing PropertyAddress values by copying from another row with the same ParcelID. 
The code is to fill in missing PropertyAddress values by finding matching ParcelID values.

*/


--Breaking out PropertyAdress into Individual Columns(Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

/*

The query splits the PropertyAddress column in the NashvilleHousing table in the PortfolioProject database into individual columns for Address and City.
Two new columns, PropertySplitAddress and PropertySplitCity, are added to the table and populated with the split values from the PropertyAddress column.

*/

--Breaking out OwnerAddress into Individual Columns(Address, City, State)


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

/*

The query splits the OwnerAddress column in the NashvilleHousing table in the PortfolioProject database into individual columns for Address, City, and State.
Three new columns, OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState, are added to the table and populated with the split values from the OwnerAddress column.

*/



--Change Y and N To Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                   WHEN SoldAsVacant = 'N' THEN 'No'
	               ELSE SoldAsVacant
	               END

/*

The query updates the SoldAsVacant column in the NashvilleHousing table in the PortfolioProject database, 
replacing the values 'Y' and 'N' with 'Yes' and 'No', respectively.
The CASE statement is used to identify the 'Y' and 'N' values and replace them with their corresponding 'Yes' and 'No' values.
After the update, the SoldAsVacant column now contains the updated 'Yes' and 'No' values.
*/


--Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

/*

The query removes duplicates from the NashvilleHousing table in the PortfolioProject database.
A common table expression (CTE) named RowNumCTE is used to add a row number to each row, partitioning by 
ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference, and ordering by UniqueID.
The outer query selects rows where row_num is greater than 1, indicating duplicate rows.
The resulting table displays the duplicate rows, ordered by PropertyAddress.

*/

--DELETIN Duplicate ROWS

WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				   ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

 
-- DELETE Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate