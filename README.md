# DrawSvg

A ruby layer to make drawing SVGs easier. Uses rasem under the hood.

* A Canvas holds all the Items to be drawn.
* Group related shapes into an Item.
* Items can have sub-Items.
* The Canvas can be scaled (ie. zoom in/out).
* Individual Items can be scaled.
* Use coordinates as if you are drawing on the first Cartesian quadrant.
* Shapes can be snapped or unsnapped to each other (do they stay together or drift apart when scaled).
* Lines are drawn with a starting point, length and angle (versus two points).

## Installation

Add this line to your application's Gemfile:

    gem 'drawsvg'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install drawsvg

## Usage

```ruby
require 'drawsvg'
include DrawSvg

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
      StickMan.new(self, Point[(0..475).to_a.sample, (0..475).to_a.sample], scale: (50..150).to_a.sample.to_f/100)
    end
  end
end

canvas = MyCanvas.new(501, 501, nil, scale: [1.1, 1.0])
File.write("/tmp/image.svg", canvas.to_svg)
```

## Contributing

1. Fork it ( https://github.com/bdiz/drawsvg/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
