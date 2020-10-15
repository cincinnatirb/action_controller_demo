json.extract! user, :id, :username, :first_name, :last_name, :bio, :bicycles, :gpa, :birth_date, :account_expiration, :earthling, :created_at, :updated_at
json.url user_url(user, format: :json)
