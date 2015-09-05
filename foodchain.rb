require 'gosu'
require './utils'
require './vectors'
require './entities/livingentity'
require './entities/plant'
require './entities/parasite'
require './entities/prey'
require './entities/predator'

#---------------------------------------------------------------------
#------------------------GAME WINDOW CLASS----------------------------
class GameWindow < Gosu::Window
  
  def initialize
    $winwidth = Gosu.screen_width/2
  	$winheight = Gosu.screen_height/2
    super($winwidth, $winheight, false, 10)
    self.caption = "Food Chain Simulator v1.1"
    $font = Gosu::Font.new(self, "Arial", 18)
  	$max_plants = 200
    $max_prey = 200
    $max_predators = 200
    $max_parasites = 200
    $max_decaying = 100
    $DecayingEntities = []
    $Plants = []
    $Plant_Max_Generation = 1
    $Prey = []
    $Prey_Max_Generation = 1
    $Predators = []
    $Predators_Max_Generation = 1
    $Parasites = []
    $Parasites_Max_Generation = 1
    $decayColor = Gosu::Color.new(0xffffffff)
    100.times{
      temp_entity = Plant.new()
      temp_entity.satiation(temp_entity.max_satiation)
      temp_entity.age(rand(1..temp_entity.max_age))
      $Plants << temp_entity
    }
    100.times{
      temp_entity = Prey.new()
      temp_entity.satiation(temp_entity.max_satiation)
      temp_entity.age(rand(1..temp_entity.max_age))
      $Prey << temp_entity
    }
    20.times{
      temp_entity = Predator.new()
      $Predators << temp_entity
    }
	end

  def update
    	for entity in $Plants do
        entity.heartbeat
        if entity.generation_count > $Plant_Max_Generation
          $Plant_Max_Generation = entity.generation_count
          #drawStatsToConsole
        end
    	end
      for entity in $Prey do
        entity.heartbeat
        if entity.generation_count > $Prey_Max_Generation
          $Prey_Max_Generation = entity.generation_count
          #drawStatsToConsole
        end
      end
      for entity in $Predators do
        entity.heartbeat
        if entity.generation_count > $Predators_Max_Generation
          $Predators_Max_Generation = entity.generation_count
          #drawStatsToConsole
        end
      end
      for entity in $Parasites do
        entity.heartbeat
      end
      if $DecayingEntities.length > $max_decaying
        removecount = $DecayingEntities.length - $max_decaying
        $DecayingEntities = $DecayingEntities.drop(removecount)
      end
      for entity in $DecayingEntities do
        entity.decay
      end
  end

  def draw
    drawscene
    drawStats
  end

  def drawscene
    for entity in $DecayingEntities do
      entitycolor = entity.color
      entitycolor.red = 255
      entitycolor.green = 255
      entitycolor.blue = 255
      x = entity.translation.x
      y = entity.translation.y
      entityHalf = entity.scale/2
      draw_line(x-(entityHalf), y-(entityHalf), entitycolor, x+(entityHalf), y+(entityHalf), entitycolor, 0)
      draw_line(x+(entityHalf), y-(entityHalf), entitycolor, x-(entityHalf), y+(entityHalf), entitycolor, 0)
      draw_line(x, y-(entityHalf), entitycolor, x, y+(entityHalf), entitycolor, 0)
      draw_line(x-(entityHalf), y, entitycolor, x+(entityHalf), y, entitycolor, 0)
    end
    for entity in $Plants do
      entitycolor = entity.color
      x = entity.translation.x
      y = entity.translation.y
      entityHalf = entity.scale/2
      draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
    end
    for entity in $Prey do
      entitycolor = entity.color
      x = entity.translation.x
      y = entity.translation.y
      entitySize = entity.scale
      entityHalf = entity.scale/2
      draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
    end
    for entity in $Predators do
      entitycolor = entity.color
      x = entity.translation.x
      y = entity.translation.y
      entityHalf = entity.scale/2
      draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
    end
    for entity in $Parasites do
      entitycolor = entity.color
      x = entity.translation.x
      y = entity.translation.y
      entityHalf = entity.scale/2
      draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
    end
  end

  def drawStats
    $font.draw("Plants alive      : #{$Plants.length} -- Generation #{$Plant_Max_Generation}", 5, 5, 1,0.85,0.85,0xffffffff)
    $font.draw("Prey alive         : #{$Prey.length} -- Generation #{$Prey_Max_Generation}", 5, 15, 1,0.85,0.85,0xffffffff)
    $font.draw("Predator alive   : #{$Predators.length} -- Generation #{$Predators_Max_Generation}", 5, 25, 1,0.85,0.85,0xffffffff)
    $font.draw("Parasites alive  : #{$Parasites.length}", 5, 35, 1,0.85,0.85,0xffffffff)
  end

  def drawStatsToConsole
    #puts "Plants alive     : #{$Plants.length} -- Generation #{$Plant_Max_Generation}"
    #puts "Prey alive       : #{$Prey.length} -- Generation #{$Prey_Max_Generation}"
    #puts "Predator alive   : #{$Predators.length} -- Generation #{$Predators_Max_Generation}"
    #puts "Parasites alive  : #{$Parasites.length}"
    #puts "Decaying Entities: #{$DecayingEntities.length}"
    #puts "--------------------------------------------------"
  end

  def button_down(id)
    if id == Gosu::KbEscape then
      exit
    end
  end

end

#Start That Shizz
$window = GameWindow.new
$window.show