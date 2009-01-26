require 'cucumber/rails/world'
require 'spec/expectations'
require 'spec/rails/matchers'

Cucumber::Rails::World.class_eval do
  include Spec::Matchers
  include Spec::Rails::Matchers
end
