-- 							Business Questions To Answer
-- Generic Question

-- 1. How many unique cities does the data have?
-- 2. In which city is each branch?

-- Product
-- 1. How many unique product lines does the data have?
-- 2. What is the most common payment method?
-- 3. What is the most selling product line?
-- 4. What is the total revenue by month?
-- 5. What month had the largest COGS?
-- 6. What product line had the largest revenue?
-- 7. What is the city with the largest revenue?
-- 8. What product line had the largest VAT?
-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
-- 10. Which branch sold more products than average product sold?
-- 11. What is the most common product line by gender?
-- 12. What is the average rating of each product line?


-- Sales
-- 1. Number of sales made in each time of the day per weekday
-- 2. Which of the customer types brings the most revenue?
-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
-- 4. Which customer type pays the most in VAT?


-- Customer
-- 1. How many unique customer types does the data have?
-- 2. How many unique payment methods does the data have?
-- 3. What is the most common customer type?
-- 4. Which customer type buys the most?
-- 5. What is the gender of most of the customers?
-- 6. What is the gender distribution per branch?
-- 7. Which time of the day do customers give most ratings?
-- 8. Which time of the day do customers give most ratings per branch?
-- 9. Which day fo the week has the best avg ratings?
-- 10. Which day of the week has the best average ratings per branch?


-- --------------------------------------------------------------------------------------------------------------------------------------------------


Create Database Walmart;

Use Walmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);

-- FEATURE ENGINEERING 

-- 1. time_of_day - ADD NEW COLUMN IN THE TABLE

SELECT time, 
	CASE 
        WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN 'Afternoon'
        ELSE 'Evening' 
	END AS time_of_day
FROM sales;


ALTER TABLE sales 
ADD COLUMN  time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (

	CASE 
        WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN 'Morning'
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN 'Afternoon'
        ELSE 'Evening' 
	END 
);


-- 2. day_name 

SELECT date, 
	DAYNAME(date) day_name
FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);



-- 3. month_name

SELECT date, 
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);


UPDATE sales 
SET month_name = MONTHNAME(date);



-- -----------------------------------------------------------------------------------------------

SELECT * FROM sales;

-- Generic Question

# 1. How many unique cities does the data have?
SELECT  DISTINCT city 
FROM sales;


# 2. In which city is each branch?
SELECT DISTINCT city, branch
FROM sales; 


-- -------------------------------------------------------------------------------------



-- Product

-- 1. How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line)
FROM sales;


-- 2. What is the most common payment method?
SELECT payment_method, COUNT(payment_method) AS Count
FROM sales
GROUP BY payment_method
ORDER BY COUNT(payment_method) DESC;


-- 3. What is the most selling product line?
SELECT product_line, COUNT(product_line) AS Count
FROM sales
GROUP BY product_line
ORDER BY COUNT(product_line) DESC;


-- 4. What is the total revenue by month?
SELECT month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- 5. What month had the largest COGS?
SELECT month_name AS month, -- cogs = Cost of Goods Sold
	SUM(cogs) AS cogs
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- 6. What product line had the largest revenue?
SELECT product_line, 
	SUM(total) AS total_revenue
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- 7. What is the city with the largest revenue?
SELECT city, branch,
	SUM(total) AS total_revenue
FROM sales
GROUP BY 1,2
ORDER BY 2 DESC;



-- 8. What product line had the largest VAT?
SELECT product_line, 
	AVG(vat) AS avg_tax
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT product_line, total, 
	CASE 
		WHEN total > avg_sales THEN 'Good'
        ELSE 'Bad' 
	END AS Performance
FROM (
	SELECT product_line, total, AVG(total) OVER(PARTITION BY product_line) avg_sales
    FROM sales) sales_with_avg;





-- 10. Which branch sold more products than average product sold?
SELECT branch, 
	SUM(quantity) AS qty
FROM sales
GROUP BY 1
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);



-- 11. What is the most common product line by gender?
SELECT gender, product_line, count(gender) AS total_count
FROM sales
GROUP BY 1,2
ORDER BY 3 DESC;



-- 12. What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),1) AS Avg_rating
FROM sales 
GROUP BY 1
ORDER BY 2 DESC;

-- --------------------------------------------------------------------------------------------------------------------------


-- Sales

-- 1. Number of sales made in each time of the day per weekday
SELECT time_of_day, count(*) as Number_of_sales
FROM sales
WHERE day_name = 'Monday'
GROUP BY 1
ORDER BY 2 DESC;


-- 2. Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- 3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
SELECT CITY, avg(vat) AS vat
FROM sales
GROUP BY 1
ORDER BY 2 DESC;


-- 4. Which customer type pays the most in VAT?

SELECT customer_type, avg(vat) AS vat
FROM sales
GROUP BY 1
ORDER BY 2 DESC;





-- ----------------------------------------------------------------------------------------------------------------------------

-- Customer

-- 1. How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM SALES;


-- 2. How many unique payment methods does the data have?
SELECT DISTINCT payment_method
FROM SALES;



-- 3. What is the most common customer type?
SELECT customer_type, COUNT(customer_type)
FROM sales
GROUP BY 1;



-- 4. Which customer type buys the most?
SELECT customer_type, COUNT(customer_type)
FROM sales
GROUP BY 1;


-- 5. What is the gender of most of the customers?
SELECT gender, COUNT(gender)
FROM sales
GROUP BY 1;



-- 6. What is the gender distribution per branch?
SELECT DISTINCT branch,
	SUM(CASE WHEN gender = 'male' THEN 1 ELSE 0 END) AS Male,
    SUM(CASE WHEN gender = 'female' THEN 1 ELSE 0 END) AS Female
FROM sales
GROUP BY 1;


-- 7. Which time of the day do customers give most ratings?
SELECT time_of_day, ROUND(AVG(rating),1)
FROM sales
GROUP BY 1
ORDER BY 2 DESC;



-- 8. Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, ROUND(AVG(rating),1)
FROM sales
GROUP BY 1,2
ORDER BY 1,3 DESC;



-- 9. Which day fo the week has the best avg ratings?

SELECT DISTINCT day_name, ROUND(AVG(rating),1)
FROM sales
GROUP BY 1
ORDER BY 2 DESC;



-- 10. Which day of the week has the best average ratings per branch?
SELECT DISTINCT branch, day_name, ROUND(AVG(rating),2)
FROM sales
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------  END  ---------------------------------------------------------------------------
