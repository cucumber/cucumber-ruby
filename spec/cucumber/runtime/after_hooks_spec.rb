require 'spec_helper'
require 'cucumber/runtime/hooks_examples'

require 'cucumber/runtime/after_hooks'

module Cucumber
  class Runtime
    describe AfterHooks do
      let(:subject) { AfterHooks.new(id_generator, hooks, scenario, event_bus) }

      describe '#apply_to' do
        include_examples 'events are fired when applying hooks'
      end
    end
  end
end
