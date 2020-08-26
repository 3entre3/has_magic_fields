# coding: utf-8
# frozen_string_literal: true

require_relative "lib/has_magic_fields/version"

Gem::Specification.new do |s|
  s.name          = "has_magic_fields"
  s.version       = HasMagicFields::VERSION
  s.authors       = ["ikeqiao"]
  s.email         = ["zhzsi@126.com"]
  s.description   = "Custom fields forActiveRecord models, suppport Rails 4!"
  s.summary       = "Allow addition of custom 'magic' fields to ActiveRecord models."
  s.homepage      = "https://github.com/ikeqiao/has_magic_fields"
  s.license       = "MIT"

  s.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s|features)/})
  s.require_path = "lib"

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_dependency("rails", [">= 4.0.0"])
  s.add_runtime_dependency("zeitwerk", "~> 2.2")
end
