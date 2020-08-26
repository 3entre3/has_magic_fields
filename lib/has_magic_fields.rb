# frozen_string_literal: true

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.do_not_eager_load("#{__dir__}/generators")
loader.push_dir("#{__dir__}/../app/models")
loader.setup
loader.eager_load

require "has_magic_fields/version"
require "has_magic_fields/extend"
