-- EDA

select *
from layoffs_staging2

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc

-- change the date(text/str) data type to DATE
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')

select min(`date`), max(`date`)
from layoffs_staging2

-- Checking what year has the most layoffs
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc

-- Checking which stage company got the most layoffs
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc

-- Rolling total

select substring(`date`, 1,7) as `mon`, sum(total_laid_off) as laid
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `mon`
order by 1 asc

with Rolling_Total as
(
select substring(`date`, 1,7) as `mon`, sum(total_laid_off) as laid
from layoffs_staging2
where substring(`date`, 1,7) is not null
group by `mon`
order by 1 asc
)
select `mon`, laid, sum(laid) over (order by `mon`) as rolling 
from Rolling_Total

-- breaking it by the year and company

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by company 

select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
order by 3 desc


with company_year (company, years, laids) as
(
select company, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_rank as
(
select *, 
dense_rank() over (partition by years order by laids desc) as total
from company_year
where years is not null
)
select *
from company_year_rank
where total <= 5