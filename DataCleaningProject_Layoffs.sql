# Data Cleaning
# 1. Remove Duplicates
# 2. Standardize the data(Spellings,Format)
# 3. Null Values or Blank Values
# 4. Remove rows or columns unnecessary

select * from layoffs_staging;

create table layoffs_staging
like layoffs;

insert into layoffs_staging
select * from layoffs;

# 1. Remove Duplicates

with duplicate_cte as
(
select *, row_number() over(partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte
where row_num>1;

# Delete or update cannot be performed on CTE. So we create a table with the extra row row number and tehn delete 

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

select * from layoffs_staging2;

insert into layoffs_staging2
select *, row_number() over(partition by company,location,industry,total_laid_off,
percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

select * from layoffs_staging2
where row_num>1;

delete from layoffs_staging2
where row_num>1;

# 2.Standardize data

select * from layoffs_staging2;
# Trims

select distinct company, trim(company) from layoffs_staging2;
update layoffs_staging2
set company= trim(company);


select distinct industry from layoffs_staging2
order by 1;

select * from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select * from layoffs_staging2;
select distinct location
from layoffs_staging2;
select distinct country
from layoffs_staging2 order by 1;
# there is a period after United States - remove it
select distinct country from layoffs_staging2
where country like 'United States%';

select distinct country, trim(trailing '.' from country) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select * from layoffs_staging2;
# Date is a text column instead of a date format - lets change the format
# You cannot chgange the datatype to date directly. You can only change the datattype after changing to the date format

select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;


update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;

# 3. Null and Blank Value

select * from layoffs_staging2
order by industry;

select * from layoffs_staging2
where industry = '' or industry is null;

select * from layoffs_staging2
where company = 'Carvana';
#Carvana, Juul, Airbnb

select *
from layoffs_staging2 t1
join layoffs_staging2 t2employee_demographics
on t1.company= t2.company
and t1.location = t2.location
where (t1.industry is null or t1.industry='') and (t2.industry is not null and t2.industry != '');

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company= t2.company
and t1.location = t2.location
set t1.industry = t2.industry
where (t1.industry is null or t1.industry='') and (t2.industry is not null and t2.industry != '');



select * from layoffs_staging2
order by industry;

select * from layoffs_staging2
where total_laid_off is null; 

select * from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null; 

delete from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null; 

#4. remove column or row

alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;


select * from employee_demographics;
select * from employee_salary;
select * from parks_departments;

select * from employee_demographics ed
join employee_salary es
on ed.employee_id=es.employee_id
# join parks_departments pd
# on es.dept_id=pd.department_id
# where pd.department_id=1;
where es.dept_id=1;

select * from employee_demographics
where employee_id in (select employee_id from employee_salary where dept_id=1)



