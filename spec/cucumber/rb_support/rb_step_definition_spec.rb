require 'spec_helper'
require 'cucumber/ast'
require 'cucumber/step_mother'
require 'cucumber/rb_support/rb_language'

module Cucumber
  module RbSupport
    describe RbStepDefinition do
      let(:user_interface) { double('user interface') }
      let(:support_code)   { Cucumber::Runtime::SupportCode.new(user_interface) }
      let(:rb)             { support_code.load_programming_language('rb') }
      let(:dsl) do
        rb
        Object.new.extend(Cucumber::RbSupport::RbDsl)
      end

      before do
        rb.before(double('scenario').as_null_object)
        $inside = nil
      end

      def run_step(text)
        support_code.step_match(text).invoke(nil)
      end

      it "should allow calling of other steps" do
        dsl.Given /Outside/ do
          step "Inside"
        end
        dsl.Given /Inside/ do
          $inside = true
        end

        run_step "Outside"
        $inside.should == true
      end

      it "should allow calling of other steps with inline arg" do
        dsl.Given /Outside/ do
          step "Inside", Cucumber::Ast::Table.new([['inside']])
        end
        dsl.Given /Inside/ do |table|
          $inside = table.raw[0][0]
        end

        run_step "Outside"
        $inside.should == 'inside'
      end

      context "mapping to world methods" do
        it "should call a method on the world when specified with a symbol" do
          rb.current_world.should_receive(:with_symbol)
          dsl.Given /With symbol/, :with_symbol

          run_step "With symbol"
        end

        it "should call a method on a specified object" do
          target = double('target')
          rb.current_world.stub(:target => target)
          dsl.Given /With symbol on block/, :with_symbol, :on => lambda { target }

          target.should_receive(:with_symbol)
          run_step "With symbol on block"
        end

        it "should call a method on a specified world attribute" do
          target = double('target')
          rb.current_world.stub(:target => target)
          dsl.Given /With symbol on symbol/, :with_symbol, :on => :target

          target.should_receive(:with_symbol)
          run_step "With symbol on symbol"
        end
      end

      it "should raise Undefined when inside step is not defined" do
        dsl.Given /Outside/ do
          step 'Inside'
        end

        lambda { run_step "Outside" }.
          should raise_error(Cucumber::Undefined, 'Undefined step: "Inside"')
      end

      it "should allow forced pending" do
        dsl.Given /Outside/ do
          pending("Do me!")
        end

        lambda { run_step "Outside" }.
          should raise_error(Cucumber::Pending, "Do me!")
      end

      it "should raise ArityMismatchError when the number of capture groups differs from the number of step arguments" do
        dsl.Given /No group: \w+/ do |arg|
        end

        lambda { run_step "No group: arg" }.
          should raise_error(Cucumber::ArityMismatchError)
      end

      it "should allow puts" do
        user_interface.should_receive(:puts).with('wasup')
        dsl.Given /Loud/ do
          puts 'wasup'
        end
        run_step "Loud"
      end

      it "should recognize $arg style captures" do
        arg_value = "wow!"
        dsl.Given "capture this: $arg" do |arg|
          arg.should == arg_value
        end
        run_step "capture this: wow!"
      end

      it "should have a JSON representation of the signature" do
        RbStepDefinition.new(rb, /I CAN HAZ (\d+) CUKES/i, lambda{}, {}).to_hash.should == {'source' => "I CAN HAZ (\\d+) CUKES", 'flags' => 'i'}
      end
    end
  end
end
