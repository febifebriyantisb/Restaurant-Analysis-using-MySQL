create database dannys_dinner;
use dannys_dinner;

CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INTEGER
);
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
  CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


-- 1. What is the total amount each customer spent at the restaurant?  
select customer_id, sum(price) as total_price 
from Sales 
inner join menu on sales.product_id=menu.product_id 
group by customer_id;

-- 2. How many days has each customer visited the restaurant?
select customer_id, 
count(distinct order_date) as total_visited 
from sales 
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select s.customer_id, min(s.order_date) as first_date_order, m.product_name 
from sales s 
inner join menu m on s.product_id=m.product_id
group by s.customer_id, m.product_name
having min(s.order_date) = 
	(Select s2.order_date 
	from sales s2 
	where s2.customer_id=s.customer_id 
	order by order_date 
	limit 1);

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(s.product_id) as times_purchased
from sales s 
inner join menu m on s.product_id=m.product_id 
group by s.product_id
order by times_purchased desc 
limit 1;

-- 5. Which item was the most popular for each customer?
select s.customer_id, m.product_name as popular_item, count(s.product_id) as times_purchased
from sales s 
inner join menu m on s.product_id=m.product_id 
group by s.customer_id, s.product_id
having count(s.product_id) = (
select count(s2.product_id) from sales s2
where s2.customer_id=s.customer_id
group by s2.product_id
order by count(s2.product_id) desc
limit 1);

-- 6. Which item was purchased first by the customer after they became a member?
 select s.customer_id, mem.join_date, m.product_name, s.order_date
 from menu m
 inner join sales s on m.product_id=s.product_id
 inner join members mem on s.customer_id=mem.customer_id
 where s.order_date = 
	 (select 
	 min(s2.order_date) from sales s2 
	 where s2.customer_id=s.customer_id and s2.order_date>=mem.join_date 
	 group by s2.customer_id limit 1);
 
--  7. Which item was purchased just before the customer became a member?
select s.customer_id , mem.join_date, m.product_name, s.order_date
from menu m
inner join sales s on m.product_id=s.product_id
inner join members mem on s.customer_id=mem.customer_id
where s.order_date = 
	(select 
	max(s2.order_date) from sales s2 
	where s2.customer_id=s.customer_id and s2.order_date <mem.join_date 
	group by s.customer_id limit 1 );

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, 
count(s.product_id) as total_item_before_member, 
sum(m.price) as total_price_before_member
from menu m 
inner join sales s on m.product_id	= s.product_id
inner join members mem on s.customer_id=mem.customer_id
where s.order_date <=
	(select 
	max(s2.order_date) from sales s2 
	where s2.customer_id=s.customer_id and s2.order_date < mem.join_date 
	group by s.customer_id limit 1 )
group by s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, 
sum(case 
		when m.product_name = 'sushi' then m.price*20
		else m.price*10
	end) as total_point
from sales s 
inner join menu m on s.product_id=m.product_id
group by s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January? 
select s.customer_id, s.order_date ,
sum(case 
		when s.order_date between mem.join_date and DATE_ADD(mem.join_date, INTERVAL 7 DAY) then m.price*20
		when m.product_name = 'sushi' then m.price*20
		else m.price*10
	end) as total_point
from menu m 
inner join sales s on s.product_id=m.product_id 
inner join members mem on s.customer_id=mem.customer_id
where month(s.order_date) = 1
group by s.customer_id;
