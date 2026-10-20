--QUERY 1
-- query 1: arbitrary aliases and reordered output
SELECT "product_name || ', ' || COALESCE(product_size, '') || ' (' || COALESCE(product_qty_type, 'unit') || ')'" AS "q1_field_0" FROM (SELECT 
product_name || ', ' || COALESCE(product_size, '') || ' (' || COALESCE(product_qty_type, 'unit') || ')'
FROM product);
--END QUERY

--QUERY 2
-- query 2: arbitrary aliases and reordered output
SELECT "q2_field_2",
        COALESCE(LEAD("q2_field_1") OVER (ORDER BY "q2_field_0", "q2_field_1"),
                 FIRST_VALUE("q2_field_1") OVER (ORDER BY "q2_field_0", "q2_field_1")) AS "q2_field_1",
        "q2_field_0" FROM (SELECT "visit_number" AS "q2_field_2", "market_date" AS "q2_field_1", "customer_id" AS "q2_field_0" FROM (-- query for question 2: student answer
SELECT customer_id, market_date,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY market_date) AS visit_number

FROM customer_purchases
WHERE market_date < '2022-04-29'

GROUP BY customer_id, market_date
ORDER BY customer_id, market_date));
--END QUERY

--QUERY 3
-- query 3: arbitrary aliases and reordered output
SELECT "market_date" AS "q3_field_1", "customer_id" AS "q3_field_0" FROM (-- query for question 3: student answer
SELECT customer_id, market_date FROM (
        SELECT DISTINCT customer_id, market_date,
               DENSE_RANK() OVER (
                   PARTITION BY customer_id ORDER BY market_date DESC
               ) AS visit_number
        FROM customer_purchases
    ) x WHERE visit_number = 1);
--END QUERY

--QUERY 4
-- query 4: arbitrary aliases and reordered output
SELECT "cnt" AS "q4_field_3", "market_date" AS "q4_field_2", "product_id" AS "q4_field_1", "customer_id" AS "q4_field_0" FROM (-- query for question 4: student answer
SELECT customer_id, product_id, market_date,
        COUNT(*) OVER (PARTITION BY customer_id, product_id ORDER BY market_date) AS cnt
        FROM customer_purchases WHERE market_date < '2022-04-29');
--END QUERY

--QUERY 5
-- query 5: arbitrary aliases and reordered output
SELECT "description" AS "q5_field_5", "product_qty_type" AS "q5_field_4", "product_category_id" AS "q5_field_3", "product_size" AS "q5_field_2", "product_name" AS "q5_field_1", "product_id" AS "q5_field_0" FROM (-- query for question 5: student answer
SELECT *, 
CASE WHEN INSTR(product_name,'-') > 0
  THEN LTRIM(RTRIM(SUBSTR(product_name,INSTR(product_name,'-')+1)))
  ELSE NULL END AS description

FROM product);
--END QUERY

--QUERY 6
-- query 6: arbitrary aliases and reordered output
SELECT "description" AS "q6_field_5", "product_qty_type" AS "q6_field_4", "product_category_id" AS "q6_field_3", "product_size" AS "q6_field_2", "product_name" AS "q6_field_1", "product_id" AS "q6_field_0" FROM (-- query for question 6: student answer
SELECT *, 
CASE WHEN INSTR(product_name,'-') > 0
  THEN LTRIM(RTRIM(SUBSTR(product_name,INSTR(product_name,'-')+1)))
  ELSE NULL END AS description


FROM product
WHERE product_size REGEXP( '[0-9]'));
--END QUERY

--QUERY 7
-- query 7: arbitrary aliases and reordered output
SELECT "sales_rank" AS "q7_field_2", "sales" AS "q7_field_1", "market_date" AS "q7_field_0" FROM (-- query for question 7: student answer
WITH sales_per_market AS (
SELECT
market_date,
ROUND(SUM(quantity * cost_per_quantity),2) AS sales

FROM customer_purchases
GROUP BY market_date
)

,market_dates_ranked_by_sales AS (
SELECT
market_date,
sales,
RANK() OVER (ORDER BY sales) AS sales_rank_asc,
RANK() OVER (ORDER BY sales DESC) AS sales_rank_desc

FROM sales_per_market
)
      
SELECT market_date, sales, sales_rank_desc AS sales_rank
FROM market_dates_ranked_by_sales
WHERE sales_rank_asc = 1

UNION

SELECT market_date, sales, sales_rank_desc AS sales_rank
FROM market_dates_ranked_by_sales
WHERE sales_rank_desc = 1);
--END QUERY

--QUERY 8
-- query 8: arbitrary aliases and reordered output
SELECT "extra" AS "q8_field_3", "product_name" AS "q8_field_2", "gross_income" AS "q8_field_1", "vendor_name" AS "q8_field_0" FROM (-- query for question 8: student answer
SELECT vendor_name, "sum(price)" AS gross_income, product_name, 0 AS extra FROM (SELECT vendor_name, product_name, sum(price)
FROM (
  SELECT DISTINCT
  vendor_name,
  product_name,
  5 * original_price as price

  FROM vendor_inventory vi 
  JOIN vendor v on v.vendor_id = vi.vendor_id
  JOIN product p on p.product_id = vi.product_id
  ) x
CROSS JOIN 
  (SELECT DISTINCT 
  customer_id
  FROM customer)
GROUP BY vendor_name, product_name));
--END QUERY

--QUERY 9
-- query 9: arbitrary aliases and reordered output
-- query for question 9: student answer
CREATE TEMP TABLE product_units AS

 SELECT p.*,
   CURRENT_TIMESTAMP AS snapshot_timestamp
 FROM product AS p
 WHERE product_qty_type = "unit"
--END QUERY

--QUERY 10
-- query 10: arbitrary aliases and reordered output
-- query for question 10: student answer
INSERT INTO product_units (product_id, product_name,
  product_size, product_category_id, product_qty_type, snapshot_timestamp)
      SELECT
          product_id,
          product_name,
          product_size,
          product_category_id,
          product_qty_type,
          CURRENT_TIMESTAMP
      FROM product AS p
      WHERE product_id = 7
--END QUERY

--QUERY 11
-- query 11: arbitrary aliases and reordered output
-- query for question 11: student answer
WITH older_record AS
(SELECT product_id
    ,MIN(snapshot_timestamp) AS snapshot_timestamp
    FROM product_units 
    WHERE product_id = 7)

DELETE FROM product_units
WHERE (product_id = 
  (SELECT  product_id 
  FROM older_record
    )
AND snapshot_timestamp =  
  (SELECT  snapshot_timestamp 
  FROM older_record
    ))
--END QUERY

--QUERY 12
-- query 12: arbitrary aliases and reordered output
-- query for question 12: student answer
ALTER TABLE product_units
ADD current_quantity INT;

UPDATE product_units
SET current_quantity = (
  SELECT current_quantity 
  FROM (
    SELECT  p.product_id, COALESCE(quantity,0) as current_quantity

    FROM product_units p
    LEFT JOIN (
      SELECT *
      ,ROW_NUMBER() OVER( PARTITION BY vi.product_id ORDER BY market_date DESC) AS rn
      FROM vendor_inventory vi 
    ) vi ON p.product_id  = vi.product_id

    WHERE rn = 1 
    OR rn IS NULL
  ) p
WHERE product_units.product_id = p.product_id);
--END QUERY