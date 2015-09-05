class LivingEntity

	def initialize
		@translation = Translation.new(rand(1..$winwidth),rand(1..$winheight))
		@velocity = Velocity.new(0,0)
		@mass = 1
		@density = 0.1 #Percentage
		@min_scale = 10 #Pixels
		@scale = 10 #Pixels
		@max_scale = 30 #Pixels
		@color = Gosu::Color.new(0xffffffff)
		@color.red = rand(1..255)
		@color.green = rand(1..255)
		@color.blue = rand(1..255)
		@color.alpha = 255
		@age = 0
		@max_age = 750
		@satiation = 20.0
		@max_satiation = 20.0
		@sex = 0 #female = -1 / male = 1 / asexual = 0
		@min_speed = 1
		@speed = 1
		@max_speed = 5
		@food_distance = 350
		@virility = 50 #Inverted percentage
		@isAlive = true
		@generation_count = 1
		@cleanliness = 50
		@collision_quadrant = 0
		@collision_subquadrant = 0
		@maturity_age = 40
	end
	
	def heartbeat
		addMomentum
		chooseDirection
		windowBounce
		loseMomentum
		processCollisions
		calculateScale
		calculateMass
		expendEnergy
		clampTranslation
		clampVelocity
	end

	def decay
		@color.alpha -= 2
		if @color.alpha <= 0
			$DecayingEntities.delete(self)
		end
	end

	def courtship entity
		if @sex != 0 and entity.sex != @sex and @sex == -1 && @age > (@max_age/6)
			sexual_reproduction entity
		elsif @sex == 0
			asexual_reproduction
		end
	end

	def sexual_reproduction thefather
		#sexual reproduction
		if rand(0..100) < @virility && $LivingEntities.length < $max_entities
			$LivingEntities << LivingEntity.new()
			$LivingEntities[-1].translation.x(self.translation.x+5)
			$LivingEntities[-1].translation.y(self.translation.y+5)
			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red = rand(0..1) == 0 ? self.color.red+rand(-10..10) : thefather.color.red+rand(-10..10)
			newcolor.green = rand(0..1) == 0 ? self.color.green+rand(-10..10) : thefather.color.green+rand(-10..10)
			newcolor.blue = rand(0..1) == 0 ? self.color.blue+rand(-10..10) : thefather.color.blue+rand(-10..10)
			$LivingEntities[-1].color(newcolor)
			newcount = [thefather.generation_count]
			$LivingEntities[-1].generation_count($LivingEntities[-1].generation_count+(self.generation_count+thefather.generation_count)/2)
			#puts "#{$LivingEntities[-1]} reproduced at generation #{$LivingEntities[-1].generation_count}"
		end
	end

	def asexual_reproduction
		#asexual reprouction
		if rand(0..100) < @virility && $LivingEntities.length < $max_entities
			$LivingEntities << LivingEntity.new()
			$LivingEntities[-1].translation.x(self.translation.x+5)
			$LivingEntities[-1].translation.y(self.translation.y+5)
			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red =self.color.red+rand(-10..10)
			newcolor.green =self.color.green+rand(-10..10)
			newcolor.blue =self.color.blue+rand(-10..10) 
			$LivingEntities[-1].color(newcolor)
			newcount = [self.generation_count]
			$LivingEntities[-1].generation_count($LivingEntities[-1].generation_count+self.generation_count)
			$LivingEntities[-1].sex(0)
			self.satiation(self.satiation/4)
		end
	end

	def processCollisions
		#Livingentities doesnt actually exist. This is a placeholder function and should be overridden
		for entity in $LivingEntities do
			didcollide = detectcollisions(@translation.x , @translation.y , @scale , entity.translation.x , entity.translation.y , entity.scale)
			if didcollide == true && entity != self && entity.isAlive && @isAlive
				gainsatisfaction
				beselfish entity
				courtship entity
				entityBounce entity
			end
		end
	end

	def parasiteCheck
		if rand(0..100) < @cleanliness && $Parasites.length < $max_parasites
			$Parasites << Parasite.new()
			newcolor = Gosu::Color.new(0xffffffff)
			newcolor.red = self.color.red+rand(-40..40)
			newcolor.green = self.color.green+rand(-40..40)
			newcolor.blue = self.color.blue+rand(-40..40)
			$Parasites[-1].color(newcolor)
			$Parasites[-1].parent_entity(self)
		end
	end

	def beselfish entity
		entity.satiation(entity.satiation-5)
	end

	def gainsatisfaction
		if @satiation <= @max_satiation
			@satiation += 10
		end
	end

	def expendEnergy
		@age += 1
		@satiation -= 0.01
		if @age >= @max_age or @satiation <= 0
			#puts "#{self} has died"
			$DecayingEntities << self
			$LivingEntities.delete(self)
			@isAlive = false
		end
	end

	def chooseDirection
		xval = rand(-2..2)*@speed
		yval = rand(-2..2)*@speed
		@velocity = Velocity.new(@velocity.x+xval, @velocity.y+yval)
	end

	def addMomentum
		@translation.x(@translation.x+@velocity.x)
		@translation.y(@translation.y+@velocity.y)
	end

	def clampTranslation
		@translation.x(@translation.x.clamp(0, $winwidth))
		@translation.y(@translation.y.clamp(0, $winheight))
	end

	def clampVelocity
		@velocity.x(@velocity.x.clamp(-@speed,@speed))
		@velocity.y(@velocity.y.clamp(-@speed,@speed))
	end

	def generation_count(generation_count = nil)
		if generation_count
			@generation_count = generation_count
		else
			return @generation_count
		end
	end

	def calculateScale
		@scale = (@max_scale*(@satiation/@max_satiation)).clamp(@min_scale, @max_scale)
	end

	def calculateMass
		@mass = @scale * @density
	end

	def loseMomentum
		@velocity.x(@velocity.x/@mass)
		@velocity.y(@velocity.y/@mass)
	end

	def windowBounce
		if @translation.x <= 0 || @translation.x >= $winwidth
			@velocity.x(@velocity.x*-1)
		end
		if @translation.y <= 0 || @translation.y >= $winheight
			@velocity.y(@velocity.y*-1)
		end
	end

	def entityBounce entity
		@translation.x(@translation.x + (@translation.x-entity.translation.x)/2)
		@translation.y(@translation.y + (@translation.y-entity.translation.y)/2)
	end

	#---------------------GETSET------------------------
	def age(ageincrement = nil)
		if ageincrement
			@age = ageincrement
		else
			return @age
		end
	end

	def max_age(max_ageincrement = nil)
		if max_ageincrement
			@max_age = max_ageincrement
		else
			return @max_age
		end
	end

	def satiation(satiationincrement = nil)
		if satiationincrement
			@satiation = satiationincrement
		else
			return @satiation
		end
	end

	def max_satiation(max_satiationincrement = nil)
		if max_satiationincrement
			@max_satiation = max_satiationincrement
		else
			return @max_satiation
		end
	end


	def speed(speedincrement = nil)
		if speedincrement
			@speed = speedincrement
		else
			return @speed
		end
	end

	def max_speed(max_speedincrement = nil)
		if max_speedincrement
			@max_speed = max_speedincrement
		else
			return @max_speed
		end
	end

	def min_speed(min_speedincrement = nil)
		if min_speedincrement
			@min_speed = min_speedincrement
		else
			return @min_speed
		end
	end

	def virility(virilityincrement = nil)
		if virilityincrement
			@virility = virilityincrement
		else
			return @virility
		end
	end

	def color(color = nil)
		if color
			@color = color
		else
			return @color
		end
	end

	def translation(translation = nil)
		if translation
			@translation = translation
		else
			return @translation
		end
	end

	def velocity(velocity = nil)
		if velocity
			@velocity = velocity
		else
			return @velocity
		end
	end

	def scale(scale = nil)
		if scale
			@scale = scale
		else
			return @scale
		end
	end

	def max_scale(max_scale = nil)
		if max_scale
			@max_scale = max_scale
		else
			return @max_scale
		end
	end

	def sex(sex = nil)
		if sex
			@sex = sex
		else
			return @sex
		end
	end

	def food_distance(food_distance = nil)
		if food_distance
			@food_distance = food_distance
		else
			return @food_distance
		end
	end

	def density(density = nil)
		if density
			@density = density
		else
			return @density
		end
	end

	def isAlive(isAlive = nil)
		if isAlive
			@isAlive = isAlive
		else
			return @isAlive
		end
	end

	def cleanliness(cleanliness = nil)
		if cleanliness
			@cleanliness = cleanliness
		else
			return @cleanliness
		end
	end

	def collision_quadrant(collision_quadrant = nil)
		if collision_quadrant
			@collision_quadrant = collision_quadrant
		else
			return @collision_quadrant
		end
	end

	def collision_subquadrant(collision_subquadrant = nil)
		if collision_subquadrant
			@collision_subquadrant = collision_subquadrant
		else
			return @collision_subquadrant
		end
	end

	def maturity_age(maturity_age = nil)
		if maturity_age
			@maturity_age = maturity_age
		else
			return @maturity_age
		end
	end

end