require 'assert'

class Dice
	include Comparable
	
	attr_writer :number, :bonus

	def self.factory(num, sides, opts = {})
		@@dice_logic.new(num, sides, opts)
	end
	
	def initialize(number, sides, opts = {})
		@brutal = opts[:brutal] || 0
		@number = number
		@sides = sides
		@opts = opts
		@bonus = 0
		@parent = nil
	end
	
	def roll
		parent_roll = 0
		parent_roll = @parent.roll if @parent
		unless @rolls
			@total_roll = 0
			@rolls = []
			@number.times do
				begin
					value = roll_one
					@rolls.push value
					raise Dice::ValueTooSmallError.new(value) if value < 1
					raise Dice::ValueTooLargeError.new(value) if value > @sides
				end until value > @brutal
				@total_roll += value
			end
		end
		return parent_roll + @total_roll + @bonus
	end
			
	def rolls
		roll unless @rolls
		parent_rolls = []
		parent_rolls = @parent.rolls if @parent
		parent_rolls + @rolls
	end

	def max
		dice = MaximumDice.new(@number, @sides, :brutal => @brutal)
		dice.parent = parent.max if parent
		return dice + @bonus
	end
	
	def dice
		parent_dice = ""
		parent_dice = "#{parent.dice} + " if parent
		
		dice = "#{@number}d#{@sides}"

		tags = ""
		tags = "[" + tag_descriptions.join(", ") + "]" unless tag_descriptions.empty?
		
		modifier = ""
		modifier = "+#{@bonus}" if @bonus > 0
		modifier = "#{@bonus}" if @bonus < 0

		parent_dice + dice + tags + modifier
	end
	
	def details
		"#{dice}; rolled #{full_roll_description}"
	end

	def to_i
		roll
	end
		
	def to_s
		"#{roll}"
	end
	
	def coerce(other)
		@coerced = true
		return self, other
	end
	
	def *(value)
		assert @rolls == nil, "Cannot multiply dice after they have been rolled"
		result = clone
		result.number = @number * value
		return result
	end
		
	def +(value)
		return add_dice(value) if value.is_a? Dice
		assert value.is_a?(Integer), "Can't add #{value.class} to Dice"
	
		roll
		result = clone
		result.bonus = @bonus + value
		return result
	end
	
	def -(value)
		assert value.is_a?(Integer), "Can't subtract #{value.class} from Dice"
		if @coerced
			@coerced = false
			return value - roll
		else
			return self + -value
		end
	end
	
	def <=>(value)
		if @coerced
			@coerced = false
			return value <=> roll
		else
			return roll <=> value
		end
	end
	
protected
	attr_accessor :parent
	
	def full_roll_description
		roll
		result = ""
		result = "#{parent.full_roll_description} + " if parent
		return result + roll_description
	end
	
	def roll_description; "#{@rolls.join(', ')}" end
		
	def tag_descriptions
		result = []
		result << "brutal #{@brutal}" if @brutal > 0
		result
	end		

private
	def add_dice(value)
		result = value.clone
		result.parent = self
		result
	end	
	
end		
	
class MinimumDice < Dice
	def roll_one
		return @brutal + 1
	end
end

class MaximumDice < Dice
	def roll_one
		return @sides
	end
		
	def roll_description
		"max"
	end
	
	def tag_descriptions
		super << "max"
	end
end

class FixedDice < Dice
	def roll_one
		@@roll_list.shift or raise Dice::NoMoreDiceError
	end
end	

class RandomDice < Dice
	def roll_one
		return 1 + rand(@sides)
	end
end

class Dice
	@@dice_logic = RandomDice

	def self.dice_logic
		@@dice_logic
	end
	
	def self.roll_list=(list)
		@@roll_list = list
	end
	

	def self.min(&proc)
		raise "Expected block in Dice.min" unless proc
		@@dice_logic = MinimumDice
		begin
			proc.call
		ensure
			@@dice_logic = RandomDice
		end
	end
	
	def self.max(&proc)
		raise "Expected block in Dice.max" unless proc
		@@dice_logic = MaximumDice
		begin
			proc.call
		ensure
			@@dice_logic = RandomDice
		end
	end
	
	def self.fix(list, &proc)
		raise "Expected block in Dice.fix" unless proc
		@@dice_logic = FixedDice
		@@roll_list = list
		begin
			proc.call
		ensure
			@@dice_logic = RandomDice
		end
	end
			
	class NoMoreDiceError < StandardError
	end
		
	class ValueTooSmallError < StandardError
		def initialize(value)
			super "Dice roll too small: #{value}"
		end
	end
	
	class ValueTooLargeError < StandardError
		def initialize(value)
			super "Dice roll too large: #{value}"
		end
	end
end

class Fixnum
	def dice
		"#{self}"
	end
	
	def roll
		[self]
	end
	
	def rolls
		[self]
	end
	
	def details
		"#{self}; not rolled"
	end
	
	def max
		self
	end

	def d2(opts = {})
		Dice.factory(self, 2, opts)
	end

	def d3(opts = {})
		Dice.factory(self, 3, opts)
	end

	def d4(opts = {})
		Dice.factory(self, 4, opts)
	end
	
	def d6(opts = {})
		Dice.factory(self, 6, opts)
	end
	
	def d8(opts = {})
		Dice.factory(self, 8, opts)
	end
	
	def d10(opts = {})
		Dice.factory(self, 10, opts)
	end
	
	def d12(opts = {})
		Dice.factory(self, 12, opts)
	end
	
	def d20(opts = {})
		Dice.factory(self, 20, opts)
	end
	
	def d100(opts = {})
		Dice.factory(self, 100, opts)
	end
end
