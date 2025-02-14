create database SQLiciousDB;
use SQLiciousDB;

create table sales(
	customer_id varchar(1),
	order_date date,
	product_id integer
);

insert into sales 
	(customer_id, order_date, product_id)
values
	('a', '2025-02-01', 1),
	('a', '2025-02-01', 2),
	('a', '2025-02-07', 2),
	('a', '2025-02-10', 3),
	('a', '2025-02-11', 3),
	('a', '2025-02-11', 3),
	('b', '2025-02-01', 2),
	('b', '2025-02-02', 2),
	('b', '2025-02-04', 1),
	('b', '2025-02-11', 1),
	('b', '2025-02-16', 3),
	('b', '2025-02-20', 3),
	('c', '2025-02-01', 3),
	('c', '2025-02-01', 3),
	('c', '2025-02-07', 3);

create table menu(
	product_id integer,
	product_name varchar(20),
	price integer
);

insert into menu
	(product_id, product_name, price)
values
	(1, 'masala dosa', 160),
    (2, 'veg biryani', 320),
    (3, 'chilli paneer', 280);

create table members(
	customer_id varchar(1),
	customer_name varchar(50),
	join_date date
);

insert into members
	(customer_id, customer_name, join_date)
values
	('a', 'Vinay kumar panika', '2025-02-07'),
    ('b', 'Awadhesh yadav', '2025-02-09'),
    ('c', 'Nevendra rajput', '2025-02-15');


--Question- 1. What is the total amount each customer spent at the restaurant?
select m.customer_id,m.customer_name,sum(price) as Total_spending
from members as m 
inner join sales as s on m.customer_id = s.customer_id
inner join menu on s.product_id = menu.product_id
group by m.customer_id,m.customer_name
order by Total_spending desc;

-- Question- 2. How many days has each customer visited the restaurant?
select m.customer_id,m.customer_name,
count(distinct s.order_date) as days_visited from members as m
inner join sales as s on m.customer_id = s.customer_id
group by m.customer_id,m.customer_name
order by  days_visited desc;

-- Question- 3. What was the first item from the menu purchased by each customer?
with cte_first_item as (
	select m.customer_name,mn.product_name,s.order_date,
	dense_rank() over( partition by m.customer_name order by s.order_date asc) as Ranking
	from members as m 
	inner join sales as s on m.customer_id = s.customer_id
	inner join menu as mn on s.product_id = mn.product_id)
select customer_name,product_name,order_date from cte_first_item
where ranking = 1
group by customer_name,product_name,order_date;


/* Question- 4. What is the most purchased item on the menu and how many times was it 
purchased by all customers? */

select top 1 mn.product_id,mn.product_name,count(s.product_id) as order_count
from menu as mn 
inner join sales as s on mn.product_id = s.product_id
group by mn.product_id,mn.product_name
order by order_count desc;

-- Question- 5. Which item was the most popular for each customer?
with cte_popularity as (
	select s.customer_id,mn.product_name,count(mn.product_id) as order_count,
	dense_rank() over(partition by s.customer_id order by count(mn.product_id) desc) as ranking
	from sales as s
	inner join menu as mn on s.product_id = mn.product_id
	group by s.customer_id,mn.product_name)
select cp.customer_id,m.customer_name,cp.product_name,
cp.order_count from cte_popularity as cp
inner join members as m on m.customer_id = cp.customer_id
where ranking = 1;

-- Quetion- 6. What is the first item purchased after becoming a member?
with cte_first_item as (
	select s.customer_id,mn.product_name,s.order_date,m.join_date,
	dense_rank() over (partition by s.customer_id order by s.order_date asc) as ranking
	from sales as s
	inner join menu as mn on s.product_id = mn.product_id
	inner join members as m on m.customer_id = s.customer_id
	where order_date>=join_date)
select customer_id,product_name from cte_first_item
where ranking = 1;

--Question- 7. Which customer has made the most purchases before becoming a member?
select s.customer_id,count(*) as order_count from sales as s
inner join members as m on s.customer_id = m.customer_id
where s.order_date < m.join_date
group by s.customer_id
order by order_count desc;


-- Question- 8. Rank all the customers based on the total money spent at the restaurant?
with cte_spending as (
	select s.customer_id,sum(mn.price) as total_spending,
	rank() over( order by sum(mn.price) desc) as ranking
	from sales as s
	inner join menu as mn on s.product_id = mn.product_id
	group by s.customer_id)
select cte.customer_id,m.customer_name,cte.total_spending from cte_spending as cte
inner join members as m on cte.customer_id = m.customer_id;


--Question- 9. What is the total number of products ordered by each customer?
select s.customer_id,m.customer_name, count(mn.product_id) as product_order
from sales as s 
inner join menu as mn on s.product_id = mn.product_id
inner join members as m on m.customer_id = s.customer_id
group by s.customer_id,m.customer_name;


--Question- 10. What percentage of total revenue came from each product?
select mn.product_name,sum(mn.price) as product_total,
(sum(mn.price)*100.0/(select sum(mn.price) from menu as mn
inner join sales as s on s.product_id = mn.product_id)) as percentage_of_revenue
from menu as mn
inner join   sales as s on s.product_id = mn.product_id
group by mn.product_name
order by percentage_of_revenue desc;

-- Question- 11. How many unique products did each customer order?
select s.customer_id,m.customer_name,count(distinct mn.product_id) as unique_order
from sales as s
inner join menu as mn on s.product_id = mn.product_id
inner join members as m on m.customer_id = s.customer_id
group by s.customer_id, m.customer_name
order by unique_order desc;



-- Question- 12. Which customers ordered different products on the same day?
select customer_id, order_date
from sales
group by customer_id, order_date
having count(distinct product_id) > 1;


