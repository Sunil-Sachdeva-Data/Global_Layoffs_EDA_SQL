select *
from layoffs
-- DATA CLEANING
-- Creating a temp table enviorment, so that we don't directly change the raw data.

create table layoffs_staging
like layoffs

insert layoffs_staging
select *
from layoffs

select * from layoffs_staging

-- Removing duplicates

select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging

WITH duplicate_cte AS
(
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1 

-- checking the duplicate rows.
select * 
from layoffs_staging
where company = 'hibob' 

-- We cannot directly remove the duplicate values in MYSQL
-- We cannot use update commands in the CTE.
-- So we will create a new table 

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2

insert into layoffs_staging2
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging

delete
from layoffs_staging2
where row_num > 1

select *
from layoffs_staging2
where row_num > 1

-- Standardize Data
-- 1. checking and removing white spaces from either side

select distinct(company)
from layoffs_staging2

select company, trim(company)
from layoffs_staging2

update layoffs_staging2
set company = trim(company)

-- 2. Chainging the same fields to one. (edutech, edtech, education tech etc to Edtech)

select distinct(industry)
from layoffs_staging2
order by 1;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

Update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%'

-- Handling null and blank values

select *
from layoffs_staging2
where industry is null 
or industry = ''

select *
from layoffs_staging2
where company = 'Airbnb'

select *
from layoffs_staging2 as t1
join layoffs_staging2 as t2
	on t1.company=t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null

-- changing blank values to null so that we can populate the same values
update layoffs_staging2
set industry = null
where industry = ''

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company =  t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

select *
from layoffs_staging2
where industry is null

-- Removing the row_num column that we created at the starting
-- its just using extra space and have no use

alter table layoffs_staging2
drop column row_num

select *
from layoffs_staging2




