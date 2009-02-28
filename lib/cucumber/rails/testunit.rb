require 'test/unit/assertions'

Cucumber::Rails::World.class_eval do
  include Test::Unit::Assertions
end
