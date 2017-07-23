json.extract! order, :id, :customer_id, :model, :amount, :created_at, :updated_at
json.url order_url(order, format: :json)
