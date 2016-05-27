class Plant < LivingEntity

	def initialize
		super
		@sex = 0
		@virility = 1
		@color.red = rand(1..100)
		@color.green = rand(1..255)
		@color.blue = rand(1..100)
		@satiation = 1
		@max_satiation = 20
		@min_scale = $winwidth*0.002
		@max_scale = $winwidth*0.020
		@density = 0.1
		@age = 1
		@max_age = 500
		@overgrowthlimit = 2
		@reproduction_distance = 2000
		@predatorvalue = 0
		@virility = 35
		@collision_quadrant = calculateQuadrant(@translation.x,@translation.y,$winwidth,$winheight)
		@collision_subquadrant = calculateSubQuadrant(@translation.x,@translation.y,$winwidth,@collision_quadrant)
	end
	
	def heartbeat
		calculateMass
		calculateScale
		expendEnergy
		gainsatisfaction
		predatorvalue
		for entity in $DecayingEntities do
			xdist =  @translation.x-entity.translation.x
			ydist =  @translation.y-entity.translation.y
			if xdist < @reproduction_distance && ydist < @reproduction_distance
				asexual_reproduction entity
				break
			end
		end
	end

	def asexual_reproduction entity
		#asexual reprouction
		if rand(0..1000) < @virility && $Plants.length < $max_plants
			newx = entity.translation.x
			newy = entity.translation.y
			$Plants << Plant.new()
			$Plants[-1].translation.x(newx)
			$Plants[-1].translation.y(newy)

			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red = @color.red+rand(-2..2)
			newcolor.green = @color.green+rand(-2..2)
			newcolor.blue = @color.blue+rand(-2..2) 
			$Plants[-1].color(newcolor)

			newgenerationcount = $Plants[-1].generation_count+@generation_count
			$Plants[-1].generation_count(newgenerationcount)
			
			$Plants[-1].collision_quadrant(calculateQuadrant(entity.translation.x,entity.translation.y,$winwidth,$winheight))
			$Plants[-1].collision_subquadrant(calculateSubQuadrant(entity.translation.x,entity.translation.y,$winwidth,$Plants[-1].collision_quadrant))

			mutation entity
			self.satiation(self.satiation/2)

			$DecayingEntities.delete(entity)
		end
	end

	def mutation entity
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newvirility = @virility+(2*rand_array[0]).clamp(0,99999)
			$Plants[-1].virility(newvirility)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newmaxsatiation = @max_satiation+(2*rand_array[0]).clamp(0,99999)
			$Plants[-1].max_satiation(newmaxsatiation)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newmaxscale = @max_scale+(2*rand_array[0]).clamp(0,99999)
			$Plants[-1].max_scale(newmaxscale)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newmaxage = @max_age+(2*rand_array[0]).clamp(0,99999)
			$Plants[-1].max_age(newmaxage)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newovergrowthlimit = @overgrowthlimit+(2*rand_array[0]).clamp(0,99999)
			$Plants[-1].overgrowthlimit(newovergrowthlimit)
		end
	end

	def predatorvalue
		nearbyPredators = $Predators.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale*4 , entity.translation.x , entity.translation.y , entity.scale*4) }
		@predatorvalue = nearbyPredators.length
	end

	def expendEnergy
		@age += 1
		@satiation -= 0.15
		if @age >= @max_age or @satiation <= 0
			$DecayingEntities << self
			$Plants.delete(self)
		end
	end

	def gainsatisfaction
		if @satiation <= @max_satiation
			@satiation += 0.5
		end
	end

	def overgrowthlimit(overgrowthlimit = nil)
		if overgrowthlimit
			@overgrowthlimit = overgrowthlimit
		else
			return @overgrowthlimit
		end
	end

	def predatorvalue(predatorvalue = nil)
		if predatorvalue
			@predatorvalue = predatorvalue
		else
			return @predatorvalue
		end
	end

end