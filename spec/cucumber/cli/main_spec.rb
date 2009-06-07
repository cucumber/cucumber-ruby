require File.dirname(__FILE__) + '/../../spec_helper'
require 'yaml'
begin
  require 'spec/runner/differs/default' # RSpec >=1.2.4
rescue ::LoadError
  require 'spec/expectations/differs/default' # RSpec <=1.2.3
end

module Cucumber
  module Cli
    describe Main do
      before(:each) do
        @out = StringIO.new
        @err = StringIO.new
        Kernel.stub!(:exit).and_return(nil)
      end

      describe "verbose mode" do

        before(:each) do
          @empty_feature = Ast::Feature.new(nil, Ast::Comment.new(''), Ast::Tags.new(2, []), "Feature", [])
          Dir.stub!(:[])
        end

        it "should show ruby files required" do
          @cli = Main.new(%w{--verbose --require example.rb}, @out)
          @cli.stub!(:require)

          @cli.execute!(Object.new.extend(StepMother))

          @out.string.should include('example.rb')
        end

        it "should show feature files parsed" do
          @cli = Main.new(%w{--verbose example.feature}, @out)
          @cli.stub!(:require)

          Parser::FeatureParser.stub!(:new).and_return(mock("feature parser", :parse_file => @empty_feature))

          @cli.execute!(Object.new.extend(StepMother))

          @out.string.should include('example.feature')
        end

      end

      describe "diffing" do

        before :each do
          @configuration = mock('Configuration', :null_object => true, :drb? => false)
          Configuration.should_receive(:new).and_return(@configuration)

          @step_mother = mock('StepMother', :null_object => true)

          @cli = Main.new(nil, @out)
        end

        it "uses Spec Differ::Default when diff is enabled" do
          @configuration.should_receive(:diff_enabled?).and_return(true)

          ::Spec::Expectations::Differs::Default.should_receive(:new)

          @cli.execute!(@step_mother)
        end

        it "does not use Spec Differ::Default when diff is disabled" do
          @configuration.should_receive(:diff_enabled?).and_return(false)

          ::Spec::Expectations::Differs::Default.should_not_receive(:new)

          @cli.execute!(@step_mother)
        end

      end

      describe "--format with class" do

       describe "in module" do

          it "should resolve each module until it gets Formatter class" do
            cli = Main.new(%w{--format ZooModule::MonkeyFormatterClass}, nil)
            mock_module = mock('module')
            Object.stub!(:const_defined?).and_return(true)
            mock_module.stub!(:const_defined?).and_return(true)

            f = stub('formatter', :null_object => true)

            Object.should_receive(:const_get).with('ZooModule').and_return(mock_module)
            mock_module.should_receive(:const_get).with('MonkeyFormatterClass').and_return(mock('formatter class', :new => f))

            cli.execute!(Object.new.extend(StepMother))
          end

        end
      end

      context "--drb" do
        before(:each) do
          @configuration = mock('Configuration', :drb? => true, :null_object => true)
          Configuration.stub!(:new).and_return(@configuration)

          @args = ['features']

          @cli = Main.new(@args, @out, @err)
          @step_mother = mock('StepMother', :null_object => true)
        end

        it "delegates the execution to the DRB client passing the args and streams" do
          DRbClient.should_receive(:run).with(@args, @err, @out).and_return(true)
          @cli.execute!(@step_mother)
        end

        it "ceases execution if the DrbClient is able to perform the execution" do
          DRbClient.stub!(:run).and_return(true)
          @configuration.should_not_receive(:load_language)
          @cli.execute!(@step_mother)
        end

        context "when the DrbClient is unable to perfrom the execution" do
          before { DRbClient.stub!(:run).and_return(false) }

          it "alerts the user that execution will be performed locally" do
            @cli.execute!(@step_mother)
            @err.string.should include("WARNING: No DRb server is running. Running features locally:")
          end

          it "reparses the configuration since the --drb flag causes the initial parsing to short circuit" do
            @configuration.should_receive(:parse!).exactly(:twice)
            @cli.execute!(@step_mother)
          end

          it "proceeds with the execution locally" do
            @configuration.should_receive(:load_language)
            @cli.execute!(@step_mother)
          end
        end

      end

    end
  end
end
