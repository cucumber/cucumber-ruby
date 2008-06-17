require 'cucumber/tree'

module Cucumber
  module RubyTree
    class RubyStory
      include Tree::Story

      def initialize(header, narrative, &proc)
        @header, @narrative = header, narrative
        @scenarios = []
        instance_eval(&proc)
      end

      def Scenario(name, &proc)
        @scenarios << RubyScenario.new(name, &proc)
      end

    protected

      attr_reader :header, :narrative, :scenarios

    end

    class RubyScenario
      include Tree::Scenario

      def initialize(name, &proc)
        @name = name
        @steps = []
        instance_eval(&proc)
      end

      def Given(name)
        @steps << RubyStep.new('Given', name)
      end

      def When(name)
        @steps << RubyStep.new('When', name)
      end

      def Then(name)
        @steps << RubyStep.new('Then', name)
      end

      def And(name)
        @steps << RubyStep.new('And', name)
      end

    protected

      attr_reader :name, :steps

    end

    class RubyStep
      include Tree::Step
      attr_accessor :error
    
      def initialize(keyword, name)
        @keyword, @name = keyword, name
      end

    #protected

      attr_reader :keyword, :name

    end
  end
end

