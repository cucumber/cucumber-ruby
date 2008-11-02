require 'autotest/cucumber_mixin'
require 'autotest/rspec'

class Autotest::CucumberRailsRspec < Autotest::Rspec
  include CucumberMixin
end
