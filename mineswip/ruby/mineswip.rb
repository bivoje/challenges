#!/usr/bin/env ruby

require 'set'

class Screen
  def initialize(w, h)
    @width = w
    @height = h
    clear
  end

  def clear
    @buffer = []
    @height.times do
      @buffer << " " * @width
    end
  end

  def splash
    @height.times do |i|
      puts @buffer[i] 
    end
  end

  def putc(x, y, c)
    return nil if x < 0 or @width <= x or y < 0 or @height <= y
    @buffer[y][x] = c
  end

  def fill(x, y, w, h, c)
    w  = [w, 0].max
    xt = x + w - 1
    x  = [x, 0].max
    xt = [@width-1, xt].min

    h  = [h, 0].max
    yt = y + h - 1
    y  = [y, 0].max
    yt = [yt, @height-1].min

    (y .. yt).each do |j|
      @buffer[j][x..xt] = c * (xt - x + 1)
    end
  end

  def puth(x, y, str)
    if y < 0 or @height <= y then return end

    s = x
    sx = [s, 0].max
    t = x + str.length - 1
    tx = [t, @width-1].min

    @buffer[y][sx..tx] = str[sx-s .. tx-s]
  end

  def putv(x, y, str)
    if x < 0 or @width <= x then return end

    s = y
    sy = [y, 0].max
    t = y + str.length - 1
    ty = [t, @height-1].min

    (sy..ty).each do |i|
      @buffer[i][x] = str[i-s]
    end
  end
end

class MineField
  def initialize(w, h, n)
    @width = w
    @height = h

    num = @width * @height
    n = [0, [n, num].min].max

    @revmode = n > num/2 
    count = if @revmode then num - n else n end

    @bombs = Array(0 .. num-1).sample(count).to_set
  end

  # returns -1 if bomb at (x,y), # of bombs around otherwise
  def peek(x, y)
    at = x + y * @width
    return -1 if is_bomb_at?(at)

    xs = []
    xs << -1 if 0 < x
    xs <<  0
    xs <<  1 if x < @width-1

    ys = []
    ys << -1 if 0 < y
    ys <<  0
    ys <<  1 if y < @height-1

    xs.product(ys).map { |dx, dy|
      is_bomb_at?(at + dx + dy * @width)
    }.count(true)
  end

  def is_bomb_at?(at)
    @revmode ^ @bombs.include?(at)
  end

  def nbombs
    @nbombs ||=
      if @revmode then
        @width * @height - @bombs.size
      else
        @bombs.size
      end
    return @nbombs
  end
end

class Prompt

  class Int
    def self.parse(str)
      begin Integer(str, 10); rescue ArgumentError; end
    end
  end

  def initialize(cmds)
    @cmds = cmds
    @count = 0
  end

  # returns whether to keep processing
  def interpret
    print "#{@count} >> "
    line = $stdin.gets

    return false if line == nil
    inputs = line.split

    if inputs.empty? then
      return true # does nothing on empty input
    end
    
    parsers, meth = @cmds[inputs[0]]
    if not parsers
      puts "unrecognized command!"
      return true
    end

    if parsers.size != inputs.size-1 then
      puts "wrong number of arguments!"
      return true
    end

    args = parsers.zip(inputs[1..-1]).map do |p, s|
      begin p.parse(s); rescue TypeError; end
    end

    if not args.all? {|x| x != nil} then
      puts "argument error!"
      return true
    end
      
    @count += 1 if meth.call(inputs[0], *args)
    return true
  end
end

class Game
  def initialize(w, h, n, b)
    # whether the game is quit
    @quit = false
    @cheat = b

    @width = w
    @height = h
    @show_legend = 6 <= @height

    # used in *_screen methods
    @boardX = 3
    @boardY = 2
    @boardW = @width * 2 + 1
    @boardH = @height

    @field = MineField.new(w, h, n)
    @opened = Set.new
    @flags = Set.new

    screenw = 2*w + 5 + if @show_legend then 20 else 0 end
    screenh = h + 3
    @screen = Screen.new(screenw, screenh)
    clear_screen

    @prompt = Prompt.new({
      "x" => [[Prompt::Int, Prompt::Int], self.method(:dig)],
      "?" => [[Prompt::Int, Prompt::Int], self.method(:flag)],
      "r" => [[], ->(_) { redraw_screen }],
      "q" => [[], self.method(:quit)],
    })
  end

  def play
    @screen.splash

    win = false

    while not @quit
      left = @width * @height - @field.nbombs - @opened.size
      if left == 0 then
        win = true
        break
      end

      if not @prompt.interpret then
        quit(0)
      else
        @screen.splash
      end
    end

    if win then
      puts "Congretuation!"
    end
  end

  def quit(_)
    @quit = true
  end

  # returns whether the command was valid
  def dig(_, x, y)
    return false if x <= 0 or @width < x or y <= 0 or @height < y
    x -=1; y -= 1

    peek = @field.peek(x, y)
    if peek == -1 then
      blow_screen(x, y)
      quit(0)
    else
      digaround(x, y) != 0
    end
  end

  # dig (x,y) and go for aroundings.
  # stops at non-empty tile
  # returns # of opened tiles
  def digaround(x, y)
    return 0 if x < 0 or @width <= x or y < 0 or @height <= y
                                    # out of bound
    at = x + y * @width
    return 0 if @opened.member? at  # it's already opened

    peek = @field.peek(x, y)
    open(x, y, peek)

    return 1 if peek != 0           # it's number, stop here

    [-1, 0, 1].product([-1, 0, 1]).map { |dx, dy|
      digaround(x + dx, y + dy)
    }.reduce(:+)
  end

  # n = peek(x, y) where n >= 0
  def open(x, y, n)
    at = x + y * @width
    @opened.add at
    putB(x, y, if n == 0 then '_' else n.to_s end)
  end

  def flag(_, x, y)
    return false if x <= 0 or @width < x or y <= 0 or @height < y
    x -= 1; y -= 1

    at = x + y * @width
    return false if @opened.member? at

    if @flags.member? at
      @flags.delete at
      putB(x, y, '.')
    else
      @flags.add at
      putB(x, y, '?')
    end
    return true
  end

  def clear_screen
    @screen.clear

    # rulers
    # add 2 for rounding and tail-ing
    ruler = Array(0..9) * (2 + [@width, @height].max / 10)
    @screen.puth(@boardX, 0, ' '+ ruler[1, @width] * ' ')
    @screen.putv(0, @boardY, ruler[1, @height] * '')

    # frame
    @screen.puth(@boardX-1, @boardY-1, "-"*(@boardW+2))
    @screen.putv(@boardX-1, @boardY, "|"*@boardH)
    @screen.puth(@boardX-1, @boardY+@boardH, "-"*(@boardW+2))
    @screen.putv(@boardX+@boardW, @boardY, "|"*@boardH)

    # legend
    if @show_legend
      @screen.puth(@boardX+@boardW+3, @boardY+0, "깃발 : ?")
      @screen.puth(@boardX+@boardW+3, @boardY+1, "폭탄 : X")
      @screen.puth(@boardX+@boardW+3, @boardY+2, "숫자 : n")
      @screen.puth(@boardX+@boardW+3, @boardY+3, "공백 : _")
      @screen.puth(@boardX+@boardW+3, @boardY+4, "미지 : .")
      @screen.puth(@boardX+@boardW+3, @boardY+5, "#폭탄: #{@field.nbombs}")
    end

    # field
    @boardH.times do |i|
      @screen.puth(@boardX, @boardY+i, " ."*@width)
    end

    # cheat
    if @cheat then
      @height.times do |j|
        @width.times do |i|
          if @field.peek(i, j) == -1 then
            putB(i, j, ',')
          end
        end
      end
    end
  end

  def blow_screen(x, y)
    tiles = {
      '*' => 15,
      '~' => 12,
      '%' => 10,
      '&' => 8,
      ' ' => 50,
    }

    gen = -> (freq) {
      sum = freq.inject(0) { |sum, (_, x)| sum + x }.to_f
      freq.max_by { |_, w| rand ** (sum / w) }.first
    }

    ds = [[1, 0], [0, 1], [-1, 0], [0, -1]]

    (2..8).step(2).each do |l|
      x -= 1
      y -= 1
      ds.each do |dx, dy|
        l.times.each do
          tile = gen[tiles]
          putB(x, y, tile) if tile != ' '
          x += dx
          y += dy
        end
      end
      tiles[' '] *= 1.5
    end
  end

  def redraw_screen()
    clear_screen

    @opened.each do |at|
      x, y = at % width, at / @width
      peek = @field.peek(x, y)
      tile = if peek == 0 then '_' else peek.to_s end
      putB(x, y, tile)
    end

    @flags.each do |at|
      x, y = at % @width, at / @width
      putB(x, y, '?')
    end
  end

  # put on board
  def putB(x, y, c)
    return nil if x < 0 or @width <= x or y < 0 or @height <= y
    @screen.putc(@boardX + x*2+1, @boardY + y, c)
  end
end

if ARGV.size != 3 then
  puts "you've got to specify 3 numbers (width, height, #bombs)"
  exit
end

ARGV.map! { |s|
  begin Integer(s, 10); rescue ArgumentError; end
}

if not ARGV.all? then
  puts "you've got to specify 3 numbers (width, height, #bombs)"
  puts "please, insert three NUMBERs"
  exit
end

game = Game.new(*ARGV, true)
game.play
