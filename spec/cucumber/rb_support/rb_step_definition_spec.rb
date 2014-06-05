require 'spec_helper'
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
        support_code.step_match(text).invoke(MultilineArgument::None.new)
      end

      it "allows calling of other steps" do
        dsl.Given(/Outside/) do
          step "Inside"
        end
        dsl.Given(/Inside/) do
          $inside = true
        end

        run_step "Outside"

        expect($inside).to be true
      end

      it "allows calling of other steps with inline arg" do
        dsl.Given(/Outside/) do
          location = Core::Ast::Location.new(__FILE__, __LINE__)
          step "Inside", MultilineArgument.from(Cucumber::Core::Ast::DataTable.new([['inside']], location))
        end
        dsl.Given(/Inside/) do |table|
          $inside = table.raw[0][0]
        end

        run_step "Outside"

        expect($inside).to eq 'inside'
      end

      context "mapping to world methods" do
        it "calls a method on the world when specified with a symbol" do
          expect(rb.current_world).to receive(:with_symbol)

          dsl.Given(/With symbol/, :with_symbol)

          run_step "With symbol"
        end

        it "calls a method on a specified object" do
          target = double('target')

          allow(rb.current_world).to receive(:target) { target }

          dsl.Given(/With symbol on block/, :with_symbol, :on => lambda { target })

          expect(target).to receive(:with_symbol)

          run_step "With symbol on block"
        end

        it "calls a method on a specified world attribute" do
          target = double('target')

          allow(rb.current_world).to receive(:target) { target }

          dsl.Given(/With symbol on symbol/, :with_symbol, :on => :target)

          expect(target).to receive(:with_symbol)

          run_step "With symbol on symbol"
        end
      end

      it "raises Undefined when inside step is not defined" do
        dsl.Given(/Outside/) do
          step 'Inside'
        end

        expect(-> {
          run_step "Outside"
        }).to raise_error(Cucumber::Undefined, 'Undefined step: "Inside"')
      end

      it "allows forced pending" do
        dsl.Given(/Outside/) do
          pending("Do me!")
        end

        expect(-> {
          run_step "Outside"
        }).to raise_error(Cucumber::Pending, "Do me!")
      end

      it "raises ArityMismatchError when the number of capture groups differs from the number of step arguments" do
        dsl.Given(/No group: \w+/) do |arg|
        end

        expect(-> {
          run_step "No group: arg"
        }).to raise_error(Cucumber::ArityMismatchError)
      end

      it "does not allow modification of args since it messes up pretty formatting" do
        dsl.Given(/My car is (.*)/) do |colour|
          colour << "xxx"
        end

        expect(-> {
          run_step "My car is white"
        }).to raise_error(RuntimeError, /can't modify frozen String/i)
      end

      it "allows puts" do
        expect(user_interface).to  receive(:puts).with('wasup')
        dsl.Given(/Loud/) do
          puts 'wasup'
        end
        run_step "Loud"
      end

      it "recognizes $arg style captures" do
        arg_value = "wow!"
        dsl.Given "capture this: $arg" do |arg|
          expect(arg).to eq arg_value
        end
        run_step "capture this: wow!"
      end

      it "has a JSON representation of the signature" do
        expect(RbStepDefinition.new(rb, /I CAN HAZ (\d+) CUKES/i, lambda{}, {}).to_hash).to eq({ 'source' => "I CAN HAZ (\\d+) CUKES", 'flags' => 'i' })
      end
    end
  end
end
