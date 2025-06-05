-- World Life Expectancy Exploratory Data Analysis

SELECT	*
FROM	world_life_exp;

-- Average World Life Expectancy Over the Years

/*
This query calculates the average life expectancy across all countries for each year.
It excludes any records where life expectancy is zero, then groups the data by year 
and orders the results chronologically.
*/

SELECT	Year, ROUND(AVG(Life_expectancy),2) AS Avg_Life_exp
FROM	world_life_exp
WHERE	Life_expectancy <> 0
GROUP BY	Year
ORDER BY	Year;

-- Life Expectancy Growth Over 15 Years by Country

/*
This query retrieves the minimum and maximum life expectancy for each country, 
calculating the increase in life expectancy over a 15-year period. It excludes records 
where life expectancy is zero and groups the data by country, ordering the results by 
the largest life expectancy increase in descending order.
*/

SELECT	Country, 
MIN(Life_expectancy) AS Max_Life_exp, 
MAX(Life_expectancy) AS Min_Life_exp,
(MAX(Life_expectancy) - MIN(Life_expectancy)) AS Life_Increase_15y
FROM	world_life_exp
GROUP BY Country
HAVING	MIN(Life_expectancy) <> 0
AND		MAX(Life_expectancy) <> 0
ORDER BY Life_Increase_15y DESC;

-- Exploring Potential Correlation Between Life Expectancy and GDP

/*
This query calculates the average life expectancy and GDP for each country. 
It filters out countries with zero values for either metric and orders the results by average GDP 
in descending order, allowing for a visual inspection of any potential correlation between 
life expectancy and GDP across countries.
*/

SELECT	Country,ROUND(AVG(Life_expectancy),1)as Avg_Life_exp, ROUND(AVG(GDP),1) as Avg_GDP
FROM	world_life_exp
GROUP BY Country
HAVING	ROUND(AVG(Life_expectancy),1) > 0
AND		ROUND(AVG(GDP),1) > 0
ORDER BY Avg_GDP DESC;

-- Categorizing Countries by High and Low GDP with Life Expectancy Comparison.

/*
This query divides countries into two categories based on GDP: high GDP (≥ 1500) 
and low GDP (≤ 1500), based on a subjective threshold. It calculates the number of 
countries in each category and the average life expectancy within each group, providing 
insight into the relationship between GDP level and life expectancy.
*/

SELECT
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN Life_expectancy ELSE NULL END) High_GDP_Life_exp,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN Life_expectancy ELSE NULL END) Low_GDP_Life_exp
FROM	world_life_exp;


-- Life Expectancy by Country Status

/*
This query groups countries by their development status (e.g., "Developing," "Developed") 
and calculates the number of distinct countries in each category, as well as the average 
life expectancy. This provides insight into how life expectancy varies across 
different country statuses.
*/

SELECT	Status, COUNT(DISTINCT(Country)) AS No_Countries, ROUND(AVG(Life_expectancy),1) AS Avg_Life_exp
FROM	world_life_exp
GROUP BY Status;


-- Exploring Potential Correlation Between Life Expectancy and BMI

SELECT	Country,ROUND(AVG(Life_expectancy),1)as Avg_Life_exp, ROUND(AVG(BMI),1) as Avg_BMI
FROM	world_life_exp
GROUP BY Country
HAVING	ROUND(AVG(Life_expectancy),1) > 0
AND		ROUND(AVG(BMI),1) > 0
ORDER BY Avg_BMI ASC;

-- Tracking Rolling Adult Mortality Over Time for Canada

/*
This query retrieves the life expectancy and adult mortality rates for Canada, 
while calculating a rolling total of adult mortality over the years. The rolling total 
is accumulated year by year, allowing for a time-based analysis of how adult mortality 
trends over time within the country
*/

SELECT	Country,
Year,
Life_expectancy,
Adult_Mortality,
SUM(Adult_Mortality) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM	world_life_exp
WHERE	Country = 'Canada';

