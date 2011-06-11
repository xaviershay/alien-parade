require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)
    self.caption = "Alien Parade"

    @alien = Alien.new(self)
    @alien.warp(400, 600)
  end

  def update
    @alien.wander
    @alien.move
  end

  def draw
    @alien.draw
  end

end

class Alien
  def initialize(window)
    @image = Gosu::Image.new(window, "starfighter-small.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @angle = 0
    @vel_x = 2
    @aim = 90
    @ideal  = 90 
    @speed  = 6
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def draw
    @image.draw_rot(@x, @y, 1, 180 + @angle)
  end

  def wander
    if rand < 0.1
      diff = (@ideal - @angle).abs
      chance_of_turning_towards = diff / 180.0
      direction = @angle < @ideal ? 1 : -1
      if rand <= chance_of_turning_towards
        @aim = @angle + 12 * direction
      else
        @aim = @angle - 12 * direction
      end
    end

    x = rand
    if rand < 0.4
      @speed -= 0.2
    elsif rand >= 0.6
      @speed += 0.2
    end
    @speed = [1, @speed].max

    if @angle < @aim
      @angle += 1
    else
      @angle -= 1
    end
  end

  def move
    @x += Gosu::offset_x(@angle, @speed)
    @y += Gosu::offset_y(@angle, @speed)
  end
end

window = GameWindow.new
window.show
