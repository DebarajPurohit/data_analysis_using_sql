/* Create The Table */
CREATE TABLE IF NOT EXISTS store (
Row_ID SERIAL,
Order_ID CHAR(25),
Order_Date DATE,
Ship_Date DATE,
Ship_Mode VARCHAR(50),
Customer_ID CHAR(25),
Customer_Name VARCHAR(75),
Segment VARCHAR(25),
Country VARCHAR(50),
City VARCHAR(50),
States VARCHAR(50),
Postal_Code INT,
Region VARCHAR(12),
Product_ID VARCHAR(75),
Category VARCHAR(25),
Sub_Category VARCHAR(25),
Product_Name VARCHAR(255),
Sales FLOAT,
Quantity INT,
Discount FLOAT,
Profit FLOAT,
Discount_amount FLOAT,
Years INT,
Customer_Duration VARCHAR(50),
Returned_Items VARCHAR(50),
Return_Reason VARCHAR(255)
) 


/* checking the raw Table */
SELECT * FROM store


/* Importing csv file */
SET client_encoding = 'ISO_8859_5';
COPY store(Row_ID,Order_ID,Order_Date,Ship_Date,Ship_Mode,Customer_ID,Customer_Name,Segment,Country,City,States,Postal_Code,Region,Product_ID,Category,Sub_Category,Product_Name,Sales,Quantity,Discount,Profit,Discount_Amount,Years,Customer_Duration,Returned_Items,Return_Reason)
FROM 'C:\Dev\Learnings\Data Science\AlmaBetter\Chapters\SQL files\Store.csv'
DELIMITER ','
CSV HEADER;

/* checking the raw Table */
SELECT * FROM store


-- Database Size
select pg_size_pretty(pg_database_size('Data Analysis'));
-- Table Size
select pg_size_pretty(pg_relation_size('store'))
/* row count of data */
select count(*) as row_count from store
/* column count of data */
select count(*) as column_count 
from information_schema.columns
where table_name = 'store';
/* Check Dataset Information */
select * from information_schema.columns
where table_name = 'store';
/*  get column names of store data */
select column_name from information_schema.columns
where table_name = 'store';
/* get column names with data type of store data */
select column_name, data_type from information_schema.columns
where table_name = 'store';
/* checking null values of store data */
select * from store
where (select column_name 
	   from information_schema.coLUmns
	  where table_name = 'store')= NULL;
/* Dropping Unnecessary column like Row_ID */
alter table "store" drop column "row_id";
select * from store limit 10;
/* Check the count of United States */
select count(country) from store
where country = 'United States';
/* PRODUCT LEVEL ANALYSIS*/
/* What are the unique product categories? */
select * from store
select distinct(category) from store
/* What is the number of products in each category? */
select distinct(category),count(*) as no_of_items from store
group by category;

/* Find the number of Subcategories products that are divided. */
select distinct(sub_category) from store;
/* Find the number of products in each sub-category. */
select sub_category, count(*) as no_of_items from store 
group by sub_category
order by count(*) desc; 
/* Find the number of unique product names. */
select * from store
select count(distinct(product_name)) from store 
/* Which are the Top 10 Products that are ordered frequently? */
select product_name, count(*) as no_of_products
from store
group by product_name
order by count(*) desc limit 10;
/* Calculate the cost for each Order_ID with respective Product Name. */
select order_id,product_name,round(cast((sales-profit) as Numeric),2) as cost from store
/* Calculate % profit for each Order_ID with respective Product Name. */
select order_id,product_name,round(cast((profit/(sales-profit)*100) as Numeric),2) as profit
from store
/* Calculate the overall profit of the store. */
select round(cast((sum(profit)/(sum(sales)-sum(profit)))*100 as Numeric),2) as profit_percentage
from store
/* Calculate percentage profit and group by them with Product Name and Order_Id. */
select order_id, product_name, round(cast((profit/(sales-profit))*100 as Numeric),2) as profit_percent
from store
group by order_id, product_name, profit_percent
/* Same Thing Using normal method without creating any temporary data. Here, This can be only viewed for one time and we can't merge with the current dataset in this process.*/
/* Where can we trim some loses? 
   In Which products?
   We can do this by calculating the average sales and profits, and comparing the values to that average.
   If the sales or profits are below average, then they are not best sellers and 
   can be analyzed deeper to see if its worth selling them anymore. */
-- Average sales per sub-cat
select round(cast(avg(sales) as Numeric),2) as average_sales from store
-- The average sales is 229.83 i.e., 230
select round(cast(avg(profit) as Numeric),2) as average_profit from store
-- The average profit is 28.65
select round(cast(avg(sales) as Numeric),2) as average_sales, sub_category
from store
group by sub_category
order by average_sales asc
limit 9
--The sales of these Sub_category products are below the average sales.
-- Average profit per sub-cat
select round(cast(avg(profit) as Numeric),2) as average_profit, sub_category
from store
group by sub_category
order by average_profit asc
limit 11
--The profit of these Sub_category products are below the average profit.
-- "Minus sign" Respresnts that those products are in losses.
/* CUSTOMER LEVEL ANALYSIS*/
/* What is the number of unique customer IDs? */
select count(distinct(customer_id)) from store
/* Find those customers who registered during 2014-2016. */
select * from store
select distinct(Customer_name), customer_id, order_id, city, postal_code, years
from store
where years>=2014 and years<=2016
/* Calculate Total Frequency of each order id by each customer Name in descending order.*/
select order_id, customer_name, count(order_id) as total_frequency
from store
group by order_id, customer_name
order by total_frequency desc
/* Calculate  cost of each customer name. */
select * from store
select customer_name,round(cast((sum(sales-profit)) as Numeric),2) as total_cost
from store
group by customer_name
order by total_cost desc
limit 10

/* Display No of Customers in each region in descending order. */
select * from store
select region, count(region) as no_of_customers
from store
group by region
order by no_of_customers desc
/* Find Top 10 customers who order frequently. */
select customer_name, count(*) as no_of_orders
from store
group by customer_name
order by no_of_orders desc
limit 10
/* Display the records for customers who live in state California and Have postal code 90032. */
select * from store
where states = 'California' and postal_code = '90032'
/* Find Top 20 Customers who benefitted the store.*/
select customer_name, city, sales, profit
from store
group by customer_name, city, sales, profit
order by profit desc
limit 20
 --Which state(s) is the superstore most succesful in? Least?
 select states, round(cast(sum(sales) as Numeric),2) as state_sales
 from store
 group by states
 order by state_sales desc
 limit 10
 SELECT round(cast(SUM(sales) as numeric),2) AS state_sales, States
FROM Store
GROUP BY States
ORDER BY state_sales DESC
OFFSET 1 ROWS FETCH NEXT 10 ROWS ONLY;
--Top 10 results:
/* ORDER LEVEL ANALYSIS */
/* number of unique orders */
select count(distinct(order_id)) as no_of_unique_orders
from store
/* Find Sum Total Sales of Superstore. */
select round(cast(sum(sales) as Numeric),2) as total_sales from store
/* Calculate the time taken for an order to ship and converting the no. of days in int format. */
select * from store
select order_id, customer_id, customer_name, states, (ship_date-order_date) as ship_duration
from store
order by ship_duration desc
limit 20
/* Extract the year  for respective order ID and Customer ID with quantity. */
select order_id, customer_id, quantity, extract(Year from order_date)
from store
group by order_id, customer_id, extract(Year from order_date), quantity
order by quantity
/* What is the Sales impact? */
select * from store
select years,sales, round(cast(((profit/(sales-profit))*100) as numeric),2) as profit_percentage
from store
group by years, sales, profit_percentage
order by profit_percentage desc
--Breakdown by Top vs Worst Sellers:
-- Find Top 10 Categories (with the addition of best sub-category within the category).:
select category, sub_category, round(cast(sum(sales) as numeric),2) as total_sales
from store
group by category, sub_category
order by total_sales desc
--Find Top 10 Sub-Categories. :
select sub_category, round(cast(sum(sales) as numeric),2) as total_sales
from store
group by sub_category
order by total_sales desc
limit 10
--Find Worst 10 Categories.:
select category, sub_category, round(cast(sum(sales) as numeric), 2) as total_sales
from store
group by category, sub_category
order by total_sales asc
limit 10
-- Find Worst 10 Sub-Categories. :
select sub_category, round(cast(sum(sales) as numeric),2) as total_sales
from store
group by sub_category
order by total_sales asc
limit 10
/* Show the Basic Order information. */
select count(order_id) as purchases,
round(cast(sum(sales) as numeric),2) as total_sales,
round(cast(sum(((profit/(sales-profit))*100))/count(*) as numeric),2) as avg_percentage_profit,
min(order_date) as first_purchase_date,
max(order_date) as last_purchase_date,
count(distinct(product_name)) as products_purchased,
count(distinct(city)) as location_count
from store
/* RETURN LEVEL ANALYSIS */
/* Find the number of returned orders. */
select returned_items, count(returned_items) as returned_items_count
from store
group by returned_items
having returned_items = 'Returned'
--Find Top 10 Returned Categories.:
select category, sub_category, returned_items, count(returned_items) as returned_items_count
from store
group by category, returned_items, sub_category
having returned_items = 'Returned'
order by returned_items_count desc
-- Find Top 10  Returned Sub-Categories.:
select sub_category, returned_items, count(returned_items) as returned_items_count
from store
group by sub_category, returned_items
having returned_items = 'Returned'
order by returned_items_count desc
--Find Top 10 Customers Returned Frequently.:
select customer_id, customer_name, returned_items, count(returned_items) as customer_returned_count
from store
group by customer_id, customer_name, returned_items
having returned_items = 'Returned'
order by customer_returned_count desc
limit 10
-- Find Top 20 cities and states having higher return.
select states, city, returned_items, count(returned_items) as no_of_returns
from store
group by states, city, returned_items
having returned_items = 'Returned'
order by no_of_returns desc
limit 20
--Check whether new customers are returning higher or not.
select * from store
select customer_duration, returned_items, count(returned_items) as return_count
from store
group by customer_duration, returned_items
having customer_duration = 'new customer'
order by return_count asc

--Find Top  Reasons for returning.
SELECT Returned_items, Count(Returned_items)as Returned_Items_Count,return_reason
FROM store
GROUP BY Returned_items,return_reason
Having Returned_items='Returned'