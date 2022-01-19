/*

Data cleaning

*/

select * from
PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------------------

-- Standardising Date Format

Update PortfolioProject.dbo.NashvilleHousing
SET Saledate = CONVERT(Date,SaleDate)

--alter table NashvilleHousing
--add Saledatenew date

--Update NashvilleHousing
--SET SaleDatenew = CONVERT(Date,SaleDate)

--alter table NashvilleHousing 
--drop column Saledate

----------------------------------------------------------------------------------------------------------------------------------------

--replacing all null values in PropertyAddress column using the relationship btw Parcelid and propertyaddress

select a.ParcelID, a.propertyaddress, b.parcelid, b.propertyaddress from 
PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.parcelid
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is NULL

update a
set a.propertyaddress=ISNULL(a.propertyaddress, b.propertyaddress)
from 
PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.parcelid
and a.[UniqueID ]<> b.[UniqueID ]
where a.propertyaddress is NULL

-----------------------------------------------------------------------------------------------------------------------------------------

--Breaking the address column into address, city, State


select PropertyAddress, SUBSTRING(Propertyaddress,1,(CHARINDEX( ',', Propertyaddress)-1))
from PortfolioProject.dbo.NashvilleHousing

alter table  PortfolioProject.dbo.NashvilleHousing
add Propertyaddresssplit nvarchar(255),
Propertycitysplit nvarchar(255)


update PortfolioProject.dbo.NashvilleHousing
set Propertyaddresssplit= SUBSTRING(Propertyaddress,1,(CHARINDEX( ',', Propertyaddress)-1))
, Propertycitysplit= SUBSTRING(Propertyaddress,(CHARINDEX( ',', Propertyaddress)+1), len(Propertyaddress))



--using Parsename function

select owneraddress from
PortfolioProject.dbo.NashvilleHousing

--select PARSENAME(replace(owneraddress,',' , '.'),1) --1 index will give the last element separated by comma (parsename() works reverse)
--from
--PortfolioProject.dbo.NashvilleHousing

--select PARSENAME(replace(owneraddress,',' , '.'),2) 
--from
--PortfolioProject.dbo.NashvilleHousing

alter table  PortfolioProject.dbo.NashvilleHousing
add Owneraddresssplit nvarchar(255),
Ownercitysplit nvarchar(255),
Ownerstatesplit nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing
set Owneraddresssplit=PARSENAME(replace(owneraddress,',' , '.'),3),
Ownercitysplit =PARSENAME(replace(owneraddress,',' , '.'),2),
Ownerstatesplit =PARSENAME(replace(owneraddress,',' , '.'),1)

----------------------------------------------------------------------------------------------------------------------------------------

-- change Y and N to yes and No in "Soldasvacant" field


select Distinct(soldasvacant)
from PortfolioProject.dbo.NashvilleHousing

select soldasvacant,
case when soldasvacant='Y' then 'Yes'
	when soldasvacant='N' then 'No'
	else soldasvacant
	end as Newsoldasvacant
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant= case when soldasvacant='Y' then 'Yes'
	when soldasvacant='N' then 'No'
	else soldasvacant
	end 

-----------------------------------------------------------------------------------------------------------------------------------------

-- Removing Duplicates

with duprow as
(
select *,
ROW_NUMBER() over(PARTITION by 
							ParcelID,
							PropertyAddress,
							SalePrice,
							LegalReference,
							Saledate
					order by uniqueid) row_num
from PortfolioProject.dbo.NashvilleHousing
)

select * from duprow
where row_num>1
 
------------------------------------------------------------------------------------------------------------------------------------------
-- deleting unused columns

alter table PortfolioProject.dbo.NashvilleHousing
drop column Propertyaddress, Owneraddress
