require 'spec/expectations'
require 'spec/rails/matchers'

Cucumber::Rails::World.send(:include, Spec::Matchers)
Cucumber::Rails::World.send(:include, Spec::Rails::Matchers)