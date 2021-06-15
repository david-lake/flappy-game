# Base code for any gosu game

require "gosu"

class Player
  GRAVITY = 5

  def initialize(window, x, y)
    @window = window
    @x = x
    @y = y
  end

  def update
    @y = @y + GRAVITY unless @y == @window.height - 80
    if @window.button_down?(Gosu::KbSpace)
      if @y >= 10
        @y -= 10
      else
        @y -= @y
      end
    end
  end

  def draw
    width = height =  80
    Gosu.draw_rect(@x, @y, width, height, Gosu::Color.argb(0xff_ff0000))
  end
end

class Pillar
  def initialize(window)
    @window = window
    @x = @window.width + 10
  end

  def update
    return if done?
    @x -= 5
  end

  def draw
    Gosu.draw_rect(@x, 0, 60, @window.height,  Gosu::Color.argb(0xff_00ff00))
  end

  def done?
    @done ||= @x < -60
  end
end

class GameWindow < Gosu::Window
  def initialize(width=500, height=600, fullscreen=false)
    super
    self.caption = "Base gosu game"
    @player = Player.new(self, 60, 50)
    @pillars = []
    @button_down = 0
  end

  def update
    @pillars.map(&:update)
    @pillars.reject!(&:done?)
    @pillars.push(Pillar.new(self)) if needs_pillar?
    @player.update
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    @button_down += 1
  end

  def button_up(id)
    @button_down -= 1
  end

  def draw
    @screen_ready ||= true
    @player.draw
    @pillars.map(&:draw)
  end

  private

  def needs_pillar?
    now = Gosu.milliseconds
    @last_pillar ||= now
    if (now - @last_pillar) > 2500
      @last_pillar = now
    end
  end
end

w = GameWindow.new
w.show
