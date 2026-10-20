--QUERY 1
SELECT product_name FROM product;
--END QUERY

--QUERY 2
SELECT customer_id, market_date, 99 AS visit_number FROM customer_purchases;
--END QUERY

--QUERY 3
SELECT customer_id, market_date, 99 AS visit_number FROM customer_purchases;
--END QUERY

--QUERY 4
SELECT *, 99 AS product_purchase_count FROM customer_purchases;
--END QUERY

--QUERY 5
SELECT product_name, NULL AS description FROM product;
--END QUERY

--QUERY 6
SELECT * FROM product;
--END QUERY

--QUERY 7
SELECT market_date, 0 AS sales FROM customer_purchases GROUP BY market_date LIMIT 2;
--END QUERY

--QUERY 8
SELECT vendor_name, product_name, 0 AS revenue FROM vendor CROSS JOIN product;
--END QUERY

--QUERY 9
CREATE TEMP TABLE product_units AS SELECT * FROM product;
--END QUERY

--QUERY 10
SELECT 1;
--END QUERY

--QUERY 11
DELETE FROM product_units WHERE 1 = 0;
--END QUERY

--QUERY 12
ALTER TABLE product_units ADD current_quantity INT;
UPDATE product_units SET current_quantity = -1;
--END QUERY
