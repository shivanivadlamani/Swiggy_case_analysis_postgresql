create table food (
	f_id int8 ,
	f_name varchar(50),
	type varchar(50)
)

create table users
(
	user_id int8,
	name varchar(50),
	email varchar(50),
	password varchar(20)
)



create table menu
(
	menu_id int8,
	r_id int8,
	f_id int8,
	price int8
)
 
create table order_details
(
	id int8,
	order_id varchar(50),
	f_id int8
)


create table orders
(
	order_id varchar(50),
	user_id int8,
	r_id int8,
	amount int8,
	date DATE
)
 
CREATE table restaurants
(
	r_id int8,
	r_name varchar(50),
	cuisine varchar(50),
	rating float
)



/* 1.	Find customers who have never ordered */
 
 select name 
 from users 
 where user_id NOT IN (select user_id 
					   from orders)
					   
					   
/*2.	Average price per dish */
 select f.f_name , round(Avg(price),2) as average_price
 from menu m
 join food f
 on m.f_id = f.f_id
 group by f.f_name
 
 
 /*3.	Find top restaurants in terms of number of orders for a given month */
 
 SELECT r.r_name, COUNT(*) AS month
 FROM orders o
 JOIN restaurants r ON o.r_id = r.r_id
 WHERE to_char(date, 'MM') = '05'
 GROUP BY r.r_name, o.r_id
 ORDER BY COUNT(*) DESC
 LIMIT 1;
 
 

/* 4.	Restaurants with monthly sales > x for x=500 */
 
 SELECT r.r_name, SUM(amount) AS revenue
 FROM orders o
 JOIN restaurants r 
 ON o.r_id = r.r_id
 WHERE to_char(date, 'MM') = '05'
 GROUP BY r.r_name, o.r_id
 having sum(amount) > 500
 
 
/*5.Show all orders with order details for a particular customer in a particular date range */

SELECT o.order_id, r.r_name , f.f_name
FROM orders o
JOIN restaurants r ON r.r_id=o.r_id
JOIN order_details od ON od.order_id = o.order_id
JOIN food f ON f.f_id = od.f_id
WHERE user_id = (SELECT user_id 
				FROM users
				WHERE name like 'Ankit')
AND (date > '2022-06-10' AND date < '2022-07-10')

/* 6.Find restaurants with max repeated customers */

 select r.r_name, count(*) as loyal_customers
 from (
       select r_id,user_id,count(*) as visits
	   from orders
	   group by r_id, user_id
	   having count(*) >1
 ) n
 join restaurants r
 on r.r_id = n.r_id 
 group by r.r_name ,n.r_id
 order by count(*) desc 
 limit 1


/* 7.	Month over month revenue growth of swiggy */

WITH sales AS (
    SELECT DATE_TRUNC('MONTH',date) as month, SUM(amount) AS revenue
    FROM orders
    GROUP BY month
    ORDER BY month
)

SELECT TO_CHAR(month, 'Month') AS month, revenue,
LAG(revenue) OVER(ORDER BY month) AS prev,
round(((revenue - lag(revenue) OVER(ORDER BY month)) / lag(revenue) OVER(ORDER BY month)) * 100 ,2) as percentage_change
FROM sales;


/* 8.	Customers most favorite food */
 with temp as (
	select o.user_id , od.f_id , count(*) as frequency
	from orders o
	join order_details od
	on o.order_id = od.order_id
	group by o.user_id , od.f_id
	order by o.user_id
)

select u.name ,f.f_name , t1.frequency 
from temp t1
join users u on u.user_id = t1.user_id
join food f on f.f_id= t1.f_id
where t1.frequency = ( select MAX(frequency)
					   from temp t2
					   where t2.user_id=t1.user_id)





 
 

 
 
 