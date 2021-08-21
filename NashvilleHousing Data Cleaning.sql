--Creating nashville_housing table to match nashville_housing.csv columns

DROP TABLE IF EXISTS nashville_housing;
CREATE TABLE nashville_housing(
	UniqueID INT,
	ParcelID VARCHAR(250),
	LandUse VARCHAR(250),
	PropertyAddress VARCHAR(250),
	SaleDate VARCHAR(250),
	SalePrice VARCHAR(250),
	LegalReference VARCHAR(250),
	SoldAsVacant VARCHAR(50),
	OwnerName VARCHAR(250),
	OwnerAddress VARCHAR(250),
	Acreage NUMERIC(5,2),
	TaxDistrict VARCHAR(250),
	LandValue INT,
	BuildingValue INT,
	TotalValue INT,
	YearBuilt INT,
	Bedrooms SMALLINT,
	FullBath SMALLINT,
	HalfBath SMALLINT
);

--Importing nashville_housing data from nashville_housing.csv

COPY nashville_housing
FROM 'C:\Data\nashville_housing.csv'
DELIMITER ','
CSV Header;

--Selecting all the data

SELECT * FROM nashville_housing;

--Changing date format in SaleDate column

ALTER TABLE nashville_housing
ALTER COLUMN saledate TYPE date
USING saledate::date;

--Updating PropertyAddress column to remove NULL values

SELECT nva.parcelid, nva.propertyaddress, nvb.parcelid, nvb.propertyaddress,
COALESCE(nva.propertyaddress, nvb.propertyaddress)
FROM nashville_housing nva
JOIN nashville_housing nvb
ON nva.parcelid = nvb.parcelid
AND nva.uniqueid <> nvb.uniqueid
WHERE nva.propertyaddress IS NULL;

UPDATE nashville_housing
SET propertyaddress = COALESCE(nva.propertyaddress, nvb.propertyaddress)
FROM nashville_housing nva
JOIN nashville_housing nvb
ON nva.parcelid = nvb.parcelid
AND nva.uniqueid <> nvb.uniqueid
WHERE nva.propertyaddress IS NULL;

--PropertyAddress into Address and City

ALTER TABLE nashville_housing
ADD COLUMN property_address VARCHAR(250),
ADD COLUMN property_city VARCHAR(250);

UPDATE nashville_housing
SET property_address = SUBSTRING(propertyaddress, 1, POSITION(',' IN propertyaddress)-1),
property_city = SUBSTRING(propertyaddress, POSITION(',' IN propertyaddress)+1, LENGTH(propertyaddress));

--OwnerAddress into Address, City, and State

ALTER TABLE nashville_housing
ADD COLUMN owner_address VARCHAR(250),
ADD COLUMN owner_city VARCHAR(250),
ADD COLUMN owner_state VARCHAR(250);

UPDATE nashville_housing
SET owner_address = SPLIT_PART(owneraddress, ',', 1),
owner_city = SPLIT_PART(owneraddress, ',', 2),
owner_state = SPLIT_PART(owneraddress, ',', 3);

--Dropping PropertyAddress and OwnerAddress original columns

ALTER TABLE nashville_housing
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress;

--Updating 'Y' and 'N' in SoldAsVacant column to 'Yes' and 'No'

UPDATE nashville_housing
SET soldasvacant =
CASE
	WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END;
	
--Viewing Duplicate Data

SELECT *
FROM
	(SELECT parcelid, ROW_NUMBER() OVER(PARTITION BY
	parcelid, propertyaddress, saleprice, saledate, legalreference) row_num
	FROM nashville_housing) row_numb
WHERE row_num > 1;

--Deleting Duplicate Data

WITH cte_row_num AS
	(
	SELECT parcelid, ROW_NUMBER() OVER(PARTITION BY
	parcelid, propertyaddress, saleprice, saledate, legalreference) row_num
	FROM nashville_housing
	)
DELETE FROM nashville_housing
WHERE parcelid IN (SELECT parcelid FROM cte_row_num WHERE row_num > 1)
