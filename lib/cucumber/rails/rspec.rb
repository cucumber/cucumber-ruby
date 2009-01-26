require 'cucumber/rails/world'
require 'spec/expectations'
require 'spec/rails/matchers'

class Cucumber::Rails::World
  include Spec::Matchers
  include Spec::Rails::Matchers
end
