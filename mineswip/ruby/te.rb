
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

screen = Screen.new(10, 10)

x, y = 5, 5

tiles = {
  '*' => 15,
  '~' => 12,
  '%' => 10,
  '&' => 8,
  ' ' => 100,
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
      #puts "#{x}, #{y}, #{tile}"
      screen.putc(x, y, tile)
      x += dx
      y += dy
    end
    tiles[' '] *= 1.2
  end
end

screen.splash
