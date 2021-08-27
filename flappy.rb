# Flappy bird style game

require "gosu"

class Player
  GRAVITY = 5
  JUMP = 10

  attr_reader :x, :y, :height, :width

  def initialize(window, x, y)
    @window = window
    @x = x
    @y = y
    @width = @height = 70
  end

  def update
    @y = @y + GRAVITY unless @y == @window.height - @height
    if @window.button_down?(Gosu::KbUp)
      @y >= JUMP ? @y -= JUMP : @y -= @y
    end
  end

  def draw
    Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color.argb(0xff_ff0000))
  end
end

class Pillar
  attr_reader :x, :y, :height, :width

  def initialize(window, y, height)
    @window = window
    @x = @window.width + 10
    @y = y
    @height = height
    @width = 60
  end

  def update
    return if done?
    @x -= 5
  end

  def draw
    Gosu.draw_rect(@x, @y, @width, @height, Gosu::Color.argb(0xff_00ff00))
  end

  def done?
    @done ||= @x < -@width
  end
end

class GameWindow < Gosu::Window
  def initialize(width=500, height=600, fullscreen=false)
    super
    self.caption = "Flappy"
    @player = Player.new(self, 70, 50)
    @pillars = []
    @game_over = false
  end

  def update
    unless @game_over
      @pillars.map(&:update)
      @pillars.reject!(&:done?)
      add_pillar if needs_pillar?
      @player.update
    end
  end

  def button_down(id)
    close if id == Gosu::KbEscape
    reset if @game_over && id == Gosu::KbSpace
  end

  def draw
    if @game_over
      message = Gosu::Image.from_text(self, "Game Over", Gosu.default_font_name, 40)
      message.draw(150, 200, 0)
      message = Gosu::Image.from_text(self, "Press space bar to restart", Gosu.default_font_name, 20)
      message.draw(140, 300, 0)
    else
      @player.draw
      @pillars.map(&:draw)
    end
    @game_over = game_over?
  end

  private

  def needs_pillar?
    now = Gosu.milliseconds
    @last_pillar ||= now
    if (now - @last_pillar) > 2000
      @last_pillar = now
    end
  end

  def add_pillar
    gap = rand(150..250)
    pillar_total = self.height - gap
    first_pillar = rand(50..pillar_total - 50)
    @pillars.push(Pillar.new(self, 0, first_pillar))
    @pillars.push(Pillar.new(self, first_pillar + gap, pillar_total - first_pillar))
  end

  def game_over?
    # true if player touches the bottom of screen
    return true if @player.y + @player.height == self.height
    if @pillars.any?
      # true if player has collided with any pillars
      @pillars.each do |pillar|
        return true if (@player.x.between?(pillar.x, pillar.x + pillar.width)) &&
                       (@player.y.between?(pillar.y, pillar.y + pillar.height))
        return true if ((@player.x + @player.width).between?(pillar.x, pillar.x + pillar.width)) &&
                       (@player.y.between?(pillar.y, pillar.y + pillar.height))
        return true if (@player.x.between?(pillar.x, pillar.x + pillar.width)) &&
                       ((@player.y + @player.height).between?(pillar.y, pillar.y + pillar.height))
        return true if ((@player.x + @player.width).between?(pillar.x, pillar.x + pillar.width)) &&
                       ((@player.y + @player.height).between?(pillar.y, pillar.y + pillar.height))
      end
    end
    return false
  end

  def reset
    @player = Player.new(self, 70, 50)
    @pillars = []
    @game_over = false
  end
end

w = GameWindow.new
w.show
