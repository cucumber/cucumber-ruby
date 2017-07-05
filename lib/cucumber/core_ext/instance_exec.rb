# frozen_string_literal: true
require 'cucumber/glue/invoke_in_world'

module Cucumber
  # Raised if the number of a StepDefinition's Regexp match groups
  # is different from the number of Proc arguments.
  class ArityMismatchError < StandardError
  end
end

class Object #:nodoc:
  # TODO: inline
  def cucumber_instance_exec_in(world, check_arity, pseudo_method, *args, &block)
    Cucumber::Glue::InvokeInWorld.cucumber_instance_exec_in(world, check_arity, pseudo_method, *args, &block)
  end
end
