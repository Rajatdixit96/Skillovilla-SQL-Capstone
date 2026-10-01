-- Skillovilla SQL Capstone
-- Reconstructed from the Skillovilla result screenshots.
-- Only the platform's displayed "Correct Answer" queries are included.

-- Q1. How many tickets are there without boarding passes?
SELECT COUNT(*)
FROM tickets t
LEFT JOIN boarding_passes bp
    ON t.ticket_no = bp.ticket_no;


-- Q2. Represent the book_date column in YYYY-MM-DD format using Bookings table.
SELECT book_ref,
       TO_CHAR(book_date, 'YYYY-MM-DD') AS book_date,
       total_amount
FROM bookings;


-- Q3. Identify the most popular product in each store based on quantity sold.
SELECT
    store_name,
    product_name,
    quantity_sold
FROM (
    SELECT
        s.store_name,
        p.product_name,
        SUM(oi.quantity) AS quantity_sold,
        RANK() OVER (
            PARTITION BY s.store_name
            ORDER BY SUM(oi.quantity) DESC
        ) AS rank
    FROM stores s
    JOIN orders o
        ON s.store_id = o.store_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY
        s.store_name,
        p.product_name
) subquery
WHERE rank = 1;


-- Q4. Compare quarterly sales performance across stores and rank stores
-- within each quarter.
WITH QuarterlySales AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-Q') AS year_quarter,
        s.store_name,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_sales
    FROM stores s
    JOIN orders o
        ON s.store_id = o.store_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        TO_CHAR(o.order_date, 'YYYY-Q'),
        s.store_name
)
SELECT
    year_quarter,
    store_name,
    total_sales,
    RANK() OVER (
        PARTITION BY year_quarter
        ORDER BY total_sales DESC
    ) AS performance_rank
FROM QuarterlySales
ORDER BY
    year_quarter,
    performance_rank;


-- Q5. Rank airports based on the number of departing flights.
SELECT departure_airport,
       COUNT(*) AS total_flights,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS airport_rank
FROM flights
GROUP BY departure_airport
ORDER BY airport_rank;
