# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attr_memoizer/version'

Gem::Specification.new do |gem|
  gem.name          = "attr_memoizer"
  gem.version       = AttrMemoizer::VERSION
  gem.authors       = ["Matthew McEachen"]
  gem.email         = ["matthew+github@mceachen.org"]
  gem.description   = %q{Correct attribute memoization for ruby, made easy}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/mceachen/attr_memoizer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-great_expectations'
end
