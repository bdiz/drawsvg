# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'drawsvg/version'

Gem::Specification.new do |spec|
  spec.name          = "drawsvg"
  spec.version       = DrawSvg::VERSION
  spec.authors       = ["Ben Delsol"]
  spec.summary       = %q{A ruby layer built on top of the rasem gem to make drawing SVGs easier.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/bdiz/drawsvg"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rasem"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
