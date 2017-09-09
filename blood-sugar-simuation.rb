#!/usr/bin/env ruby
# CLI interface to accept records of food intake and 

BASE_SUGAR_LEVEL = 80

# Driver method
def blood_sugar_simulation

	# Store / Get data 
	# Accept inputs here
	# Calculate net sugar level change
	net_sugar_level_change
	# Map this information against time
	# Keep track of glycation
	# Output

end

# Calculate net sugar level change
# Tackle net change
# Tackle normalization
def net_sugar_level_change

	net_change_rate = 0

	food = {}
	food["1"] = {name: "something_to_eat", value: 50}

	if food.key?("1")
		puts "Eating #{food["1"][:name]}" 

	end

	net_change_rate = sugar_increase_rate_by_food
	two_hour_levels = []

	current_sugar_level = BASE_SUGAR_LEVEL
	
	two_hour_levels << current_sugar_level
	120.times do 
		two_hour_levels << (current_sugar_level += net_change_rate)
	end

	puts two_hour_levels.inspect
end

# Track sugar increase per minute on food intake
def sugar_increase_rate_by_food
	puts "Sugar level increase to be calculated here!"
	
	# Food increases blood sugar over 2 hours
	return 50.to_f / 120
end	

# Track sugar decrease per minute on food intake
def sugar_decrease_rate_by_exercise
	puts "Sugar level decrease to be calculated here"
	return 0.0;
end

blood_sugar_simulation

