#!/usr/bin/env ruby
# CLI interface to accept records of food intake and 
# exercise and simulate the blood sugar levels

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
	food["1"] = {name: "something", value: 60}

	exercise = {}
	exercise["1"] = {name: "Crunches", value: 30}

	if food.key?("1")
		puts "Eating #{food["1"][:name]}" 

	end

	five_hour_levels = []

	current_sugar_level = BASE_SUGAR_LEVEL
	
	
	five_hour_levels << current_sugar_level

	increase = sugar_increase_rate_by_food
	decrease = sugar_decrease_rate_by_exercise

	# Conside a 5 hour case to include normalization
	# Ate something and did crunches 
	# Normalize the blood sugar level between hour 2 and 3
	# Did crunches again after 3 hours
	# 
	minute = 0
	while minute <=300 do 

		if minute <= 60
			net_change_rate = increase + decrease
		elsif minute > 60 && minute <= 120
			decrease = 0
			net_change_rate = increase
		elsif minute > 120 && minute <= 180
			net_change_rate = 0
			current_sugar_level = normalize_sugar_level(current_sugar_level) if current_sugar_level.round != BASE_SUGAR_LEVEL
		elsif minute > 180 && minute <= 240
			decrease = sugar_decrease_rate_by_exercise
			increase = 0
			net_change_rate = decrease
		else 
			net_change_rate = 0
			current_sugar_level = normalize_sugar_level(current_sugar_level) if current_sugar_level.round != BASE_SUGAR_LEVEL
		end

		five_hour_levels << (current_sugar_level += net_change_rate)

		minute += 1
	end

	puts five_hour_levels.inspect
end

# Track sugar increase per minute on food intake
def sugar_increase_rate_by_food
	puts "Sugar level increase to be calculated here!"
	
	# Food increases blood sugar over 2 hours
	return 60.to_f / 120
end	

# Track sugar decrease per minute on food intake
def sugar_decrease_rate_by_exercise
	puts "Sugar level decrease to be calculated here"
	return (30.to_f / 60) * -1
end

def normalize_sugar_level(current_sugar_level)
	(current_sugar_level.round > BASE_SUGAR_LEVEL) ? current_sugar_level -= 1 : current_sugar_level += 1
end



blood_sugar_simulation

