$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'drawsvg'

require 'minitest/autorun'
require 'minitest/spec'

include DrawSvg

class Sign < Item
  def draw
    l = Line.new(self, Point.new(0,0), 40, 0)
    Line.new(self, Point.new(0,0), 40, -90)
    Line.new(self, Point.new(10,-10), 40, -45, snap: false)
    Line.new(self, l.p1 + Point.new(-5,5), 40, 90+45, snap: false)
    Line.new(self, l.p2 + Point.new(-5,5), 40, 90+45)
  end
end

class StickMan < Item
  def draw
    @left_leg = Line.new(self, [0,0], 40, 60, stroke: 'red')
    @right_leg = Line.new(self, @left_leg.p2, 40, -60)
    @body = Line.new(self, @left_leg.p2, 30, 90)
    @left_arm = Line.new(self, @body.p2-[0, 8], 30, 180+45)
    @right_arm = Line.new(self, @left_arm.p1, 30, 20)
    @box = Rectangle.new(self, @right_arm.p2, [10,15], fill: 'white', draw_from: :bottom_left)
    @head = Circle.new(self, @body.p2, 15, draw_from: :bottom, stroke: %w[orange blue red].sample, fill: 'white')
  end
end

class MyCanvas < Canvas
  def draw
    30.times do
      StickMan.new(self, Point.new((0..475).to_a.sample, (0..475).to_a.sample), scale: (50..150).to_a.sample.to_f/100)
    end
    Sign.new(self, Point.new(100,170), scale: [2,1])
    Sign.new(self, Point.new(100,100), scale: 1)
    # img.ellipse(200,200, 10, 30)
    # img.polygon(50,50,100,50,300,23, stroke: 'black', fill: 'white')
    # img.polyline(36,76,534,123,455,321,112,344, stroke: 'black', fill: 'white')
  end
end

