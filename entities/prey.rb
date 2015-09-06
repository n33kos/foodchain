class Prey < LivingEntity

	def initialize
		super
		@speed = rand(1..3)
		if rand(0..100) < 50
			@sex = -1
		else
			@sex = 1
		end
		@density = 0.175 #Percentage
		@virility = 75
		@scale = $winwidth*0.015
		@min_scale = $winwidth*0.015
		@max_scale = $winwidth*0.025
		@satiation = 2
		@max_age = 1000
		@max_satiation = 20
		@color.red = rand(1..25)
		@color.green = rand(1..25)
		@color.blue = rand(1..155)
		@food_distance = $winwidth
		@cleanliness = 75
		@collision_quadrant = calculateQuadrant(@translation.x,@translation.y,$winwidth,$winheight)
		@collision_subquadrant = calculateSubQuadrant(@translation.x,@translation.y,$winwidth,@collision_quadrant)
	end

	def sexual_reproduction thefather
		#sexual reproduction
		if $Prey.length < $max_prey
			$Prey << Prey.new()
			$Prey[-1].translation.x(@translation.x+rand(-5..5))
			$Prey[-1].translation.y(@translation.y+rand(-5..5))
			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red = rand(0..1) == 0 ? self.color.red+rand(-2..2) : thefather.color.red+rand(-2..2)
			newcolor.green = rand(0..1) == 0 ? self.color.green+rand(-2..2) : thefather.color.green+rand(-2..2)
			newcolor.blue = rand(0..1) == 0 ? self.color.blue+rand(-2..2) : thefather.color.blue+rand(-2..2)
			newgenerationcount = @generation_count+1
			$Prey[-1].generation_count(newgenerationcount)
			$Prey[-1].color(newcolor)
			mutation thefather
			@satiation = @satiation/6
		end
	end


	def mutation thefather
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newspeed = rand(0..1) == 0 ? self.speed+(2*rand_array[0]).clamp(0,99999) : thefather.speed+(2*rand_array[0]).clamp(0,99999)
			$Prey[-1].speed(newspeed)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newvirility = rand(0..1) == 0 ? self.virility+(2*rand_array[0]).clamp(0,99999) : thefather.virility+(2*rand_array[0]).clamp(0,99999)
			$Prey[-1].virility(newvirility)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newmaxsatiation = rand(0..1) == 0 ? self.max_satiation+(2*rand_array[0]).clamp(0,99999) : thefather.max_satiation+(2*rand_array[0]).clamp(0,99999)
			$Prey[-1].max_satiation(newmaxsatiation)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newmaxscale = rand(0..1) == 0 ? self.max_scale+(2*rand_array[0]).clamp(0,99999) : thefather.max_scale+(2*rand_array[0]).clamp(0,99999)
			$Prey[-1].max_scale(newmaxscale)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newmaxage = rand(0..1) == 0 ? self.max_age+(2*rand_array[0]).clamp(0,99999) : thefather.max_age+(2*rand_array[0]).clamp(0,99999)
			$Prey[-1].max_age(newmaxage)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newdensity = rand(0..1) == 0 ? self.density+(rand(-0.02...0.02)*rand_array[0]).clamp(0.0001,99999) : thefather.density+(rand(-0.02...0.02)*rand_array[0]).clamp(0.0001,99999)
			$Prey[-1].density(newdensity)
		end
		if rand < 0.05
			rand_array = []
			16.times{rand_array << rand}
			rand_array.sort! { |x,y| y <=> x }

			newcleanliness = rand(0..1) == 0 ? self.cleanliness+(2*rand_array[0]).clamp(1,99999) : thefather.cleanliness+(2*rand_array[0]).clamp(1,99999)
			$Prey[-1].cleanliness(newcleanliness)	
		end
	end

	def processCollisions
		Thread.new{
			@collision_quadrant = calculateQuadrant(@translation.x,@translation.y,$winwidth,$winheight)
			@collision_subquadrant = calculateSubQuadrant(@translation.x,@translation.y,$winwidth,@collision_quadrant)
			touchedprey = $Prey.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale) }
			for entity in touchedprey do
				if entity != self
					courtship entity
					entityBounce entity
					break
				end
			end
			touchedplants = $Plants.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale) }
			for entity in touchedplants do
				gainsatisfaction
				beselfish entity
				entityBounce entity
				break
			end
			toucheddecay = $DecayingEntities.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale) }
			for entity in toucheddecay do
				parasiteCheck
				break
			end
		}.join
	end

	def chooseDirection
		closestFoodDistx = @food_distance
		closestFoodDisty = @food_distance
		closestFuckDistx = @food_distance
		closestFuckDisty = @food_distance
		closestPredatorDistx = @food_distance
		closestPredatorDisty = @food_distance

		predsInRange = $Predators.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @food_distance , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in predsInRange do
			xdist = entity.translation.x - @translation.x
			ydist = entity.translation.y - @translation.y
			if xdist.abs < closestPredatorDistx.abs && ydist.abs < closestPredatorDisty.abs
				closestPredatorDistx = xdist
				closestPredatorDisty = ydist
			end
		end

		foodInRange = $Plants.select { |entity| detectcollisions(@translation.x , @translation.y , @food_distance , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in foodInRange do
			xdist = entity.translation.x - @translation.x
			ydist = entity.translation.y - @translation.y
			if xdist.abs < closestFoodDistx.abs && ydist.abs < closestFoodDisty.abs && entity.predatorvalue < 1
				closestFoodDistx = xdist
				closestFoodDisty = ydist
			end
		end

		fucksInRange = $Prey.select { |entity| detectcollisions(@translation.x , @translation.y , @food_distance , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in fucksInRange do
			xdist = entity.translation.x - @translation.x
			ydist = entity.translation.y - @translation.y
			if xdist.abs < closestFuckDistx.abs && ydist.abs < closestFuckDisty.abs && entity.sex != @sex
				closestFuckDistx = xdist
				closestFuckDisty = ydist
			end
		end

		if closestPredatorDistx.abs < closestFoodDistx.abs && closestPredatorDisty.abs < closestFoodDisty.abs
			#Run from predator
			@velocity = Velocity.new(@velocity.x+(closestPredatorDistx*@speed)/@mass*4, @velocity.y+(closestPredatorDisty*@speed)/@mass*4)
		elsif @satiation < @max_satiation/1.2
			#Head toward food
			@velocity = Velocity.new(@velocity.x+(closestFoodDistx*@speed)/@mass, @velocity.y+(closestFoodDisty*@speed)/@mass)
		elsif @age > @maturity_age and @satiation > @max_satiation/1.2
			#Head toward fuck
			@velocity = Velocity.new(@velocity.x+(closestFuckDistx*@speed)/@mass, @velocity.y+(closestFuckDisty*@speed)/@mass)
		else
			#Head to center because we are confused.
			xdist = ($winwidth/2) - @translation.x
			ydist = ($winheight/2) - @translation.y
			@velocity = Velocity.new(@velocity.x+(xdist*@speed)/@mass, @velocity.y+(ydist*@speed)/@mass)
		end

	end

	def beselfish entity
		entity.satiation(entity.satiation-10)
	end

	def gainsatisfaction
		if @satiation <= @max_satiation
			@satiation += 10
		end
	end

	def courtship entity
		virilitycheck = rand(0..100)
		if @sex != 0 and entity.sex != @sex and @sex == -1 && @age > @maturity_age && entity.age > entity.maturity_age && virilitycheck < @virility
			sexual_reproduction entity
		end
	end

	def expendEnergy
		@age += 1
		@satiation -= 0.020
		if @age >= @max_age or @satiation <= 0
			#puts "#{self} has died"
			@isAlive = false
			$DecayingEntities << self
			$Prey.delete(self)
		end
	end

end