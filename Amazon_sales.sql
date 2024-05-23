-- AMAZON SALES DATA ANALYSIS
-- As a pre-requisite, cleaned some of the data in the excel i.e. renamed the column names for easy use 
-- Step -1 Created a database named amazon_db, and loaded the amazon file into the table
-- now using the amazon schema for Querying
USE amazon_db; 
show tables; -- shows the tables present in the schema

SELECT * FROM amazon; -- gives all the rows and columns data

DESCRIBE amazon; -- gives the data types of all the columns
-- ----------------------------------------------------------------------------------------------------------------------------
-- The date and time are text format, converting them to respective data types

ALTER TABLE amazon
ADD COLUMN sales_Date DATE;

UPDATE amazon
SET sales_Date= STR_TO_DATE (Sale_Date, '%d-%m-%Y');

-- dropping the old date column
alter table amazon
drop column Sale_Date;


ALTER TABLE amazon
MODIFY COLUMN Sale_Time TIME;

describe amazon;
-- ----------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------FEATURE ENGINEERING----------------------------------------------------------
-- As part of feature engineering, adding new columns to the existing table
-- adding a new column named dayname, Monthname
ALTER TABLE amazon
ADD COLUMN day_name varchar(50),
ADD COLUMN month_name varchar(50),
ADD COLUMN timeofday varchar(50);

-- extracting and updating the values into the respective columns
UPDATE amazon
SET day_name=dayname(Sales_Date);

UPDATE amazon
SET month_name=monthname(Sales_Date);

UPDATE amazon
SET timeofday = 
				( CASE 	
						WHEN Sale_Time BETWEEN '10:00:00' AND '12:00:00' THEN 'MORNING'
                        WHEN Sale_Time BETWEEN '12:01:00' AND '16:00:00' THEN 'AFTERNOON'
                        ELSE 'EVENING'
					END );
                        
-- ------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------Q&A------------------------------------------------------------------

-- 1.What is the count of distinct cities in the dataset?
SELECT DISTINCT CITY FROM amazon;
 -- here the distinct keywork helps in retrieving the unique values from the city column
 
-- ------------------------------------------------------------------------------------------------------------------------

-- 2.For each branch, what is the corresponding city?
SELECT DISTINCT Branch,City from amazon;
-- 
-- -------------------------------------------------------------------------------------------------------------------------

-- 3.What is the count of distinct product lines in the dataset?
SELECT DISTINCT Product_line from amazon;
-- gives the unique entries of product line

SELECT COUNT(DISTINCT Product_line) as count_of_productline from amazon;
-- gives the count of unique entries of product line

-- --------------------------------------------------------------------------------------------------------------------------

-- 4.Which payment method occurs most frequently?
SELECT Payment, count(*) as payment_frequency from amazon
group by Payment
Order by Payment_frequency DESC;
-- from the result through 'Ewallet' most of the payments were being done
-- here in the query, count(*) retrieves the count of rows, all group by the payment types
-- Order by, retrieves the column in a specified order either by ascending or descending

-- ----------------------------------------------------------------------------------------------------------------------------
  
-- 5.Which product line has the highest sales? 
SELECT Product_line, ROUND(SUM(Total),2) as Total_sales from amazon 
Group by Product_line
Order by Total_sales DESC;
-- from the result, 'Food and beverages' has the highest sales
-- Here, ROUND keyword is used to get the values rounded to two positions after the decimal
  
-- --------------------------------------------------------------------------------------------------------------------------

-- 6.How much revenue is generated each month?
SELECT month_name, SUM(Total) as monthly_sale from amazon 
Group by month_name
Order by monthly_sale DESC ;
-- From the result, in the month of 'January' the sale are high

-- --------------------------------------------------------------------------------------------------------------------------

-- 7.In which month did the cost of goods sold reach its peak?
SELECT month_name, SUM(cogs) AS Total_cogs from amazon
Group by month_name
Order by Total_cogs DESC
LIMIT 1;
-- In the month of 'January' COGS reaches it's peal
-- LIMIT keyword is used to limit the number of rows to be retrieved in the result

-- -------------------------------------------------------------------------------------------------------------------------

-- 8.Which product line generated the highest revenue?
SELECT Product_line, ROUND(SUM(Total),2) as revenue from amazon 
Group by Product_line 
Order by revenue DESC;
-- Food and beverages have the highest revenue

-- --------------------------------------------------------------------------------------------------------------------------
-- 9. In which city was the highest revenue recorded?
SELECT City,ROUND(SUM(Total),2) as Total_revenue from amazon
Group by City
Order by Total_revenue Desc;
-- Naypyitaw has the highest revenue

-- ----------------------------------------------------------------------------------------------------------------------------
-- 10. Which product line incurred the highest Value Added Tax?
-- VAT is the % applied on the COGS i.e. tax_5%
SELECT Product_line, AVG(VAT) as high_VAT from amazon
Group by Product_line
Order by high_VAT DESC
Limit 1;
-- Home and lifestyle product has the high VAT

-- ----------------------------------------------------------------------------------------------------------------------------

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

SELECT 
	AVG(quantity) AS avg_qnty
FROM amazon ;


SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 5.51 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM amazon 
GROUP BY product_line;

-- ---------------------------------------------------------------------------------------------------------------------

-- 12.Identify the branch that exceeded the average number of products sold.

SELECT branch, SUM(quantity) AS qnty FROM amazon
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM amazon);
-- -----------------------------------------------------------------------------------------------------------------------
-- 13.Which product line is most frequently associated with each gender?
SELECT Product_line,Gender,count(Gender) as total_count from amazon
Group by Product_line,Gender
Order by total_count DESC;
-- Higher number of Female buying the most of Fashion accessories and foood and beverages

-- ----------------------------------------------------------------------------------------------------------------------
 
 -- 14. Calculate the average rating for each product line.
 SELECT Product_line,ROUND(avg(Rating),2) as avg_rating from amazon
 Group by Product_line
 Order by avg_rating desc ;
-- Food and beverages got high rating 

-- ------------------------------------------------------------------------------------------------------------------------

-- 15.Count the sales occurrences for each time of day on every weekday.
SELECT day_name,timeofday,count(*) as total_sales from amazon 
Group by day_name,timeofday
Order by total_sales Desc;
-- gives the result for all the week days sales grouped by days and time of day
-- Most of the sales are happening on saturday evening, and least sales are happening on monday morning

-- to know the count of sales on a particular weekday
SELECT timeofday, COUNT(*) AS total_sales FROM amazon
WHERE day_name = "Sunday"
GROUP BY timeofday 
ORDER BY total_sales DESC;
-- gives the sale details on sunday

--  ------------------------------------------------------------------------------------------------------------------

-- 16.Identify the customer type contributing the highest revenue.
SELECT Customer_type,round(sum(Total),2) as Revenue from amazon 
Group by Customer_type
Order by Revenue DESC;
-- Member are contributing more than normal customers

-- ----------------------------------------------------------------------------------------------------------------------

-- 17.Determine the city with the highest VAT percentage.
SELECT City, round(avg(VAT),2) as high_VAT from amazon
group by city
Order by high_VAT DESC;

-- ----------------------------------------------------------------------------------------------------------------------
-- 18 Identify the customer type with the highest VAT payments.
SELECT Customer_type,round(AVG(VAT),2) as high_vat from amazon 
Group by Customer_type
Order by high_vat DESC;


-- -------------------------------------------------------------------------------------------------------------------------

-- 19. What is the count of distinct customer types in the dataset?
SELECT count(DISTINCT Customer_type) as distinct_customers from amazon;
-- there are two kinds of customers available
SELECT DISTINCT Customer_type from amazon;
-- retrieves the two types of customers 
-- --------------------------------------------------------------------------------------------------------------------------

-- 20 What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT Payment) as payment_methods from amazon;
-- gives the count of unique payment methods
SELECT DISTINCT Payment from amazon;
-- gives the different types of payment options available

-- ---------------------------------------------------------------------------------------------------------------------------

-- 21.Which customer type occurs most frequently?
SELECT Customer_type,count(Customer_type) as customer_count from amazon 
Group by Customer_type
Order by customer_count DESC;

-- ----------------------------------------------------------------------------------------------------------------------------

-- 22.Identify the customer type with the highest purchase frequency.
SELECT Customer_type,count(*) as purchasing_frequency from amazon
Group by Customer_type
Order by purchasing_frequency DESC;

-- ---------------------------------------------------------------------------------------------------------------------

-- 23.Determine the predominant gender among customers.
SELECT Gender,count(Gender) as total_customers from amazon
Group by Gender
Order by total_customers DESC;
-- Female customes buys more

-- ------------------------------------------------------------------------------------------------------------------------

-- 24.Examine the distribution of genders within each branch
SELECT Branch,Gender, count(Gender) as total_count from amazon 
Group by Branch,Gender
Order by Branch;
-- gives the number of male and female in each branch

-- -------------------------------------------------------------------------------------------------------------------

-- 25.Identify the time of day when customers provide the most ratings
SELECT timeofday,ROUND(avg(rating),2) as Ratings from amazon
Group by timeofday
Order by Ratings DESC;
-- Almost every time similar count of ratings are provided

-- ---------------------------------------------------------------------------------------------------------------------

-- 26. Determine the time of day with the highest customer ratings for each branch.
SELECT Branch,timeofday, avg(rating) as avg_ratings from amazon
Group by Branch, timeofday
Order by Branch,avg_ratings desc;

-- -------------------------------------------------------------------------------------------------------------------

-- 27 Identify the day of the week with the highest average ratings.
SELECT Day_name, ROUND(avg(rating),2) as high_ratings from amazon 
Group by Day_name
Order by high_ratings DESC;
-- On Monday most of the ratings were provided , followed by Friday and sunday with less differences

-- ---------------------------------------------------------------------------------------------------------------------
-- 28 Determine the day of the week with the highest average ratings for each branch.
SELECT Branch, Day_name, ROUND(avg(rating),2) as high_ratings from amazon 
Group by Branch,Day_name
Order by Branch,high_ratings DESC;
-- for Branch A &C- on friday high ratings are provided
-- for Branch B-on monday high ratings are provided
