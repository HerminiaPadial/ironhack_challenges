--KATA TOP 10 CUSTOMERS
SELECT
cu.customer_id AS CUSTOMER_ID,
cu.email AS EMAIL,
COUNT(pa.payment_id) AS PAYMENTS_COUNT,
CAST(SUM(pa.amount) AS FLOAT) AS TOTAL_AMOUNT
FROM customer AS cu
INNER JOIN payment AS pa
ON pa.customer_id = cu.customer_id
GROUP BY cu.customer_id
ORDER BY TOTAL_AMOUNT
DESC
LIMIT 10