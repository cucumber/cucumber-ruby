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
        @line = *caller[2].split(':')[1].to_i
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

      attr_reader :name, :steps, :line

    end

    class RubyStep
      include Tree::Step
      attr_accessor :error
    
      def initialize(keyword, name)
        @keyword, @name = keyword, name
        @file, @line, _ = *caller[2].split(':')
      end

      attr_reader :keyword, :name, :file, :line

    end
  end
end

