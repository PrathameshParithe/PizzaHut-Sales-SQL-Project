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
    
