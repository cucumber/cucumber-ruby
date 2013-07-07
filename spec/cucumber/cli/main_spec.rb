require 'spec_helper'
require 'yaml'
require 'cucumber/parser/gherkin_builder'
require 'gherkin/formatter/model'

module Cucumber
  module Cli
    describe Main do
      before(:each) do
        File.stub(:exist?).and_return(false) # When Configuration checks for cucumber.yml
        Dir.stub(:[]).and_return([]) # to prevent cucumber's features dir to being laoded
      end

      let(:args)   { [] }
      let(:stdin)  { StringIO.new }
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }
      let(:kernel) { double(:kernel) }
      subject { Main.new(args, stdin, stdout, stderr, kernel)}

      describe "#execute!" do
        context "passed an existing runtime" do
          let(:existing_runtime) { double('runtime').as_null_object }

          def do_execute
            subject.execute!(existing_runtime)
          end

          it "configures that runtime" do
            expected_configuration = double('Configuration', :drb? => false).as_null_object
            Configuration.stub(:new => expected_configuration)
            existing_runtime.should_receive(:configure).with(expected_configuration)
            kernel.should_receive(:exit).with(1)
            do_execute
          end

          it "uses that runtime for running and reporting results" do
            expected_results = double('results', :failure? => true)
            existing_runtime.should_receive(:run!)
            existing_runtime.stub(:results).and_return(expected_results)
            kernel.should_receive(:exit).with(1)
            do_execute
          end
        end

        context "interrupted with ctrl-c" do
          after do
            Cucumber.wants_to_quit = false
          end

          it "should register as a failure" do
            results = double('results', :failure? => false)
            runtime = Runtime.any_instance
            runtime.stub(:run!)
            runtime.stub(:results).and_return(results)

            Cucumber.wants_to_quit = true
            kernel.should_receive(:exit).with(1)
            subject.execute!
          end
        end
      end

      describe "verbose mode" do

        before(:each) do
          b = Cucumber::Parser::GherkinBuilder.new('features/foo.feature')
          b.feature(Gherkin::Formatter::Model::Feature.new([], [], "Feature", "Foo", "", 99, ""))
          b.language = double
          @empty_feature = b.result
        end

        it "should show feature files parsed" do
          cli = Main.new(%w{--verbose example.feature}, stdin, stdout, stderr, kernel)
          cli.stub(:require)

          Cucumber::FeatureFile.stub(:new).and_return(double("feature file", :parse => @empty_feature))

          kernel.should_receive(:exit).with(0)
          cli.execute!

          stdout.string.should include('example.feature')
        end

      end

      describe "--format with class" do
        describe "in module" do
          it "should resolve each module until it gets Formatter class" do
            cli = Main.new(%w{--format ZooModule::MonkeyFormatterClass}, stdin, stdout, stderr, kernel)
            double = double('module')
            Object.stub(:const_defined?).and_return(true)
            double.stub(:const_defined?).and_return(true)

            f = double('formatter').as_null_object

            if Cucumber::RUBY_1_8_7
              Object.should_receive(:const_get).with('ZooModule').and_return(double)
              double.should_receive(:const_get).with('MonkeyFormatterClass').and_return(double('formatter class', :new => f))
            else
              Object.should_receive(:const_get).with('ZooModule', false).and_return(double)
              double.should_receive(:const_get).with('MonkeyFormatterClass', false).and_return(double('formatter class', :new => f))
            end

            kernel.should_receive(:exit).with(0)
            cli.execute!
          end
        end
      end

      [ProfilesNotDefinedError, YmlLoadError, ProfileNotFound].each do |exception_klass|

        it "rescues #{exception_klass}, prints the message to the error stream" do
          Configuration.stub(:new).and_return(configuration = double('configuration'))
          configuration.stub(:parse!).and_raise(exception_klass.new("error message"))

          subject.execute!
          stderr.string.should == "error message\n"
        end
      end

      context "--drb" do
        before(:each) do
          @configuration = double('Configuration', :drb? => true, :dotcucumber => false).as_null_object
          Configuration.stub(:new).and_return(@configuration)

          args = ['features']

          step_mother = double('StepMother').as_null_object
          StepMother.stub(:new).and_return(step_mother)

          @cli = Main.new(args, stdin, stdout, stderr, kernel)
        end

        it "delegates the execution to the DRB client passing the args and streams" do
          @configuration.stub :drb_port => 1450
          DRbClient.should_receive(:run) do
            kernel.exit(1)
          end
          kernel.should_receive(:exit).with(1)
          @cli.execute!
        end

        it "returns the result from the DRbClient" do
          DRbClient.stub(:run).and_return('foo')
          @cli.execute!.should == 'foo'
        end

        it "ceases execution if the DrbClient is able to perform the execution" do
          DRbClient.stub(:run).and_return(true)
          @configuration.should_not_receive(:build_formatter_broadcaster)
          @cli.execute!
        end

        context "when the DrbClient is unable to perfrom the execution" do
          before { DRbClient.stub(:run).and_raise(DRbClientError.new('error message.')) }

          it "alerts the user that execution will be performed locally" do
            kernel.should_receive(:exit).with(1)
            @cli.execute!
            stderr.string.should include("WARNING: error message. Running features locally:")
          end

        end
      end
    end
  end
end
