--CLEANING DATA IN SQL QUERIES--

SELECT *
FROM PortfolioProject..NashvilleHousing

--Standardize Date Format
--remove time
Select SaleDate, CONVERT (Date,SaleDate)
From PortfolioProject..NashvilleHousing

--make new table then update that table with the converted date format and remove later
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

--Matching ParcelID has matching address so we can populate missing values in address
SELECT * --PropertyAddress
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Check which is null and its corrospoding address that matches with ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

--Populate it with the matching address
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
JOIN PortfolioProject..NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing

-- in address there is "address, city" the ',' is the delimeter (seperator), we wanna seperate this out
--use substring charindex selects position, we minus one because we dont want the coma to be in
SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

--Create new columns and add the values in
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

--Now its seperated, its so much more usable data


--Seperating OwnerAddress

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

--use parse name, replace , with . because thats what parsename detects

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)

SELECT *
FROM NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Solid as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
--using row number to find the ones that are the same labeled '2'

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
				
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
Where row_num > 1
Order By PropertyAddress

--Now delete

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID
						) row_num
				
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
Where row_num > 1

------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused columns

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Drop COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
Drop COLUMN SaleDate

--Done!
