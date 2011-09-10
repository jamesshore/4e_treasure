#!/usr/bin/ruby

require 'dice'

PC_COUNT = 4;
INHERENT = true;

def attempt(category, target, &proc)
	adjust = (5 - PC_COUNT) * 2
	roll = 1.d20 - adjust
	if (roll >= target || roll.rolls[0] == 20) then 
		puts "#{category}: #{proc.call(roll)}"
	else 
		puts "  xx No #{category} (#{roll.details}, needed #{target + adjust})"
	end
end

def gold(lesser_roll, amount, quantity, denomination)
	attempt("Gold", lesser_roll) do |roll|
		"#{amount.roll * quantity} #{denomination} (#{roll.details}: #{amount.details})"
	end
end

def gems_or_art(category, description, lesser_roll, lesser_amount, lesser_value, best_roll, best_value)
	attempt(category, lesser_roll) do |roll|
		if (roll >= best_roll || (roll.rolls[0] == 20 && roll >= lesser_roll)) then
			value = best_value
			amount = 1
		else
			value = lesser_value
			amount = lesser_amount
		end
		"#{amount} #{description}#{amount > 1 ? 's' : ''} worth #{value} gp #{amount > 1 ? 'each ' : ''}(#{roll.details}: #{amount.details})"
	end
end

def gems(lesser_roll, lesser_amount, lesser_value, best_roll, best_value)
	gems_or_art("Gems", "gem", lesser_roll, lesser_amount, lesser_value, best_roll, best_value)
end

def art(lesser_roll, lesser_amount, lesser_value, best_roll, best_value)
	gems_or_art("Art", "art object", lesser_roll, lesser_amount, lesser_value, best_roll, best_value)
end

def magic(parcel)
	min = 13 + (INHERENT ? 4 : 0)
	attempt("Magic", min) do |roll|
		is_even = (roll.roll & 1) == 0
		rarity = (is_even || INHERENT) ? "uncommon" : "common"
		rarity = "rare" if roll.rolls[0] == 20
		level = INHERENT ? 1.d2+parcel+1 : 1.d4+parcel
		"one #{rarity} magic item of level #{level} (#{roll.details}: #{level.details})"
	end
end

level = Integer(ARGV[0])
puts "Level #{level} parcel, assuming #{PC_COUNT} PCs#{INHERENT ? ' and inherent bonuses' : ''}:"
puts
case level
when 9:
	gold 11, 2.d8, 100, "gp"
	gems 13, 1, 500, 20, 1000
	art 18, 1.d4, 250, 20, 1500
when 10:
	gold 11, 2.d10, 100, "gp"
	gems 13, 1, 500, 20, 1000
	art 18, 1, 1500, 20, 2500
when 11:
	gold 11, 4.d8, 100, "gp"
	gems 13, 1, 1000, 20, 5000
	art 18, 1, 1500, 20, 2500
when 12:
	gold 11, 4.d12, 100, "gp"
	gems 13, 1.d2, 1000, 20, 5000
	art 17, 1.d3, 1500, 19, 2500
else
	puts "Unsupported level"
	exit
end
magic level
puts
