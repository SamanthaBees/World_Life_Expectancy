-- World Life Expectancy Project (Data Cleaning)

USE world_life_expectancy
GO

SELECT	*
FROM	world_life_exp;


-- Check for Duplicates in the Dataset

/*
A unique key is created by concatenating the country and year columns to ensure one row per country per year. 
The keys are then counted to identify any duplicates.
*/

SELECT Country, Year,
CONCAT(Country,Year),
COUNT(CONCAT(Country,Year))
FROM world_life_exp
GROUP BY Country, Year, CONCAT(Country,Year)
HAVING COUNT(CONCAT(Country,Year)) > 1;


-- Duplicate Removal Process

/*
This query removes duplicates from the world_life_exp table by assigning a row number to each Country-Year 
combination. Rows with a row number greater than 1 are deleted, ensuring only one entry per country per year.
*/

WITH CTE AS (
    SELECT Row_ID,
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
    FROM world_life_exp
)
DELETE FROM world_life_exp
WHERE Row_ID IN (
    SELECT Row_ID
    FROM CTE
    WHERE Row_Num > 1
);


-- Country Status Validation

-- Checking for Null and Empty Values in the Status Column

SELECT	*
FROM	world_life_exp
WHERE	Status = '';

SELECT	*
FROM	world_life_exp
WHERE	Status IS NULL;

SELECT	DISTINCT(Status)
FROM	world_life_exp
WHERE	Status IS NOT NULL;


/*
This query verifies that each country has a consistent status. For example, it ensures there are no conflicting 
rows where a country like Canada is listed as both "developed" and "developing.
*/
SELECT Country, Status,
CONCAT(Country,Status),
COUNT(DISTINCT(CONCAT(Country,Status)))
FROM world_life_exp
GROUP BY Country, Status, CONCAT(Country,Status)
HAVING COUNT(DISTINCT(CONCAT(Country,Status))) > 1;


-- Fill Null Values in the Status Column

/*
This query updates the Status column in the world_life_exp table, setting it to 'Developing'
or 'Developed'for rows where the current status is NULL.
*/

SELECT	DISTINCT(Country)
FROM	world_life_exp
WHERE	Status = 'Developing';

SELECT	DISTINCT(Country)
FROM	world_life_exp
WHERE	Status = 'Developed';

UPDATE t1
SET t1.Status = 'Developing'
FROM world_life_exp AS t1
JOIN world_life_exp AS t2 ON t1.Country = t2.Country
WHERE t1.Status IS NULL
  AND t2.Status IS NOT NULL
  AND t2.Status = 'Developing';

UPDATE t1
SET t1.Status = 'Developed'
FROM world_life_exp AS t1
JOIN world_life_exp AS t2 ON t1.Country = t2.Country
WHERE t1.Status IS NULL
  AND t2.Status IS NOT NULL
  AND t2.Status = 'Developed';


-- -- Country Life_expectancy Validation

-- Check for Null and Empty Values in the Life_expectancy Column

SELECT	*
FROM	world_life_exp
WHERE	Life_expectancy = '';

SELECT	*
FROM	world_life_exp
WHERE	Life_expectancy IS NULL;

-- Update Life Expectancy Using Neighboring Years

/*
This query updates the Life_expectancy column in the world_life_exp table for rows where 
the current value is NULL. It calculates the new value as the average of life expectancy 
from the previous and next years, using LEFT JOIN to access these neighboring records. 
If either neighboring value is missing, it adjusts the average calculation accordingly 
to avoid division by zero.
*/

UPDATE t1
SET t1.Life_expectancy = 
    (ISNULL(t2.Life_expectancy, 0) + ISNULL(t3.Life_expectancy, 0)) / 
    (CASE 
        WHEN t2.Life_expectancy IS NOT NULL AND t3.Life_expectancy IS NOT NULL THEN 2
        WHEN t2.Life_expectancy IS NOT NULL OR t3.Life_expectancy IS NOT NULL THEN 1
        ELSE NULL
    END)
FROM world_life_exp AS t1
LEFT JOIN world_life_exp AS t2 
    ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
LEFT JOIN world_life_exp AS t3 
    ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
WHERE t1.Life_expectancy IS NULL;


-- Update Float Numbers to One Decimal Places

UPDATE world_life_exp
SET Life_expectancy = ROUND(Life_expectancy, 1)
WHERE Life_expectancy IS NOT NULL; 

UPDATE world_life_exp
SET percentage_expenditure = ROUND(percentage_expenditure, 1)
WHERE percentage_expenditure IS NOT NULL; 

UPDATE world_life_exp
SET BMI = ROUND(BMI, 1)
WHERE BMI IS NOT NULL; 

UPDATE world_life_exp
SET HIV_AIDS = ROUND(HIV_AIDS, 1)
WHERE HIV_AIDS IS NOT NULL; 

UPDATE world_life_exp
SET thinness_1_19_years = ROUND(thinness_1_19_years, 1)
WHERE thinness_1_19_years IS NOT NULL; 

UPDATE world_life_exp
SET thinness_5_9_years = ROUND(thinness_5_9_years, 1)
WHERE thinness_5_9_years IS NOT NULL; 

UPDATE world_life_exp
SET Schooling = ROUND(Schooling, 1)
WHERE Schooling IS NOT NULL; 