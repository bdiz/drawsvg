require "drawsvg/version"
require "rasem"

# TODO: Remove PrintStatusImg
class PrintStatusImg
  def initialize img
    @img = img
  end
  def method_missing meth, *args, &block
    puts "img.#{meth}(#{args.join(", ")})"
    @img.send(meth, *args, &block)
  end
end
module DrawSvg
  class Point
    def self.[] *args
      Point.new(*args)
    end
    attr_accessor :x, :y
    def initialize x, y=nil
      if !y.nil?
        @x, @y = x, y
      elsif x.is_a? Array and x.size == 2
        @x, @y = x[0], x[1]
      elsif x.is_a? Point
        @x, @y = x.x, x.y
      else
        @x, @y = x, x
      end
    end
    def + other
      other = Point.new(other)
      Point.new(@x+other.x, @y+other.y)
    end
    def - other
      other = Point.new(other)
      Point.new(@x-other.x, @y-other.y)
    end
    def * other
      other = Point.new(other)
      Point.new(@x*other.x, @y*other.y)
    end
    def round
      Point.new(@x.round, @y.round)
    end
    def to_s
      "[#{@x}, #{@y}]"
    end
  end
  class Scale < Point; end

  # TODO: consider making Canvas an Item.
  # TODO: Add Rotation.
  # TODO: performance.
  class Canvas
    DEFAULT_SCALE = 1
    attr_reader :img, :width, :height, :items
    attr_accessor :scale
    def initialize width, height, output=nil, opts={}
      @width, @height, @output, @opts = width, height, output, opts
      @scale = Scale.new(@opts.delete(:scale) || DEFAULT_SCALE)
      @img = SVGImageCalls.new
      @location = Point[0, 0]
      @items = []
      draw
    end
    def draw
      raise NotImplementedError
    end
    def absolute_location
      @location
    end
    def to_svg
      svg = PrintStatusImg.new(Rasem::SVGImage.new(@width, @height, @output))
      @img.replay_on svg
      @items.each {|i| i.to_svg svg }
      svg.close
      svg.output
    end
  end

  class SVGImageCalls
    def initialize
      @calls = []
    end
    def method_missing name, *args, &block
      @calls << [name, args, block]
    end
    def replay_on img
      @calls.each {|name, args, block| img.send(name, *args, &block) }
    end
  end

  class Item
    include Comparable
    DEFAULT_SCALE = 1
    attr_reader :parent, :items, :location
    def initialize parent, location, opts={}
      @parent, @location = parent, Point.new(location)
      @scale = Scale.new(opts[:scale] || DEFAULT_SCALE)
      @parent.items << self
      @items = []
      draw
    end
    def draw
      raise NotImplementedError
    end
    def <=> other
      self.object_id <=> other.object_id
    end
    def img; canvas.img; end
    def scale; parent.scale * @scale; end
    def absolute_location; parent.absolute_location + location; end
    def delete
      @parent.delete(self)
    end
    def to_svg img
      @items.each {|i| i.to_svg img }
    end
    def canvas
      return parent if parent.is_a? Canvas
      return parent.canvas
    end
  end

  class Line < Item
    attr_reader :length, :angle
    def initialize parent, location, length, angle, opts={}
      super(parent, location)
      @length = length
      @angle = angle * Math::PI / 180
      @opts = opts
      @snap = @opts.has_key?(:snap) ? @opts.delete(:snap) : true
    end
    def draw; end
    def to_svg img
      img.line(p1_svg.x, p1_svg.y, p2_svg.x, p2_svg.y, Rasem::SVGImage::DefaultStyles[:line].merge(@opts))
    end
    def p1
      @snap ?  location : (location * scale)
    end
    def p2
      p1 + Point.new(length*Math.cos(angle), length*Math.sin(angle))*scale
    end
    def p1_absolute
      parent.absolute_location + p1
    end
    def p2_absolute
      parent.absolute_location + p2
    end
    def p1_svg
      Point.new(p1_absolute.x, (canvas.height - p1_absolute.y)).round
    end
    def p2_svg
      Point.new(p2_absolute.x, (canvas.height - p2_absolute.y)).round
    end
  end

  # TODO: consider making only an Ellipse class with a Circle wrapper
  class Circle < Item
    attr_writer :radius
    def initialize parent, location, radius, opts={} #location is center of circle by default
      super(parent, location)
      @radius, @opts = radius, opts
      @draw_from = @opts.delete(:draw_from) || :center
      @snap = @opts.delete(:snap)
    end
    def draw; end
    def to_svg img
      img.circle(center_svg.x, center_svg.y, radius, Rasem::SVGImage::DefaultStyles[:line].merge(fill: 'white').merge(@opts))
    end
    def center
      if @draw_from == :bottom
        location + Point[0, radius]
      else
        location 
      end
    end
    def radius
      (@radius*scale.x).round
    end
    def center_absolute
      parent.absolute_location + center
    end
    def center_svg
      Point.new(center_absolute.x, (canvas.height - center_absolute.y)).round
    end
  end

  # TODO: Consider only having Polygon w/ a Rectangle wrapper.
  class Rectangle < Item
    attr_reader :location2
    def initialize parent, location, location2, opts={}
      super(parent, location)
      @location2 = Point.new(location2)
      @opts = opts
      @draw_from = @opts.delete(:draw_from) || :top_left
      @snap = @opts.has_key?(:snap) ? @opts.delete(:snap) : true
    end
    def draw; end
    def to_svg img
      img.rectangle(p1_svg.x, p1_svg.y, p2_svg.x, p2_svg.y, Rasem::SVGImage::DefaultStyles[:rect].merge(@opts))
    end
    # top left corner
    def p1
      p = @snap ?  location : (location * scale)
      if @draw_from == :bottom_left
        p + Point[0, (location2*scale).y]
      else
        p
      end
    end
    # bottom right corner
    def p2
      p1 + p2_relative
    end
    def p2_relative
      location2*scale
    end
    def p1_absolute
      parent.absolute_location + p1
    end
    def p2_absolute
      parent.absolute_location + p2
    end
    def p1_svg
      Point.new(p1_absolute.x, (canvas.height - p1_absolute.y)).round
    end
    def p2_svg
      p2_relative.round
    end
  end

  # TODO: class Polygon

end
