require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super(800, 600, false)
    self.caption = "Alien Parade"

    @followers = []
  end

  def reset
    @followers = 50.times.map {
      alien = Alien.new(self)
      alien.warp(400 + (rand - 0.5) * 200, 900 + (rand - 0.5) * 600)
      alien
    }
  end

  def update
    maybe_add_new_alien
    @followers.each {|x| x.follow(@followers); x.wander }
    @followers.each(&:move)
    @followers.delete_if(&:off_screen?)
  end

  def draw
    @followers.each(&:draw)
  end

  def maybe_add_new_alien
    if rand < 0.3
      alien = Alien.new(self)
      alien.warp(400 + (rand - 0.5) * 200, 900 + (rand - 0.5) * 600)
      @followers << alien
    end
  end
end

class Alien
  attr_reader :angle, :speed

  def initialize(window)
    @image = Gosu::Image.new(window, Dir["alien-*.png"].sample, false)
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @angle = 0
    @vel_x = 2
    @aim = 0
    @ideal  = 0 
    @speed  = 8
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

    speed  = others.map(&:speed).inject(0) {|a, b| a + b} / others.size.to_f

    if rand < 0.8
      if @speed < speed
        @speed += 0.05
      else
        @speed -= 0.05
      end
    end
  end

  def wander
    if rand < 0.1
      diff = (@ideal - @angle).abs
      chance_of_turning_towards = diff / 180.0
      direction = @angle < @ideal ? 1 : -1
      if rand <= chance_of_turning_towards
        @aim = @angle - 12 * direction
      else
        @aim = @angle + 12 * direction
      end
    end

    x = rand
    if rand < 0.4
      @speed -= 0.2
    elsif rand >= 0.5
      @speed += 0.2
    end
    @speed = [3, @speed].max

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
