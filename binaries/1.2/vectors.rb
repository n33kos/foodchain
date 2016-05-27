class Translation 
	def initialize xval=nil, yval=nil
		@x_val, @y_val = 0 , 0
		if xval
			@x_val = xval
		end
		if yval
			@y_val = yval
		end
	end
	def x xval = nil
		if xval
			@x_val = xval
		else
			return @x_val
		end
	end
	def y yval = nil
		if yval
			@y_val = yval
		else
			return @y_val
		end
	end
end

class Velocity 
	def initialize xvel=nil, yvel=nil
		@x_vel, @y_vel = 0 , 0
		if xvel
			@x_vel = xvel
		end
		if yvel
			@y_vel = yvel
		end
	end
	def x xvel = nil
		if xvel
			@x_vel = xvel
		else
			return @x_vel
		end
	end
	def y yvel = nil
		if yvel
			@y_vel = yvel
		else
			return @y_vel
		end
	end
end

class Scale 
	def initialize xval=nil, yval=nil
		@x_vel, @y_vel = 0 , 0
		if xval
			@x_vel = xval
		end
		if yval
			@y_vel = yval
		end
	end
	def x xval = nil
		if xval
			@x_vel = xval
		else
			return @x_vel
		end
	end
	def y yval = nil
		if yval
			@y_vel = yval
		else
			return @y_vel
		end
	end
end

class Rotation 
	def initialize rotation=nil
		if rotation
			@rotation = rotation
		end
	end
	def rotation rotation = nil
		if rotation
			@rotation = rotation
		else
			return @rotation
		end
	end
end