--Головний датасет: позиції доставлених замовлень з контекстом
SELECT 
	o.order_id,
    o.order_purchase_t,
    strftime('%Y-%m', o.order_purchase_t) AS ym, --рядком відформатуй часolist_sellers_dataset
	cu.customer_state,
    t.product_category_1 AS category_en,
    oi.price,
    oi.freight_value,
    op.payment_type AS payment_method,
    r.review_score
from olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
JOIN olist_customers_dataset cu USING (customer_id)
JOIN olist_products_dataset p USING (product_id)
LEFT JOIN product_category_name_translation t USING (product_category)
LEFT JOIN olist_order_payments_dataset op USING (order_id)
LEFT JOIN olist_order_reviews_dataset r USING (order_id)
WHERE o.order_status = 'delivered';

--Місячний виторг і кількість замовлень
SELECT
	strftime('%Y-%m', o.order_purchase_t) as ym,
    ROUND(SUM(oi.price), 2) as revenue,
    COUNT(DISTINCT o.order_id) as orders
from olist_orders_dataset o
JOIN olist_order_items_dataset oi USING (order_id)
WHERE o.order_status = 'delivered'
GROUP by ym
ORDER by ym;

--топ-10 категорій за виторгом;
-- 1. healthy_beauty;
-- 2. watches_gifts;
-- 3. bed_bath_table;
-- 4. sports_leisure;
-- 5. computers_accessories;
-- 6. furniture_decor;
-- 7. housewares;
-- 8. cool_stuff;
-- 9. auto;
-- 10. toys.
	
SELECT 
    t.product_category_1 AS category_en,
    ROUND(SUM(oi.price), 2) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
JOIN olist_products_dataset p USING (product_id)
LEFT JOIN product_category_name_translation t USING (product_category)
WHERE o.order_status = 'delivered'
GROUP BY category_en
ORDER BY revenue DESC
LIMIT 10;

-- виторг за штатами (для карти в Tableau)
-- SP	5067633,16
-- RJ	1759651,13
-- MG	1552481,83
-- RS	728897,47
-- PR	666063,51
-- SC	507012,13
-- BA	493584,14
-- DF	296498,41
-- GO	282836,7
-- ES	268643,45
-- PE	251889,49
-- CE	219757,38
-- PA	174470,59
-- MT	152191,62
-- MA	117009,38
-- MS	115429,97
-- PB	112586,82
-- PI	84721
-- RN	82105,66
-- AL	78855,72
-- SE	56574,19
-- TO	48402,51
-- RO	45682,76
-- AM	22155,84
-- AC	15930,97
-- AP	13374,81
-- RR	7057,47

SELECT
 cu.customer_state,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT o.order_id) AS orders
FROM olist_order_items_dataset oi
JOIN olist_orders_dataset o USING (order_id)
JOIN olist_customers_dataset cu USING (customer_id)
WHERE o.order_status = 'delivered'
GROUP BY cu.customer_state
ORDER BY revenue DESC;

--середня оцінка (review_score) за категоріями
-- category_en	avg_score	reviews
-- books_general_interest	4,45	549
-- costruction_tools_tools	4,44	99
-- books_imported	4,4	60
-- books_technical	4,37	266
-- luggage_accessories	4,32	1088
-- food_drink	4,32	279
-- small_appliances_home_oven_and_coffee	4,3	76
-- fashion_shoes	4,23	261
-- food	4,22	495
-- cine_photo	4,21	73
-- stationery	4,19	2507
-- pet_shop	4,19	1939
-- home_appliances	4,17	806
-- computers	4,17	200
-- toys	4,16	4091
-- perfumery	4,16	3421
-- small_appliances	4,15	677
-- musical_instruments	4,15	675
-- cool_stuff	4,15	3772
-- home_appliances_2	4,14	238
-- health_beauty	4,14	9645
-- fashion_bags_accessories	4,14	2039
-- tablets_printing_image	4,12	81
-- furniture_bedroom	4,12	110
-- sports_leisure	4,11	8640
-- industry_commerce_and_business	4,1	266
-- signaling_and_security	4,09	197
-- dvds_blu_ray	4,08	63
-- auto	4,07	4213
-- housewares	4,06	6943
-- drinks	4,05	377
-- costruction_tools_garden	4,05	240
-- construction_tools_lights	4,05	296
-- construction_tools_construction	4,05	926
-- garden_tools	4,04	4329
-- electronics	4,04	2749
-- watches_gifts	4,02	5950
-- market_place	4,02	309
-- consoles_games	4,02	1127
-- christmas_supplies	4,02	146
-- baby	4,01	3048
-- agro_industry_and_commerce	4	212
-- fashion_underwear_beach	3,98	130
-- air_conditioning	3,97	292
-- kitchen_dining_laundry_garden_furniture	3,96	280
-- telephony	3,95	4517
-- home_construction	3,94	600
-- art	3,94	207
-- computers_accessories	3,93	7849
-- furniture_living_room	3,9	502
-- furniture_decor	3,9	8331
-- bed_bath_table	3,9	11137
-- construction_tools_safety	3,84	193
-- home_confort	3,83	435
-- audio	3,83	361
-- 	3,83	1622
-- fixed_telephony	3,68	262
-- fashion_male_clothing	3,64	131
-- office_furniture	3,49	1687

SELECT
	t.product_category_1 as category_en,
	ROUND(AVG(r.review_score), 2) as avg_score,
    COUNT(*) as reviews
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset oi USING (order_id)
Join olist_products_dataset p USING (product_id)
LEFT JOIN product_category_name_translation t USING (product_category)
GROUP by category_en
HAVING reviews > 50
Order by avg_score DESC;

--середній час доставки (різниця між датою купівлі і датою доставки);
-- 12.6 days

SELECT
	ROUND(AVG(julianday(order_delivered_6) - julianday(order_purchase_t)), 1) as avg_delivery_days
from olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_6 is NOT NULL;

-- розподіл способів оплати
-- payment_type 	n	    total_value
-- credit_card	    76795	12542084,19
-- boleto	        19784	2869361,27
-- voucher	        5775	379436,87
-- debit_card	    1529	217989,79
-- not_defined	    3	    0

SELECT
	payment_type,
    COUNT(*) as n,
    ROUND(SUM(payment_value), 2) as total_value
FROM olist_order_payments_dataset
GROUP by payment_type
order by n DESC;

