require 'spec/expectations'
require 'spec/rails/matchers'

ActionController::Integration::Session.send(:include, Spec::Matchers)
ActionController::Integration::Session.send(:include, Spec::Rails::Matchers)
