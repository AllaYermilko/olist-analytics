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

