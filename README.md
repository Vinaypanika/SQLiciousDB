# SQLiciousDB



### 1. What is the total amount each customer spent at the restaurant?
```sql
select m.customer_id,m.customer_name,sum(price) as Total_spending
from members as m 
inner join sales as s on m.customer_id = s.customer_id
inner join menu on s.product_id = menu.product_id
group by m.customer_id,m.customer_name
order by Total_spending desc;
```

### 2. How many days has each customer visited the restaurant?
```sql
select m.customer_id,m.customer_name,
count(distinct s.order_date) as days_visited from members as m
inner join sales as s on m.customer_id = s.customer_id
group by m.customer_id,m.customer_name
order by  days_visited desc;
```

### 3. What was the first item from the menu purchased by each customer?
```sql
with cte_first_item as (
	select m.customer_name,mn.product_name,s.order_date,
	dense_rank() over( partition by m.customer_name order by s.order_date asc) as Ranking
	from members as m 
	inner join sales as s on m.customer_id = s.customer_id
	inner join menu as mn on s.product_id = mn.product_id)
select customer_name,product_name,order_date from cte_first_item
where ranking = 1
group by customer_name,product_name,order_date;
```

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
select top 1 mn.product_id,mn.product_name,count(s.product_id) as order_count
from menu as mn 
inner join sales as s on mn.product_id = s.product_id
group by mn.product_id,mn.product_name
order by order_count desc;
```

### 5. Which item was the most popular for each customer?
```sql
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
```

### 6. What is the first item purchased after becoming a member?
```sql
with cte_first_item as (
	select s.customer_id,mn.product_name,s.order_date,m.join_date,
	dense_rank() over (partition by s.customer_id order by s.order_date asc) as ranking
	from sales as s
	inner join menu as mn on s.product_id = mn.product_id
	inner join members as m on m.customer_id = s.customer_id
	where order_date>=join_date)
select customer_id,product_name from cte_first_item
where ranking = 1;
```

### 7. Which customer has made the most purchases before becoming a member?
```sql
select s.customer_id,count(*) as order_count from sales as s
inner join members as m on s.customer_id = m.customer_id
where s.order_date < m.join_date
group by s.customer_id
order by order_count desc;
```

### 8. Rank all the customers based on the total money spent at the restaurant?
```sql
with cte_spending as (
	select s.customer_id,sum(mn.price) as total_spending,
	rank() over( order by sum(mn.price) desc) as ranking
	from sales as s
	inner join menu as mn on s.product_id = mn.product_id
	group by s.customer_id)
select cte.customer_id,m.customer_name,cte.total_spending from cte_spending as cte
inner join members as m on cte.customer_id = m.customer_id;
```

### 9. What is the total number of products ordered by each customer?
```sql
select s.customer_id,m.customer_name, count(mn.product_id) as product_order
from sales as s 
inner join menu as mn on s.product_id = mn.product_id
inner join members as m on m.customer_id = s.customer_id
group by s.customer_id,m.customer_name;
```

### 10. What percentage of total revenue came from each product?
```sql
select mn.product_name,sum(mn.price) as product_total,
(sum(mn.price)*100.0/(select sum(mn.price) from menu as mn
inner join sales as s on s.product_id = mn.product_id)) as percentage_of_revenue
from menu as mn
inner join   sales as s on s.product_id = mn.product_id
group by mn.product_name
order by percentage_of_revenue desc;
```

### 11. How many unique products did each customer order?
```sql
select s.customer_id,m.customer_name,count(distinct mn.product_id) as unique_order
from sales as s
inner join menu as mn on s.product_id = mn.product_id
inner join members as m on m.customer_id = s.customer_id
group by s.customer_id, m.customer_name
order by unique_order desc;
```

### 12. Which customers ordered different products on the same day?
```sql
select customer_id, order_date
from sales
group by customer_id, order_date
having count(distinct product_id) > 1;
```

## 📞 Contact

If you have any questions or want to connect, feel free to reach out:

- 📧 Email: [vinaypanika@gmail.com](mailto:vinaypanika@gmail.com)
- 💼 LinkedIn: [Vinay Kumar Panika](https://www.linkedin.com/in/vinaykumarpanika)
- 📂 GitHub: [VinayPanika](https://github.com/Vinaypanika)
- 🌐 Portfolio: [Visit My Portfolio](https://sites.google.com/view/vinaykumarpanika/home)
- 📞 Mobile: [+91 7415552944](tel:+917415552944)
