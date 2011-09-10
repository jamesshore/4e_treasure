class AssertionError < StandardError
end

def assert(boolean, message)
	raise AssertionError.new(message) unless boolean
end