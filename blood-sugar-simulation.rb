#!/usr/bin/env ruby
# CLI interface to accept records of food intake and 
# exercise and simulate the blood sugar levels

require 'time'

BASE_SUGAR_LEVEL = 80

# Inputs and reference data
@food_db = {}
@exercise_db = {}
@user_inputs = []

# Status mapping strcutures
@food_impact = {}
@exercise_impact = {}
@net_value_map = {}

# Variables
@food_impact_period = 120		# Food increases blood sugar over 2 hours
@exercise_impact_period	= 60	# Exercise decreases blood sugar over 1 hour
@glycation_threshold = 150
@simulation_period = 0
@glycation_count = 0

def initialize_simulation(hours = 5)

	@food_db["1"] = {name: "something", glycemic_index: 60}
	@exercise_db["1"] = {name: "Crunches", exercise_index: 30}

	render_script_information
	get_user_inputs

	# Initialize the tracking maps.
	@simulation_period = hours * 60 # Convert to minutes
	@food_impact = (0..@simulation_period).each_with_object(false).to_h
	@exercise_impact = (0..@simulation_period).each_with_object(false).to_h
	@net_value_map = (0..@simulation_period).each_with_object(0).to_h

	blood_sugar_simulation
end


# Driver method
def blood_sugar_simulation

	parse_inputs
	simulate_sugar_levels
end

# Get inputs from the user
def get_user_inputs

	input = "begin"

	while input != "exit" do 
		puts "Enter Food or Exercise with ID and timestamp in above mentioned format"
		puts "Type exit to finish."
		input = gets.chomp
		@user_inputs << input unless input == "exit"
	end
end


# Parse the user input and update food or exercise impact maps
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

# Tracks minutes impacted by food consumption
# @param [String] food_id ID of the food consumed
# @param [String] eat_time Timestamp of food consumption
def update_food_impact(food_id, eat_time) 

	eat_time = Time.parse(eat_time)
	start_time = (eat_time.hour * 60) + (eat_time.min)
	end_time = start_time + @food_impact_period

	increase_rate = sugar_increase_rate_by_food(food_id)
	(start_time..end_time).each do |minute|
		@food_impact[minute] = true	
		@net_value_map[minute] += increase_rate 
	end
end

# Tracks minutes impacted by exercise
# @param [String] ecx_id ID of the exercise performed
# @param [String] exc_time Timestamp of exercise
def update_exercise_impact(exc_id, exc_time)

	exc_time = Time.parse(exc_time)
	start_time = (exc_time.hour * 60) + (exc_time.min)
	end_time = start_time + @exercise_impact_period

	decrease_rate = sugar_decrease_rate_by_exercise(exc_id)
	(start_time..end_time).each do |minute|
		@exercise_impact[minute] = true	
		@net_value_map[minute] -= decrease_rate
	end

end

# Calculated and stores the simulated rates of blood sugar
# level based on food consumed and exercise performed at any
# point of time, by the minute. Also normalization chart and 
# keeps a glycation count. 
def simulate_sugar_levels

	net_change_rate = 0
	minute = 0
	current_sugar_level = BASE_SUGAR_LEVEL
	simulated_sugar_levels = [] << current_sugar_level

	# Calculate simulated sugar levels by the minute
	while minute <= @simulation_period do 

		# Impact of food or exercise or both
		if @food_impact[minute] || @exercise_impact[minute]
			net_change_rate = @net_value_map[minute]
			simulated_sugar_levels << (current_sugar_level += net_change_rate)
		else # No impact of either food or sugar
			current_sugar_level = normalize_sugar_level(current_sugar_level) 
			simulated_sugar_levels << (current_sugar_level)
		end

		@glycation_count += 1 if current_sugar_level > @glycation_threshold

		minute += 1
	end

	# Extended period simulation if blood sugar level is not
	# normalized by end of stated period
	is_extended_simulation = current_sugar_level != BASE_SUGAR_LEVEL ? true : false
	while current_sugar_level != BASE_SUGAR_LEVEL do 

		current_sugar_level = normalize_sugar_level(current_sugar_level) 
		simulated_sugar_levels << (current_sugar_level)
		@glycation_count += 1 if current_sugar_level > @glycation_threshold
	end

	render_results(simulated_sugar_levels, is_extended_simulation)

end

# Returns sugar increase per minute on food intake
# @param [String] food_id ID of the food consumed
# @return [Float] Increase rate of sugar
def sugar_increase_rate_by_food(food_id)
	return (@food_db[food_id][:glycemic_index]).to_f / @food_impact_period
end	

# Returns sugar decrease per minute on food intake
# @param [String] exc_id ID of the exercise performed
# @return [Float] Decrease rate of sugar
def sugar_decrease_rate_by_exercise(exc_id)
	return ((@exercise_db[exc_id][:exercise_index]).to_f / @exercise_impact_period)
end

# Returns the current sugar level as it normalized
# to BASE_SUGAR_LEVEL
# @param [Float] current_sugar_level 
# @return [Float] updated sugar level
def normalize_sugar_level(current_sugar_level)

	if current_sugar_level.round == BASE_SUGAR_LEVEL
		return current_sugar_level.round 
	elsif current_sugar_level.floor == BASE_SUGAR_LEVEL
		return current_sugar_level.floor
	else
		(current_sugar_level.round > BASE_SUGAR_LEVEL) ? current_sugar_level -= 1 : current_sugar_level += 1
	end
end


# Render the resuts
# @param [Array] sugar_levels_by_minute Simulated sugar levels
# @param [Boolean] is_extended_simulation Flag for note
def render_results(sugar_levels_by_minute, is_extended_simulation = false)

	puts "Note: This simulation is for an extended period as blood levels had not normalized till the end of the default period." if is_extended_simulation
	puts
	puts sugar_levels_by_minute.inspect
	puts
	puts "Glycation count is at #{@glycation_count}"
	puts

end

# Render the necessary information at the start of the script
def render_script_information

	puts "* ---------------------------------------------------------------------------"
	puts "* This is a CLI interface to accept records of food intake and exercise"
	puts "* along with timestamps and simulate the blood sugar levels through the day."
	puts "*"
	puts "* Food intake information is to be entered as below"
	puts '*        "Food, 1, 2017-09-09 00:00:23 -0700"'
	puts "*"
	puts "* Exercise information is to be entered as below"
	puts '*        "Exercise, 1, 2017-09-09 01:45:23 -0700"'
	puts "*"
	puts "* ---------------------------------------------------------------------------"
	puts
end

initialize_simulation

