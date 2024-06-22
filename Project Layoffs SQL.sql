-- Data Cleaning 

SELECT *  FROM layoffs;

-- 3. Null Values or Blank Values
-- 4. Remove any unneccessary columns

-- Create the staging data for cleaning
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
	SELECT * FROM layoffs;
    
SELECT * FROM layoffs_staging;

-- 1. Remove Duplicates
-- Adding row number for the unique row
WITH duplicate_CTE AS 
(SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
-- Filter the duplicated rows
SELECT * FROM duplicate_CTE WHERE row_num > 1;

-- New Table & Insert the table to remove duplicate values
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

DELETE FROM layoffs_staging2 
WHERE row_num >1;

SELECT * FROM layoffs_staging2 
WHERE row_num >1;

-- Standardizing data

-- 1. Extra Space of the company name
-- Check company name 
SELECT DISTINCT company FROM layoffs_staging2 ORDER BY 1;

SELECT company, (TRIM(company))
FROM layoffs_staging2;

-- Remove the space in text
UPDATE layoffs_staging2 
SET company = trim(company);

-- 2. The different name for the same industry
-- Check indsutry
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY 1;

-- Update Cryto Currency to Crypto
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 2. Comma after the country name

-- Check country
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY 1;

-- Remove the comma
SELECT DISTINCT country, trim(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 3. Change the type of date column from text to date_time

SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

-- Check null industry
SELECT *
FROM layoffs_staging2
WHERE industry is null OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Juul%' ;

UPDATE layoffs_staging2
SET industry = 'Consumer' 
WHERE industry = '' and company = 'Juul';

-- Check null total & percentage laid off 
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off is null
AND percentage_laid_off is null;

SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP column row_num;