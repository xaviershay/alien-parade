require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)
    self.caption = "Alien Parade"

    reset
  end

  def reset
    @leader = Alien.new(self)
    @leader.warp(400, 600)

    @followers = 5.times.map {
      alien = Alien.new(self)
      alien.warp(400 + (rand - 0.5) * 200, 700 + (rand - 0.5) * 100)
      alien
    }
  end

  def update
    @leader.wander
    @leader.move
    @followers.each {|x| x.follow([@leader] + @followers); x.wander }
    @followers.each(&:move)

    if ([@leader] + @followers).all?(&:off_screen?)
      reset
    end
  end

  def draw
    @leader.draw
    @followers.each(&:draw)
  end

end

class Alien
  attr_reader :angle

  def initialize(window)
    @image = Gosu::Image.new(window, "starfighter-small.png", false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @angle = 0
    @vel_x = 2
    @aim = 90
    @ideal  = 90 
    @speed  = 6
  end

  def off_screen?
    @y < -40
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def draw
    @image.draw_rot(@x, @y, 1, 180 + @angle)
  end

  def follow(others)
    aim  = others.map(&:angle).inject(0) {|a, b| a + b} / others.size.to_f

    if rand < 0.8
      if @angle < aim
        @angle += 1.0 
      else
        @angle -= 1.0
      end
    end
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
    elsif rand >= 0.5
      @speed += 0.2
    end
    @speed = [2, @speed].max

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
