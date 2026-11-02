#!/bin/bash

wget -O /tmp/olist.zip https://www.kaggle.com/api/v1/datasets/download/olistbr/brazilian-ecommerce
unzip /tmp/olist.zip -d /tmp/olist

psql -U admin -d postgres << 'EOF'
\copy olist.customers FROM '/tmp/olist/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.geolocation FROM '/tmp/olist/olist_geolocation_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.order_items FROM '/tmp/olist/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.order_payments FROM '/tmp/olist/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.order_reviews FROM '/tmp/olist/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.orders FROM '/tmp/olist/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.products FROM '/tmp/olist/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.sellers FROM '/tmp/olist/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy olist.product_category_name_translation FROM '/tmp/olist/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
EOF

rm -rf /tmp/olist*
