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
		@scale = 5 #Pixels
		@max_scale = 20 #Pixels
		@satiation = 2
		@max_age = 1000
		@max_satiation = 20
		@color.red = rand(1..25)
		@color.green = rand(1..25)
		@color.blue = rand(1..155)
		@food_distance = $winwidth
		@cleanliness = 75
	end

	def sexual_reproduction thefather
		#sexual reproduction
		if $Prey.length < $max_prey
			$Prey << Prey.new()
			$Prey[-1].translation.x(@translation.x+rand(-5..5))
			$Prey[-1].translation.y(@translation.y+rand(-5..5))
			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red = rand(0..1) == 0 ? self.color.red+rand(-10..10) : thefather.color.red+rand(-10..10)
			newcolor.green = rand(0..1) == 0 ? self.color.green+rand(-10..10) : thefather.color.green+rand(-10..10)
			newcolor.blue = rand(0..1) == 0 ? self.color.blue+rand(-10..10) : thefather.color.blue+rand(-10..10)
			newgenerationcount = @generation_count+1
			$Prey[-1].generation_count(newgenerationcount)
			$Prey[-1].color(newcolor)
			mutation thefather
			@satiation = @satiation/6
		end
	end


	def mutation thefather

		newspeed = rand(0..1) == 0 ? self.speed+rand(-1..1).clamp(0,99999) : thefather.speed+rand(-1..1).clamp(0,99999)
		$Prey[-1].speed(newspeed)

		newvirility = rand(0..1) == 0 ? self.virility+rand(-1..1).clamp(0,99999) : thefather.virility+rand(-1..1).clamp(0,99999)
		$Prey[-1].virility(newvirility)

		newmaxsatiation = rand(0..1) == 0 ? self.max_satiation+rand(-1..1).clamp(0,99999) : thefather.max_satiation+rand(-1..1).clamp(0,99999)
		$Prey[-1].max_satiation(newmaxsatiation)
		
		newmaxscale = rand(0..1) == 0 ? self.max_scale+rand(-1..1).clamp(0,99999) : thefather.max_scale+rand(-1..1).clamp(0,99999)
		$Prey[-1].max_scale(newmaxscale)

		newmaxage = rand(0..1) == 0 ? self.max_age+rand(-1..1).clamp(0,99999) : thefather.max_age+rand(-1..1).clamp(0,99999)
		$Prey[-1].max_age(newmaxage)

		newdensity = rand(0..1) == 0 ? self.density+rand(-0.01..0.01).clamp(0.0001,99999) : thefather.density+rand(-0.01..0.01).clamp(0.0001,99999)
		$Prey[-1].density(newdensity)

		newcleanliness = rand(0..1) == 0 ? self.cleanliness+rand(-1..1).clamp(1,99999) : thefather.cleanliness+rand(-1..1).clamp(1,99999)
		$Prey[-1].cleanliness(newcleanliness)

		#newfood_distance = rand(0..1) == 0 ? self.food_distance+rand(-@scale..@scale).clamp(1,99999) : thefather.food_distance+rand(-@scale..@scale).clamp(1,99999)
		#$Prey[-1].food_distance(newfood_distance)
	end

	def processCollisions
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
			@velocity = Velocity.new(@velocity.x+(closestPredatorDistx*@speed)/@mass*2, @velocity.y+(closestPredatorDisty*@speed)/@mass*-2)
		elsif @satiation < @max_satiation/1.2
			#Head toward food
			@velocity = Velocity.new(@velocity.x+(closestFoodDistx*@speed)/@mass, @velocity.y+(closestFoodDisty*@speed)/@mass)
		elsif @age > @maturity_age
			#Head toward fuck
			@velocity = Velocity.new(@velocity.x+(closestFuckDistx*@speed)/@mass, @velocity.y+(closestFuckDisty*@speed)/@mass)
		else
			@velocity = Velocity.new(@velocity.x+(closestFoodDistx*@speed)/@mass, @velocity.y+(closestFoodDisty*@speed)/@mass)
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