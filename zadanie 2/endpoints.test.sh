#!/usr/bin/env bash

API_URL='localhost:8000/api/products'
content_type='Content-Type: application/json'
curl_out="\nhttp status code: %{http_code}\n"

echo '---add 3 product (POST /api/products)---'
curl -s -d '{"name": "fabulous chair", "price": "127.54"}' -X POST -H "$content_type" -w "$curl_out" "$API_URL"
product=$(curl -s -d '{"name": "amazing table", "price": "1450.99"}' -X POST -H "$content_type" -w "$curl_out" "$API_URL")
echo "$product"
curl -s -d '{"name": "okayish lamp", "price": "35.27"}' -X POST -H "$content_type" -w "$curl_out" "$API_URL"
echo

id=$(echo "$product" | grep -P -o '(?<="id":)\d+')

echo "---list all products (GET /api/products)---"
curl -s -w "$curl_out" "$API_URL"
echo

echo "---get product with id: $id (GET /api/products/$id)---"
curl -s -w "$curl_out" "$API_URL/$id"
echo

echo "---update price of product with id: $id (PUT /api/products/$id)---"
curl -s -d '{"price": "1725.14"}' -X PUT -H "$content_type" -w "$curl_out" "$API_URL/$id"
echo

echo "---delete product with id: $id (DELETE /api/products/$id)---"
curl -s -X DELETE -H "$content_type" -w "$curl_out" "$API_URL/$id"
echo

echo "---list all products (GET /api/products)---"
curl -s -w "$curl_out" "$API_URL"
