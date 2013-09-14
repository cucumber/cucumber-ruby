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
            expected_configuration = double('Configuration').as_null_object
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

      describe "--format with class" do
        describe "in module" do
          it "should resolve each module until it gets Formatter class" do
            cli = Main.new(%w{--format ZooModule::MonkeyFormatterClass}, stdin, stdout, stderr, kernel)
            mock_module = double('module')
            Object.stub(:const_defined?).and_return(true)
            mock_module.stub(:const_defined?).and_return(true)

            f = double('formatter').as_null_object

            Object.should_receive(:const_get).with('ZooModule', false).and_return(mock_module)
            mock_module.should_receive(:const_get).with('MonkeyFormatterClass', false).and_return(double('formatter class', :new => f))

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

    end
  end
end
