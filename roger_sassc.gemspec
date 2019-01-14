lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "roger_sassc/version"

Gem::Specification.new do |spec|
  spec.name          = "roger_sassc"
  spec.version       = RogerSassc::VERSION

  spec.authors       = ["Edwin van der Graaf"]
  spec.email         = ["edwin@digitpaint.nl"]
  spec.summary       = "Sass plugin for Roger based on libsass"
  spec.homepage      = "https://github.com/DigitPaint/roger_sassc"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sassc", "~> 1.11.4"
  spec.add_dependency "roger", "~> 1.0"
  spec.add_dependency "mime-types", ["~> 2.2"]
  spec.add_dependency "rack"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "mocha", "~> 1.1.0"
  spec.add_development_dependency "test-unit", "~> 3.1.2"
  spec.add_development_dependency "simplecov", "~> 0.10.0"
  spec.add_development_dependency "rubocop", "~> 0.31.0"
end
