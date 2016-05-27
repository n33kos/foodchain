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
    #$winwidth = Gosu.screen_width/2
  	#$winheight = Gosu.screen_height/2
    $winwidth = 800
    $winheight = 800
    super($winwidth, $winheight, false, 10)
    self.caption = "Food Chain Simulator v1.2"
    $font = Gosu::Font.new(self, "Arial", 14)
    $cursor = Gosu::Image.new(self, "Cursor.png", false)

  	$max_plants = 100
    $max_prey = 100
    $max_predators = 100
    $max_parasites = 100
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
    50.times{
      temp_entity = Plant.new()
      temp_entity.satiation(temp_entity.max_satiation)
      temp_entity.age(rand(1..temp_entity.max_age))
      $Plants << temp_entity
    }
    50.times{
      temp_entity = Prey.new()
      temp_entity.satiation(temp_entity.max_satiation)
      temp_entity.age(rand(1..temp_entity.max_age))
      $Prey << temp_entity
    }
    15.times{
      temp_entity = Predator.new()
      $Predators << temp_entity
    }
	end

  def update
      Thread.new{
      	for entity in $Plants do
          entity.heartbeat
          if entity.generation_count > $Plant_Max_Generation
            $Plant_Max_Generation = entity.generation_count
            #drawStatsToConsole
          end
      	end
      }.join
      Thread.new{
        for entity in $Prey do
          entity.heartbeat
          if entity.generation_count > $Prey_Max_Generation
            $Prey_Max_Generation = entity.generation_count
            #drawStatsToConsole
          end
        end
      }.join
      Thread.new{
        for entity in $Predators do
          entity.heartbeat
          if entity.generation_count > $Predators_Max_Generation
            $Predators_Max_Generation = entity.generation_count
            #drawStatsToConsole
          end
        end
      }.join
      Thread.new{
        for entity in $Parasites do
          entity.heartbeat
        end
      }.join
      Thread.new{
        if $DecayingEntities.length > $max_decaying
          removecount = $DecayingEntities.length - $max_decaying
          $DecayingEntities = $DecayingEntities.drop(removecount)
        end
        for entity in $DecayingEntities do
          entity.decay
        end
      }.join
  end

  def draw
    $cursor.draw($window.mouse_x,$window.mouse_y,9999)
    drawscene
    drawStats
  end

  def drawscene
    Thread.new{
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
    }.join
    Thread.new{
      for entity in $Plants do
        entitycolor = entity.color
        x = entity.translation.x
        y = entity.translation.y
        entityHalf = entity.scale/2
        draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
      end
    }.join
    Thread.new{
      for entity in $Prey do
        entitycolor = entity.color
        x = entity.translation.x
        y = entity.translation.y
        entitySize = entity.scale
        entityHalf = entity.scale/2
        draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
      end
    }.join
    Thread.new{
      for entity in $Predators do
        entitycolor = entity.color
        x = entity.translation.x
        y = entity.translation.y
        entityHalf = entity.scale/2
        draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
      end
    }.join
    Thread.new{
      for entity in $Parasites do
        entitycolor = entity.color
        x = entity.translation.x
        y = entity.translation.y
        entityHalf = entity.scale/2
        draw_quad(x-(entityHalf), y-(entityHalf), entitycolor, x+entityHalf, y-(entityHalf), entitycolor, x+entityHalf, y+entityHalf, entitycolor, x-(entityHalf), y+entityHalf, entitycolor, 0)
      end
    }.join
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
    if id == Gosu::KbSpace then
      #Open a new universe - (buggy)
      $newwindow = GameWindow.new
      $newwindow.show
    end
    if id == Gosu::MsLeft then
      #create new predator at mouse location
      temp_entity = Predator.new()
      temp_entity.translation(Translation.new($window.mouse_x,$window.mouse_y))
      $Predators << temp_entity
    end
    if id == Gosu::MsRight then
      #create new prey at mouse location
      temp_entity = Prey.new()
      temp_entity.translation(Translation.new($window.mouse_x,$window.mouse_y))
      $Prey << temp_entity
    end
  end

end

#Start That Shizz
$window = GameWindow.new
$window.show