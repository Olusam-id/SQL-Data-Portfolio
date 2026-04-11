# Nashville Housing Data Cleaning | SQL Portfolio Project

## Nashville Housing Data Cleaning with SQL  
**Data Portfolio Project | Microsoft SQL Server (T-SQL) | 2024**

---

## 1. Project Overview

This project demonstrates end-to-end data cleaning techniques applied to a real-world property dataset — the Nashville Housing dataset — using Microsoft SQL Server (T-SQL).

---

## 2. Dataset Overview

### Key Columns

| Column | Data Type | Description |
|--------|----------|-------------|
| UniqueID | INT | Primary identifier |
| ParcelID | VARCHAR | Land parcel identifier |
| PropertyAddress | VARCHAR | Property address |
| OwnerAddress | VARCHAR | Owner address |
| SaleDate | DATETIME/DATE | Sale date |
| LegalReference | VARCHAR | Legal reference |
| SoldAsVacant | VARCHAR | Vacancy flag |

---

## 3. Data Cleaning Steps

### 3.1 Standardise Date Format

```sql
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate DATE;
```

---

### 3.2 Populate Missing Property Addresses

```sql
UPDATE h
SET PropertyAddress = ISNULL(h.PropertyAddress, r.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing h
LEFT JOIN PortfolioProject.dbo.NashvilleHousing r
ON h.ParcelID = r.ParcelID
WHERE h.PropertyAddress IS NULL;
```

---

### 3.3 Split Property Address

```sql
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD streetAddress VARCHAR(255), city VARCHAR(100);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET streetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
```

---

### 3.4 Split Owner Address

```sql
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerStreetAddress VARCHAR(255),
    OwnerCity VARCHAR(100),
    OwnerState VARCHAR(50);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
```

---

### 3.5 Standardise SoldAsVacant

```sql
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant END;
```

---

### 3.6 Remove Duplicates

```sql
WITH RowNumCTE AS (
  SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
    ORDER BY SaleDate DESC
  ) AS rn
  FROM PortfolioProject.dbo.NashvilleHousing
)
DELETE FROM RowNumCTE WHERE rn > 1;
```

---

### 3.7 Remove Redundant Columns

```sql
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress;
```

---

## 4. SQL Techniques Demonstrated

- CONVERT and ALTER COLUMN  
- Self-Join with ISNULL  
- SUBSTRING and CHARINDEX  
- PARSENAME and REPLACE  
- CASE expressions  
- ROW_NUMBER window function  
- CTE-based DELETE  
- ALTER TABLE DROP COLUMN  

---

## 5. Before & After Summary

| Issue | Before | After |
|------|--------|-------|
| SaleDate | DATETIME | DATE |
| Null addresses | Present | Resolved |
| Address format | Combined | Split |
| SoldAsVacant | Y/N/Yes/No | Yes/No |
| Duplicates | Present | Removed |

---

## 6. Key Skills Showcased

- Data cleaning & transformation  
- SQL querying & optimization  
- Schema normalization  
- Data quality auditing  

---

## 7. Tools & Environment

| Tool | Purpose |
|------|--------|
| SQL Server | Database |
| T-SQL | Querying |
| SSMS | Development |
| Dataset | Source data |

---

## 8. Conclusion

This project demonstrates a structured approach to data cleaning using SQL, transforming raw housing data into an analysis-ready dataset suitable for downstream analytics and reporting.

---

*Data Portfolio*
