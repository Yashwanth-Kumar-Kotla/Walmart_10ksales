/*Solving business problems related to walmart
this is after Data exploration and cleaning using pandas
pymysql etc and exporting it into sql*/

use walmart;


select * from walmart;


select * from walmart
limit 5;

select count(*) from walmart;





select payment_method, count(*)
from walmart
group by payment_method;


select max(quantity) from walmart;

/* After exploring the data let us solve business problems*/
/*Q1 Find the different payment method, number of transactions 
and number of quantity sold*/


select distinct payment_method, count(payment_method), sum(quantity)
from walmart
group by payment_method; 


/* Q2 identify the highest-rated category in each branch, displaying
the branch, category and rating*/
select *
from (
	select 
		branch,
		category,avg(rating) as avg_rating,
		RANK() over(partition by branch order by avg(rating) desc) as ranks
	from walmart
	group by branch,category
) as ranked_data
where ranks=1;




/*- Q.3 Identify the busiest day 
for each branch based on the number of transactions
we have to change the format of date column from text to date datatype*/


select * from (
	SELECT branch, 
       DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%W') AS day,
       count(*) as no_of_transactions,
       rank() over(partition by branch order by count(*) desc) as ranks
	FROM walmart
	group by branch,day) as formatted_table
where ranks=1;


/*Q4 -- Calculate the total quantity of items sold per payment method.
 List payment_method and total_quantity.*/
 
 select payment_method,
 sum(quantity) as total_quantity
 from walmart
 group by payment_method;

/*-- Q. 5
-- Determine the average, minimum, and maximum rating of category for each city.
-- List the city, average_rating, min_rating, and max_rating.*/

select city,category,
min(rating) as min_rating, max(rating) as max_rating,
avg(rating) as avg_rating
from walmart
group by city,category;


/*-- Q. 6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.*/

select category,
sum(total_sales * profit_margin)  as total_profit
from walmart
group by category
order by total_profit desc;

/*-- Q.7
-- Determine the most common payment method for each Branch.
-- Display Branch and the preferred_payment_method.*/

select * from (
	select branch,payment_method, count(*) as No_of_trans,
		rank() over(partition by branch order by count(*) desc) as ranks
	from walmart
	group by branch,payment_method) as formatted_table
where ranks = 1;

/*Q. 8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out each of the shift and number of invoices*/


    
SELECT branch,
       CASE 
           WHEN HOUR(time) BETWEEN 0 AND 11 THEN 'Morning'
           WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
           WHEN HOUR(time) BETWEEN 18 AND 23 THEN 'Evening'
           ELSE 'Unknown'  -- In case there’s an invalid time, though it shouldn’t happen with valid data
       END AS shift,
       count(*)
FROM walmart
group by branch,shift
order by field(shift, 'Morning', 'Afternoon', 'Evening');


/*-- Q. 9 Identify 5 branch with highest decrese ratio in
-- revevenue compare to last year 
(current year 2023 and last year 2022)*/


select *,
DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%Y') AS year
from walmart;


#2022 sales
with revenue_2022 as 
(
select branch, sum(total_sales) as revenue_2022
from walmart
where DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%Y')  = "2022"
group by branch
),
revenue_2023 as
(
select branch, sum(total_sales) as revenue_2023
from walmart
where DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%Y')  = "2023"
group by branch
)
select ls.branch,
ls.revenue_2022 as last_year_revenue,
cs.revenue_2023 as current_yearrevenue,
CAST(((ls.revenue_2022 - cs.revenue_2023) / ls.revenue_2022) * 100 AS DECIMAL(10, 2)) AS percentage_change
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue_2022 > cs.revenue_2023
order by percentage_change desc
limit 5;




