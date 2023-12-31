/*
	CLEANING DATA IN SQL QUERIES
*/

SELECT *
FROM PortfolioProject.dbo.NashvillHousing

-------------------------------------------------------------
-- Standartize Date Format
-------------------------------------------------------------
SELECT Sale_Date, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvillHousing

ALTER TABLE NashvillHousing
ADD Sale_Date Date;

UPDATE NashvillHousing
SET Sale_Date = CONVERT(Date, SaleDate)

ALTER TABLE NashvillHousing
DROP COLUMN SaleDate;

SELECT *
FROM PortfolioProject.dbo.NashvillHousing

-----------------------------------------------------------------
--Populate Property Address Data
-----------------------------------------------------------------
SELECT *
FROM PortfolioProject.dbo.NashvillHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvillHousing a
JOIN PortfolioProject.dbo.NashvillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvillHousing a
JOIN PortfolioProject.dbo.NashvillHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------
-- Breaking out into Individual Columns (Address, City, State)
--------------------------------------------------------------
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvillHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvillHousing

ALTER TABLE NashvillHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvillHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT *
FROM PortfolioProject.dbo.NashvillHousing

-- Separating Owner Address
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvillHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvillHousing

ALTER TABLE NashvillHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvillHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvillHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvillHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-----------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
-----------------------------------------------------------------
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvillHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.NashvillHousing

UPDATE NashvillHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------
-- Remove Duplicates
--------------------------------------------------
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
	) row_num
FROM PortfolioProject.dbo.NashvillHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

----------------------------------------------------------------
-- Delete Unused Columns
----------------------------------------------------------------
SELECT *
FROM PortfolioProject.dbo.NashvillHousing

ALTER TABLE PortfolioProject.dbo.NashvillHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO