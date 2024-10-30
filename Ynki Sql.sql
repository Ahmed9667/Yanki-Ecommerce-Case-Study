-- Windows Functions:
-- Calculate the total sales amount for each order along with the individual product sales.
select * from yanki.orders;   -- yanki is the name of schema

select order_id, p.product_id , quantity , total_price ,
sum(o.quantity * p.price) as total_sales_amount
from yanki.orders o 
join yanki.products p
on o.product_id = p.product_id 
group by order_id ,p.product_id  ;

-- another solution
select order_id, p.product_id , quantity , total_price ,
sum(o.quantity * p.price) over(partition by order_id )  as total_sales_amount
from yanki.orders o 
join yanki.products p
on o.product_id = p.product_id ;

-- Calculate the running total price for each order
-- use order for accumulative sum
select order_id, product_id , quantity , total_price , 
sum(total_price) over(order by order_id) as total_price  
from yanki.orders;

-- Rank products by their price within each category

select product_id , product_name ,brand,category,price ,
rank() over(partition by category order by price desc) as ranked_price_of_category
from yanki.products ;
---------------------------------------------------------------------------------------------

-- Ranking:
-- Rank customers by the total amount they have spent
select c.customer_id , customer_name , sum(o.total_price) as total_spent 
from yanki.customers c
join yanki.orders o 
on c.customer_id = o.customer_id 
group by c.customer_id 
order by total_spent desc;

select c.customer_id , customer_name , sum(o.total_price) as total_spent ,
rank() over(order by sum(o.total_price) desc ) as customer_rank
from yanki.customers c
join yanki.orders o 
on c.customer_id = o.customer_id 
group by c.customer_id ;

-- Rank products by their total sales amount
select p.product_id , product_name ,brand,category , sum(p.price * o.quantity) as total_sales_amount ,
rank() over(order by sum(p.price * o.quantity) desc) as ranked_total_amounts
from yanki.products p join yanki.orders o
on o.product_id = p.product_id 
group by p.product_id ;

-- Rank orders by their total price
select
     order_id,
	 total_price ,
	 rank () over(order by total_price desc) as ranked_total_prices
from yanki.orders
group by order_id ;


-- Rank orders and their payment methods by their total price
select
     o.order_id,
	 o.total_price ,
	 p.payment_method,
	 p.transaction_status ,
	 rank () over(order by o.total_price desc) as ranked_total_prices
from yanki.orders o
join yanki.payments p
on o.order_id = p.order_id
group by o.order_id ,  p.payment_method ,  p.transaction_status;

---------------------------------------------------------------------------------------------

-- Case:
-- Categorize the orders based on total price
select
     order_id,
	 total_price ,
	 case
	      when total_price >= 1000 then 'High'
		  when total_price >= 500 and total_price <1000 then 'Medium'
	      else 'Low'
	 end as category_of_price
from yanki.orders ;

-- classify customers by the number of orders they made
select c.customer_id , customer_name , email, phone_number , count(o.order_id) as num_of_orders ,
case 
     when count(o.order_id) >= 10 then 'frequent'
	 when count(o.order_id) >= 5 and count(o.order_id) < 10 then 'Regular'
	 Else 'Occasional'
end as frequency_of_orders
from yanki.customers c
join yanki.orders o
on c.customer_id = o.customer_id
group by c.customer_id ;


-- classify products by their prices
select
       product_id,
	   product_name,
	   price,
	   case 
	       when price >= 500 then 'Expensive'
		   when price >= 100 and price < 500 then 'Moderate'
		   Else 'Affordable'
		end as category_of_price
from yanki.products;
---------------------------------------------------------------------------------------------

--Joins:

-- 1.inner join:
-- retrieve customer details along with the products they ordered
select 
        c.customer_id ,
        c.customer_name ,
		c.email, c.phone_number, 
		o.order_id ,
		p.product_id ,
		quantity,
		total_price,
		product_name,
		brand,
		price
from yanki.customers c
inner join yanki.orders o on c.customer_id = o.customer_id
inner join yanki.products p on o.product_id = p.product_id ;

-- Retrieve order details along with payment information
select p.order_id , payment_method,transaction_status
from yanki.payments p
inner join yanki.orders o
on p.order_id = o.order_id ;


--2.left join:
-- Retrieve all customers along with their orders even if they had not placed any order
select 
        c.customer_id ,
        c.customer_name ,
		c.email,
		c.phone_number, 
		o.order_id ,
		o.product_id ,
		o.quantity,
		o.total_price
from yanki.customers c
left join yanki.orders o on c.customer_id = o.customer_id;


-- Retrieve all orders alongside with products details even if there are no corresponding products
select
        o.order_id ,
		o.customer_id,
		o.product_id ,
		o.quantity,
		o.total_price,
		p.product_name,
		p.price
from yanki.orders o
left join yanki.products p
on o.product_id = p.product_id ;


--3.right join :
-- Retrieve all orders along with payment information even if there are no corresponding payment records
select o.order_id , p.payment_method,p.transaction_status
from yanki.orders o
right join yanki.payments p
on p.order_id = o.order_id ;

-- Retrieve all products along with orders even there ae no corresonding orders
select
		o.product_id ,
		p.product_name,
		o.order_id ,
		o.total_price,
	    o.quantity
from yanki.products p
right join yanki.orders o
on o.product_id = p.product_id ;

--4.outer join
-- Retrieve all customers along with thier orders including customers who have not placed any prders and orders who have not any customers
select 
        c.customer_id ,
        c.customer_name ,
		c.email,
		c.phone_number, 
		o.order_id ,
		o.product_id ,
		o.quantity,
		o.total_price
from yanki.customers c
full outer join yanki.orders o on c.customer_id = o.customer_id;

-- Retrieve all orders along with payment information even if there are no corresponding payment records and payment records without corresponding orders
select o.order_id , p.payment_method,p.transaction_status
from yanki.orders o
full outer join yanki.payments p
on p.order_id = o.order_id ;