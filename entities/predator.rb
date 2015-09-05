class Predator < LivingEntity

	def initialize
		super
		@speed = rand(2..4)
		if rand(0..100) < 50
			@sex = -1
		else
			@sex = 1
		end
		@density = 0.30 #Percentage
		@virility = 30
		@min_scale = 15 #Pixels
		@scale = 15 #Pixels
		@max_scale = 20 #Pixels
		@max_age = 3000
		@satiation = 5
		@max_satiation = 50
		@color.red = rand(1..255)
		@color.green = rand(1..25)
		@color.blue = rand(1..25)
		@food_distance = $winwidth
		@cleanliness = 60
	end

	def sexual_reproduction thefather
		#sexual reproduction
		if $Predators.length < $max_predators
			$Predators << Predator.new()
			$Predators[-1].translation.x(@translation.x)
			$Predators[-1].translation.y(@translation.y)

			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red = rand(0..1) == 0 ? self.color.red+rand(-10..10) : thefather.color.red+rand(-10..10)
			newcolor.green = rand(0..1) == 0 ? self.color.green+rand(-10..10) : thefather.color.green+rand(-10..10)
			newcolor.blue = rand(0..1) == 0 ? self.color.blue+rand(-10..10) : thefather.color.blue+rand(-10..10)
			$Predators[-1].color(newcolor)

			newgenerationcount = self.generation_count+$Predators[-1].generation_count
			$Predators[-1].generation_count(newgenerationcount)
			mutation thefather
			@satiation = @satiation/6
		end
	end

	def mutation thefather

		newspeed = rand(0..1) == 0 ? self.speed+rand(-1..1).clamp(0,99999) : thefather.speed+rand(-1..1).clamp(0,99999)
		$Predators[-1].speed(newspeed)

		newvirility = rand(0..1) == 0 ? self.virility+rand(-1..1).clamp(0,99999) : thefather.virility+rand(-1..1).clamp(0,99999)
		$Predators[-1].virility(newvirility)

		newmaxsatiation = rand(0..1) == 0 ? self.max_satiation+rand(-1..1).clamp(0,99999) : thefather.max_satiation+rand(-1..1).clamp(0,99999)
		$Predators[-1].max_satiation(newmaxsatiation)
		
		newmaxscale = rand(0..1) == 0 ? self.max_scale+rand(-1..1).clamp(0,99999) : thefather.max_scale+rand(-1..1).clamp(0,99999)
		$Predators[-1].max_scale(newmaxscale)

		newmaxage = rand(0..1) == 0 ? self.max_age+rand(-1..1).clamp(0,99999) : thefather.max_age+rand(-1..1).clamp(0,99999)
		$Predators[-1].max_age(newmaxage)

		newdensity = rand(0..1) == 0 ? self.density+rand(-0.01..0.01).clamp(0.0001,99999) : thefather.density+rand(-0.01..0.01).clamp(0.0001,99999)
		$Predators[-1].density(newdensity)

		newcleanliness = rand(0..1) == 0 ? self.cleanliness+rand(-1..1).clamp(1,99999) : thefather.cleanliness+rand(-1..1).clamp(1,99999)
		$Predators[-1].cleanliness(newcleanliness)

		#newfood_distance = rand(0..1) == 0 ? self.food_distance+rand(-@scale..@scale).clamp(1,99999) : thefather.food_distance+rand(-@scale..@scale).clamp(1,99999)
		#$Predators[-1].food_distance(newfood_distance)
	end

	def processCollisions
		@collision_quadrant = calculateQuadrant(@translation.x,@translation.y,$winwidth,$winheight)
		@collision_subquadrant = calculateSubQuadrant(@translation.x,@translation.y,$winwidth,@collision_quadrant)
		touchedpredators = $Predators.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in touchedpredators do
			if entity != self
				courtship entity
				entityBounce entity
				break
			end
		end
		touchedprey = $Prey.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in touchedprey do
			gainsatisfaction
			beselfish entity
			entityBounce entity
			break
		end
		touchedplants = $Plants.select { |entity| (entity.collision_subquadrant == @collision_subquadrant) && (entity.collision_quadrant == @collision_quadrant) && detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in touchedplants do
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
		
		foodInRange = $Prey.select { |entity| detectcollisions(@translation.x , @translation.y , @food_distance , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in foodInRange do
			xdist = entity.translation.x - @translation.x
			ydist = entity.translation.y - @translation.y
			if (xdist.abs < closestFoodDistx.abs && ydist.abs < closestFoodDisty.abs)
				closestFoodDistx = xdist
				closestFoodDisty = ydist
			end
		end
		
		fucksInRange = $Predators.select { |entity| detectcollisions(@translation.x , @translation.y , @food_distance , entity.translation.x , entity.translation.y , entity.scale) }
		for entity in fucksInRange do
			xdist = entity.translation.x - @translation.x
			ydist = entity.translation.y - @translation.y
			if (xdist.abs < closestFuckDistx.abs && ydist.abs < closestFuckDisty.abs && entity.sex != @sex)
				closestFuckDistx = xdist
				closestFuckDisty = ydist
			end
		end

		if @satiation < @max_satiation/1.2
			@velocity = Velocity.new(@velocity.x+(closestFoodDistx*@speed)/@mass, @velocity.y+(closestFoodDisty*@speed)/@mass)
		elsif @age > @maturity_age
			@velocity = Velocity.new(@velocity.x+(closestFuckDistx*@speed)/@mass, @velocity.y+(closestFuckDisty*@speed)/@mass)
		else
			@velocity = Velocity.new(@velocity.x+(closestFoodDistx*@speed)/@mass, @velocity.y+(closestFoodDisty*@speed)/@mass)
		end
	end

	def beselfish entity
		entity.satiation(entity.satiation-20)
	end

	def gainsatisfaction
		if @satiation <= @max_satiation
			@satiation += 20
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
		@satiation -= 0.2
		if @age >= @max_age or @satiation <= 0
			#puts "#{self} has died"
			@isAlive = false
			$DecayingEntities << self
			$Predators.delete(self)
		end
	end

end