#!/usr/bin/env ruby
# CLI interface to accept records of food intake and 
# exercise and simulate the blood sugar levels

require 'time'

BASE_SUGAR_LEVEL = 80

@food_db = {}
@exercise_db = {}
@user_inputs = []

# Considering a 5 hour scenario
@food_impact = {}
@exercise_impact = {}
@net_value_map = {}

def initialize_simulation

	@food_db["1"] = {name: "something", glycemic_index: 60}
	@exercise_db["1"] = {name: "Crunches", exercise_index: 30}

	# Considering a 5 hour scenario
	@food_impact = (0..300).each_with_object(false).to_h
	@exercise_impact = (0..300).each_with_object(false).to_h
	@net_value_map = (0..300).each_with_object(0).to_h

	blood_sugar_simulation
end


# Driver method
def blood_sugar_simulation

	# Accept inputs here
	get_user_inputs
	# Parse inputs
	parse_inputs
	# Calculate net sugar level change
	net_sugar_level_change
	# Map this information against time
	# Keep track of glycation
	# Output

end

# Assumed format of the input
def get_user_inputs
	@user_inputs << "Food, 1, 2017-09-09 00:00:23 -0700"
	@user_inputs << "Exercise, 1, 2017-09-09 00:30:23 -0700"
	@user_inputs << "Exercise, 1, 2017-09-09 03:00:23 -0700"
end


# Parse the user input 
# 
def parse_inputs

	@user_inputs.each do |input|
		impact_factor, id, time = input.split(",").each {|x| x.strip!}
		if (impact_factor.downcase == "food")
			update_food_impact(id, time)
		elsif (impact_factor.downcase == "exercise")
			update_exercise_impact(id, time)
		end
	end
end

def update_food_impact(food_id, eat_time) 

	eat_time = Time.parse(eat_time)
	start_time = (eat_time.hour * 60) + (eat_time.min)
	end_time = start_time + 120 # Since sugar level rises for 2 hours

	increase_rate = sugar_increase_rate_by_food(food_id)
	(start_time..end_time).each do |minute|
		@food_impact[minute] = true	
		@net_value_map[minute] += increase_rate 
	end
	
end

def update_exercise_impact(exc_id, exc_time)

	exc_time = Time.parse(exc_time)
	start_time = (exc_time.hour * 60) + (exc_time.min)
	end_time = start_time + 60 # Since sugar level decreases for 1 hour

	decrease_rate = sugar_decrease_rate_by_exercise(exc_id)
	(start_time..end_time).each do |minute|
		@exercise_impact[minute] = true	
		@net_value_map[minute] -= decrease_rate
	end

end

# Calculate net sugar level change
# Tackle net change
# Tackle normalization
def net_sugar_level_change

	net_change_rate = 0

	puts @food_db.inspect
	if @food_db.key?("1")
		puts "Eating #{@food_db["1"][:name]}" 
	end

	five_hour_levels = []

	current_sugar_level = BASE_SUGAR_LEVEL
	
	
	five_hour_levels << current_sugar_level

	# Conside a 5 hour case to include normalization
	# Ate something and did crunches 
	# Normalize the blood sugar level between hour 2 and 3
	# Did crunches again after 3 hours
	# 
	minute = 0
	while minute <=300 do 

		if @food_impact[minute] || @exercise_impact[minute]
			net_change_rate = @net_value_map[minute]
			five_hour_levels << (current_sugar_level += net_change_rate)
		else
			if current_sugar_level.round != BASE_SUGAR_LEVEL
				current_sugar_level = normalize_sugar_level(current_sugar_level) 
			else
				current_sugar_level = current_sugar_level.round
			end
			five_hour_levels << (current_sugar_level)
		end
		minute += 1
	end

	puts five_hour_levels.inspect
end

# Track sugar increase per minute on food intake
def sugar_increase_rate_by_food(food_id)
	puts "Sugar level increase to be calculated here!"
	
	# Food increases blood sugar over 2 hours
	return (@food_db[food_id][:glycemic_index]).to_f / 120
end	

# Track sugar decrease per minute on food intake
def sugar_decrease_rate_by_exercise(exc_id)
	puts "Sugar level decrease to be calculated here"

	return ((@exercise_db[exc_id][:exercise_index]).to_f / 60)
end

def normalize_sugar_level(current_sugar_level)
	(current_sugar_level.round > BASE_SUGAR_LEVEL) ? current_sugar_level -= 1 : current_sugar_level += 1
end



initialize_simulation

