select * from amazonorders;
select 'product_id' as column_name, count(*) as null_count
from amazonorders
where product_id is null
union
select 'product_name', count(*)
from amazonorders
where product_name is null
union
SELECT 'category', COUNT(*)  
FROM AmazonOrders  
WHERE category IS NULL  
UNION  
SELECT 'discounted_price', COUNT(*)  
FROM AmazonOrders  
WHERE discounted_price IS NULL;

select product_id, count(*)
from amazonorders
group by product_id
having count(*)>1;

update amazonorders
set product_id = trim(product_id),
	product_name = trim(product_name),
    category = trim(category),
    about_product = trim(about_product),
    user_id = trim(user_id),
    user_name = trim(user_name),
    review_id = trim(review_id),
    review_title = trim(review_title),
    review_content = trim(review_content),
    img_link = trim(img_link),
    product_link = trim(product_link);

set sql_safe_updates = 0;    
update amazonorders
set discounted_price = cast(replace(discounted_price, '$','') as decimal(10,2)),
    actual_price = cast(replace(actual_price, '$','') as decimal(10,2)),
    rating = cast(rating as decimal(5,1)),
    rating_count = cast(rating_count as signed);
set sql_safe_updates=1;
    
update amazonorders
set discount_percentage = cast(((actual_price-discounted_price)/actual_price)*100 as decimal(10,2))
where actual_price is not null and discounted_price is not null;

select * from amazonorders
where rating<0 or rating>5;

select * from amazonorders
where discount_percentage<0 or discount_percentage>100;

update amazonorders
set rating_count=1
where rating is not null and rating_count is null;

delete from amazonorders
where actual_price is null and discounted_price is null;

alter table amazonorders add discount_category varchar(50);

update amazonorders 
set discount_category =
    case when discount_percentage >=50 then "High Discount"
         when discount_percentage between 20 and 49 then "Medium Discount"
         else "Low Discount"
	end;
select category, Product_category , count(*) as Total_Products, avg(rating) as Average_rating
from amazonorders
where rating is not null
group by category, Product_category
order by average_rating; 
   
select category, Product_category, sum(rating_count) as Total_ratings
from amazonorders
where rating_count is not null	
group by category, Product_category
order by total_ratings desc
limit 100;

SELECT category, Product_category, Total_ratings
FROM (
    SELECT category, Product_category, SUM(rating_count) as Total_ratings,
           RANK() OVER (ORDER BY SUM(rating_count) DESC) AS rank_order
    FROM amazonorders
    WHERE rating_count IS NOT NULL
    GROUP BY category, Product_category
) ranked_data
WHERE rank_order <= 100;

SELECT
    COUNT(*) AS product_count,  
    AVG(rating) AS avg_rating,
    discount_category
FROM AmazonOrders  
WHERE rating IS NOT NULL  
GROUP BY discount_category 
ORDER BY avg_rating DESC;

#select @@hostname;

#SHOW VARIABLES LIKE 'port';

ALTER TABLE AmazonOrders ADD COLUMN Product_category VARCHAR(255);
ALTER TABLE AmazonOrders DROP COLUMN simple_category;

UPDATE AmazonOrders
SET Product_category = SUBSTRING_INDEX(category, '|', -1);


