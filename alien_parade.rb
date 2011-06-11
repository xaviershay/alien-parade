require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = "Alien Parade"

    @followers = []
    x = 130
    @letters = self.caption.upcase.chars.map.with_index do |char, index|
      letter = Letter.new(self, char, x, index + 6)
      x += letter.width
      letter
    end
    @letters.last.add_arrived_at_center_observer do
      self.stage = 1
    end
    @tap_to_start = Gosu::Image.from_text(self, "TAP TO START", './amerika-sans.ttf', 24, 25, width, :center)
    @stage = 0
    @delay = 50
    @ticks = 0
    @alien_images = Dir["alien-*.png"].map do |image|
      Gosu::Image.new(self, image, false)
    end
  end

  def reset
    @followers = 50.times.map {
      alien = Alien.new(self)
      alien.warp(400 + (rand - 0.5) * 200, 900 + (rand - 0.5) * 600)
      alien
    }
  end

  def update
    @ticks += 1
    @letters.each(&:update)
    @letters.delete_if(&:off_top?)
    if @stage == 2
      if @delay > 0
        @delay -= 1
      else
        maybe_add_new_alien
        @followers.each {|x| x.follow(@followers); x.wander }
        @followers.each(&:move)
        @followers.delete_if(&:off_top?)
      end
    end
  end

  def draw
    @followers.each(&:draw)
    @letters.each(&:draw)
    if @stage == 1
      if (@ticks / 30) % 2 == 0
        @tap_to_start.draw(0, 350, 0)
      end
    end
  end

  def maybe_add_new_alien
    if rand < 0.3
      alien = Alien.new(self, @alien_images.sample)
      alien.warp(400 + (rand - 0.5) * 200, 900 + (rand - 0.5) * 600)
      @followers << alien
    end
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    else
      self.stage = 2
    end
  end

  def stage=(value)
    @stage = value
    @ticks = 0
    @letters.each do |x|
      x.stage = @stage
    end
  end
end

class Letter
  LETTER_FULL_WIDTH = 48

  attr_accessor :y_offset

  def initialize(window, letter, x, delay)
    @window = window
    @delay = delay * 5
    @original_delay = @delay
    @y_offset = 600 
    @x_offset = x

    @letter_widths = {
      'I' => 20,
    }
    @image = Gosu::Image.from_text(window, letter, './amerika-sans.ttf', 64, 25, @letter_widths[letter] || LETTER_FULL_WIDTH, :center)
    @ticks = 0
    @stage = 0
    @arrived_at_center_observers = []
    @notified_observers = false
  end

  def stage=(value)
    @stage = value
    @delay = @original_delay
  end

  def add_arrived_at_center_observer(&block)
    @arrived_at_center_observers << block
  end

  def update
    if @delay > 0
      @delay -= 1
    else
      if (@y_offset > 250 && @stage == 0) || @stage == 2
        @ticks += 1
        @y_offset = -50 * (@ticks / 50.0 - 1.8) ** 7 + 250
      elsif !@notified_observers
        @arrived_at_center_observers.each(&:call)
        @notified_observers = true
      end
    end
  end

  def draw
    @image.draw(@x_offset, @y_offset, 0)
  end

  def width
    @image.width
  end

  def off_top?
    @y_offset < -@image.height
  end
end

class Alien
  attr_reader :angle, :speed

  def initialize(window, image)
    @image = image 
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @angle = 0
    @vel_x = 2
    @aim = 0
    @ideal  = 0 
    @speed  = 6 + rand(3) - 1
  end

  def off_top?
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
