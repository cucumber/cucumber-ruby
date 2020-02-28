require 'spec_helper'
require 'cucumber/runtime/hooks_examples'

require 'cucumber/runtime/before_hooks'

module Cucumber
  class Runtime
    describe BeforeHooks do
      let(:subject) { BeforeHooks.new(id_generator, hooks, scenario, event_bus) }

      describe '#apply_to' do
        include_examples 'events are fired when applying hooks'
      end
    end
  end
end
