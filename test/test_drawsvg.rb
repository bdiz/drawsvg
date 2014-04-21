require 'minitest_helper'

describe DrawSvg do
  it "has a version number" do
    ::DrawSvg::VERSION.wont_be_nil
  end

  it "can draw something" do
    canvas = MyCanvas.new(501, 501, nil, scale: [1.1, 1.0])
    canvas.to_svg.wont_be_empty
    File.write("/tmp/image.svg", canvas.to_svg)
  end
end
