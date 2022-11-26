/*
Cleaning Data in SQL Queries
*/

select *
from PortfolioProject..NashvilleHousing

-- standardizing date format

select saledate, CONVERT(date,saledate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set saledate = CONVERT(date,saledate)

alter table nashvillehousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,saledate)

select SaleDateConverted, CONVERT(date,saledate)
from PortfolioProject..NashvilleHousing

-- populate property address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- breaking out address into individual columns (address, city, state)
 
select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
-- order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from PortfolioProject..NashvilleHousing

alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select * 
from PortfolioProject..NashvilleHousing


select OwnerAddress
from PortfolioProject..NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * 
from PortfolioProject..NashvilleHousing

-- change Y and N to Yes and No in "sold as vacant" field

select distinct(SoldAsVacant),COUNT(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant, 
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 ELSE SoldAsVacant
		 END

--remove duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
	order by uniqueid) row_num
from PortfolioProject..NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress


-- remove unused columns 

select * 
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject..NashvilleHousing
drop column saledate