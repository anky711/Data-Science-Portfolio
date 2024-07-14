use pizzahut;
Select * from pizzas;
Select * from order_details;
Select * from ORDERS;
Select * from pizza_types;


-- Retrieve the total number of orders placed.

Select Count(order_id)
from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS 'Total revenue'
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY 1 , 2;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity_ordered DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hour_of_day, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY hour_of_day
ORDER BY 2 DESC;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    COUNT(pizza_type_id) AS Pizza_types, category
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    round(AVG(Quantity),0) AS Daily_avg
FROM
    (SELECT 
        SUM(order_details.quantity) AS Quantity, orders.date
    FROM
        order_details
    JOIN orders ON order_details.order_id = orders.order_id
    GROUP BY orders.date) AS Order_quantity;
    
    -- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((ROUND(SUM(order_details.quantity * pizzas.price),
                    2) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS 'Total revenue'
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS Percent_Contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Percent_Contribution DESC;

-- Analyze the cumulative revenue generated over time.
SELECT 
    date, 
    SUM(revenue) OVER (ORDER BY date) AS Cum_revenue 
FROM (
    SELECT 
        orders.date, 
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM 
        order_details 
    JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.date
) AS sales;

-- Determine the top 3 most ordered pizza types based on 
-- revenue for each pizza category.
Select category,name , revenue from
(Select category , name , revenue,
rank() over (partition by category order by revenue desc) as rn
from
(Select pizza_types.category , pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;



