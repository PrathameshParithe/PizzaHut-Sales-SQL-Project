-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS order_count
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id;
    
-- Identify the highest-priced pizza.

SELECT 
    pt.name, MAX(p.price) AS max_price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY max_price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(order_details_id) AS order_count
FROM
    order_details od
        JOIN
    pizzas p ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS quantity_ordered
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY quantity_ordered DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS quantity_ordered
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY category
ORDER BY quantity_ordered DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_Count
FROM
    orders
GROUP BY hour
ORDER BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(a.quantity), 1) AS avg_pizza_ordered
FROM
    (SELECT 
        o.order_Date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS a;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name,
    ROUND(SUM(p.price * od.quantity), 2) AS total_revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;

# Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    concat(ROUND(SUM(p.price * od.quantity) / (SELECT 
    ROUND(SUM(od.quantity * p.price), 2)  as total_revenue
FROM
    pizzas p
        JOIN
    order_details od ON od.pizza_id = p.pizza_id)*100,2),"%") as total_revenue
FROM
    pizza_types pt JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
        JOIN order_details od ON p.pizza_id = od.pizza_id
    group by pt.category
    order by total_revenue desc;
    
-- Analyze the cumulative revenue generated over time.

select a.order_date,
	   a.revenue,
	   round(sum(revenue) over(order by order_date),2) as cumalative_revenue
		from
        (select o.order_date,
				round(sum(p.price* od.quantity),1) as revenue
		from 
			orders o
		join 
			order_details od
		on o.order_id = od.order_id
		join 
			pizzas p on od.pizza_id = p.pizza_id
		group by o.order_date) a;
        
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select
	category,
    name,
    revenue,
    rnk from
    (select category,
			name,
            revenue,
            rank() over(partition by category order by revenue desc) as rnk
            from
			(select 
					pt.category,
                    pt.name,
                    round(sum(p.price * od.quantity),1) as revenue
            from 
				pizza_types pt
            join 
				pizzas p on p.pizza_type_id = pt.pizza_type_id
            join 
				order_details od on
				p.pizza_id = od.pizza_id
            group by category,pt.name)a)b
            where rnk <= 3;








