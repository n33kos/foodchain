class Parasite < LivingEntity

	def initialize
		super
		@density = 0.03 #Percentage
		@min_scale = 1 #Pixels
		@max_scale = 3 #Pixels
		@age = 0
		@max_age = 500
		@satiation = 1
		@max_satiation = 10
		@sex = 0
		@virility = 90 #Inverted percentage
		@generation_count = 1
		@parent_entity = nil
	end

	def heartbeat
		setMaxScale
		setMaxAge
		calculateScale
		calculateMass
		moveWithParent
		eatParent
		expendEnergy
	end

	def eatParent
		beselfish
		gainsatisfaction
	end

	def setMaxScale
		if @parent_entity
			@max_scale = @parent_entity.max_scale-2
		end
	end

	def setMaxAge
		if @parent_entity
			@max_age = @parent_entity.max_age
		end
	end

	def moveWithParent
		if @parent_entity
			@translation.x(@parent_entity.translation.x)
			@translation.y(@parent_entity.translation.y)
		end
	end

	def spreadParasite entity
		@parent_entity = entity
	end

	def beselfish
		if @parent_entity && @parent_entity.isAlive
			@parent_entity.satiation(@parent_entity.satiation-0.05)
		elsif @parent_entity && !@parent_entity.isAlive
			@isAlive = false
			$Parasites.delete(self)			
		end
	end

	def gainsatisfaction
		if @satiation <= @max_satiation && @parent_entity
			@satiation += 0.075
		end
	end

	def expendEnergy
		@age += 1
		@satiation -= 0.05
		if @age >= @max_age or @satiation <= 0
			@isAlive = false
			$Parasites.delete(self)
		end
	end

	def parent_entity(parent_entity = nil)
		if parent_entity
			@parent_entity = parent_entity
		else
			return @parent_entity
		end
	end

end