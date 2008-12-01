require 'spec'
require 'spec/rails'

# Hack to stop RSpec from dumping the summary
Spec::Runner::Options.class_eval do
  def examples_should_be_run?
    false
  end
end

ActionController::Integration::Session.send(:include, Spec::Matchers)
ActionController::Integration::Session.send(:include, Spec::Rails::Matchers)
