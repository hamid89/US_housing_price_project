-- 1) Create a database called house_price_regression
CREATE DATABASE house_price_regression;

use house_price_regression;
-----------------------------------------------------

-- 2) Create a table house_price_data with the same columns as given in the csv file. Please make sure you use the correct data types for the columns.

drop table if exists house_price_data;

CREATE TABLE house_price_data 
(
  `id` int(11) UNIQUE NOT NULL,
  `date` date DEFAULT NULL,
  `bedrooms` int(4) DEFAULT NULL,
  `bathrooms` float DEFAULT NULL,
  `sqft_living` float DEFAULT NULL,
  `sqft_lot` float DEFAULT NULL,
  `floors` int(4) DEFAULT NULL,
  `waterfront` int(4) DEFAULT NULL,
  `view` int(4) DEFAULT NULL,
  `condition` int(4) DEFAULT NULL,
  `grade` int(4) DEFAULT NULL,
  `sqft_above` float DEFAULT NULL,
  `sqft_basement` float DEFAULT NULL,
  `yr_built` int(11) DEFAULT NULL,
  `yr_renovated` int(11) DEFAULT NULL,
  `zip_code` int(11) DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `lon` float DEFAULT NULL,
  `sqft_living15` float DEFAULT NULL,
  `sqft_lot15` float DEFAULT NULL,
  `price` float DEFAULT NULL,
  CONSTRAINT PRIMARY KEY (`id`) 
);

---------------------------------------------------

-- 3) Import the data from the csv file into the table.

load data local infile '/Users/siljaloik/Desktop/IronHack/Week5/regression_data_clean_lf.csv'
into table house_price_data
fields terminated BY ',';

---------------------------------------------------

-- 4) Select all the data from table house_price_data to check if the data was imported correctly

select * from house_price_data;

---------------------------------------------------

-- 5) Use the alter table command to drop the column date from the database, as we would not use it in the analysis with SQL. Select all the data from the table to verify if the command worked. Limit your returned results to 10.

alter table house_price_data
drop column date;

---------------------------------------------------

-- 6) Use sql query to find how many rows of data you have.

select count(*) from house_price_data;

---------------------------------------------------

-- 7) Now we will try to find the unique values in some of the categorical columns: 
--  What are the unique values in the column bedrooms?
-- What are the unique values in the column bathrooms?
-- What are the unique values in the column floors?
-- What are the unique values in the column condition?
-- What are the unique values in the column grade?

select distinct(bedrooms) AS unique_values_bedrooms
from house_price_data
order by unique_values_bedrooms;

select distinct(bathrooms) AS unique_values_bathrooms
from house_price_data
order by unique_values_bathrooms;

select distinct(floors) AS floors
from house_price_data
order by floors;

select distinct(house_price_data.condition) AS unique_values_condition
from house_price_data
order by unique_values_condition;

select distinct(grade) AS grade
from house_price_data
order by grade;

---------------------------------------------------

-- 8) Arrange the data in a decreasing order by the price of the house. Return only the IDs of the top 10 most expensive houses in your data.

select id 
from house_price_data
order by price desc
limit 10;

---------------------------------------------------

-- 9) What is the average price of all the properties in your data?

select AVG(price) 
from house_price_data;

---------------------------------------------------

-- 10) 
-- What is the average price of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the prices. Use an alias to change the name of the second columns  

select bedrooms, round(AVG(price),2) AS avg_price_per_bedrooms
from house_price_data
group by bedrooms
order by bedrooms;

--  What is the average sqft_living of the houses grouped by bedrooms? The returned result should have only two columns, bedrooms and Average of the sqft_living. Use an alias to change the name of the second columns

from house_price_data
group by bedrooms
order by bedrooms;  

--  What is the average price of the houses with a waterfront and without a waterfront? The returned result should have only two columns, waterfront and Average of the prices. Use an alias to change the name of the second column.

select waterfront, round(AVG(price),2) AS avg_price_with_waterfront
from house_price_data
where waterfront = 1
group by waterfront

union all

select waterfront, round(AVG(price),2) AS avg_price_without_waterfront
from house_price_data
where waterfront = 0
group by waterfront;

-- Is there any correlation between the columns condition and grade? You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. Visually check if there is a positive correlation or negative correlation or no correlation between the variables.

# 1) avg condition per each grade
select round(AVG(house_price_data.condition),2) AS avg_condition, grade
from house_price_data
group by grade
order by grade;


# 2) avg grade per each condition
select round(AVG(grade),2) AS avg_grade, house_price_data.condition
from house_price_data
group by house_price_data.condition
order by house_price_data.condition; 

---------------------------------------------------

-- 11) 

-- One of the customers is only interested in the following houses: 
-- Number of bedrooms either 3 or 4
-- Bathrooms more than 3
-- One Floor
-- No waterfront
-- Condition should be 3 at least
-- Grade should be 5 at least

select *
from house_price_data
where 
	bedrooms in (3,4)
	and bathrooms > 3
	and floors = 1
	and waterfront = 0
	and house_price_data.condition >= 3
	and grade >= 5
order by price asc;

---------------------------------------------------

-- 12) Your manager wants to find out the list of properties whose prices are twice more than the average of all the properties in the database. Write a query to show them the list of such properties. You might need to use a sub query for this problem.

select *
from house_price_data
where price >= ((select round(AVG(price),2) AS avg_price
from house_price_data)*2)
order by price;

---------------------------------------------------

-- 13) Since this is something that the senior management is regularly interested in, create a view of the same query.

create view property_list as
select *
from house_price_data
where price >= ((select round(AVG(price),2) AS avg_price
from house_price_data)*2)
order by price;

select * from property_list;

---------------------------------------------------

-- 14) Most customers are interested in properties with three or four bedrooms. What is the difference in average prices of the properties with three and four bedrooms?

select 
	(select round(AVG(price)) as 3_bedrooms_avg
	from house_price_data
	where bedrooms in (3)
	group by 3_bedrooms_avg) -

	(select round(AVG(price)) as 4_bedrooms_avg
	from house_price_data 
	where bedrooms in (4)
	group by 4_bedrooms_avg) AS difference_between_avgs

from house_price_data;

with cte1 as (

	select round(AVG(price)) as 3_bedrooms_avg
	from house_price_data
	where bedrooms in (3)
	group by 3_bedrooms_avg)

select round(AVG(price)) as 4_bedrooms_avg
	from house_price_data 
	where bedrooms in (4)
	group by 4_bedrooms_avg) AS difference_between_avgs

from house_price_data;

---------------------------------------------------

-- 15) What are the different locations where properties are available in your database? (distinct zip codes)

select distinct(zip_code) AS zip_code
from house_price_data;

---------------------------------------------------

-- 16) Show the list of all the properties that were renovated.

select *
from house_price_data
where yr_renovated <> 0
order by yr_renovated desc;

---------------------------------------------------

-- 17) Provide the details of the property that is the 11th most expensive property in your database.

select *
from house_price_data
order by price desc
limit 1 offset 10; 