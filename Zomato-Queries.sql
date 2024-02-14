    SELECT * FROM goldusers_signup;
    SELECT * FROM users;
    SELECT * FROM sales;
    SELECT * FROM product;
    
    
  /* 1. What is total amount each customer spent on zomato ? */
  
  SELECT
  s.userid,
  SUM(p.price) AS total_amount
  FROM sales s 
  JOIN product p 
  ON s.product_id = p.product_id
  GROUP BY s.userid
  ORDER BY total_amount DESC;
  
  /* 2. How many days has each customer visited zomato? */
  
  SELECT 
  userid,
  COUNT(created_date) AS no_of_days_visited 
  FROM sales
  GROUP BY userid 
  ORDER BY no_of_days_visited DESC;
  
  /* 3. What was the first product purchased by each customer? */
  
  WITH CTE AS(
  SELECT 
  *,
  DENSE_RANK() OVER(PARTITION BY userid ORDER BY created_date) AS rnk
  FROM sales
  )
     SELECT 
     c.userid,
     p.product_name 
     FROM CTE c 
     JOIN product p 
     ON c.product_id = p.product_id 
     WHERE c.rnk = 1;
    
  /* 4. What is most purchased item on menu & how many times was it purchased by all customers ? */  
  
  WITH CTE AS(
  SELECT 
  s.product_id,
  p.product_name,
  COUNT(s.product_id) AS cnt,
  DENSE_RANK() OVER (ORDER BY COUNT(product_id) DESC) AS rnk
  FROM sales s
  JOIN product p
  ON s.product_id = p.product_id
  GROUP BY product_id,  p.product_name
  )
  
         SELECT 
         s.userid,
         c.product_name,
         COUNT(c.product_id) cnt_of_items
         FROM sales s 
         LEFT JOIN CTE c 
         ON s.product_id = c.product_id 
         WHERE c.rnk = 1
         GROUP BY s.userid, c.product_id, c.product_name
         ORDER BY cnt_of_items DESC;
  
  /* 5. Which item was most popular for each customer? */
  
    WITH CTE AS(
    SELECT 
    s.userid,
    s.product_id,
    p.product_name,
    COUNT(s.product_id) AS cnt,
    DENSE_RANK() OVER(PARTITION BY s.userid ORDER BY COUNT(s.product_id) DESC) AS rnk
    FROM sales s
    JOIN product p
    ON s.product_id = p.product_id
    GROUP BY s.userid, s.product_id, p.product_name
    ORDER BY s.userid, s.product_id, p.product_name
    )
    
        SELECT
        userid,
        product_name AS most_popular_product
        FROM CTE 
        WHERE rnk = 1;

/* 6. Which item was purchased first by the customer after they become a member? */
    
     WITH CTE AS(
     SELECT 
     s.*,
     DENSE_RANK() OVER(PARTITION BY s.userid ORDER BY s.created_date) AS rnk
     FROM sales s 
     JOIN goldusers_signup g
     ON s.userid = g.userid 
     AND s.created_date > gold_signup_date
     ORDER BY s.userid
     )
          SELECT 
	  c.userid,
          p.product_name AS first_product_after_member
          FROM CTE c 
          JOIN product p 
          ON c.product_id = p.product_id
          WHERE c.rnk = 1
          ORDER BY userid;

/* 7. Which item was purchased just before the customer became a member? */

     WITH CTE AS(
     SELECT 
     s.*,
     DENSE_RANK() OVER(PARTITION BY s.userid ORDER BY s.created_date DESC) AS rnk
     FROM sales s 
     JOIN goldusers_signup g
     ON s.userid = g.userid 
     AND s.created_date < gold_signup_date
     ORDER BY s.userid
     )
          SELECT 
	  c.userid,
          p.product_name AS product_before_member
          FROM CTE c 
          JOIN product p 
          ON c.product_id = p.product_id
          WHERE c.rnk = 1
          ORDER BY userid;

/* 8. What is total orders and amount spent for each member before they become a member? */

     SELECT 
     s.userid,
     COUNT(s.created_date) AS no_of_orders,
     SUM(p.price) AS total_amount
     FROM sales s 
     JOIN goldusers_signup g
     ON s.userid = g.userid 
     AND s.created_date < g.gold_signup_date
     JOIN product p 
     ON s.product_id = p.product_id
     GROUP BY s.userid
     ORDER BY s.userid;
    
    
    

    
    
    
    
    
    
    
    
    

