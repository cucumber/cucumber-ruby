require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

module Cucumber
  describe CLI do
    
    def mock_executor(stubs = {})
      stub('executor', {:visit_features => nil, :lines_for_features= => nil, :failed => false, :formatters= => nil}.merge(stubs))
    end
    
    def mock_broadcaster(stubs = {})
      stub(Broadcaster, {:register => nil}.merge(stubs))
    end
    
    def mock_features(stubs ={})
      stub('features', {:<< => nil}.merge(stubs))
    end
    
    before(:each) do
      Kernel.stub!(:exit).and_return(nil)
    end
    
    def given_cucumber_yml_defined_as(hash_or_string)
      File.stub!(:exist?).and_return(true)
      cucumber_yml = hash_or_string.is_a?(Hash) ? hash_or_string.to_yaml : hash_or_string
      IO.stub!(:read).with('cucumber.yml').and_return(cucumber_yml)
    end
    
    it "should expand args from YAML file" do
      cli = CLI.new
      
      given_cucumber_yml_defined_as({'bongo' => '--require from/yml'})

      cli.parse_options!(%w{--format progress --profile bongo})
      cli.options[:formats].should == {'progress' => [STDOUT]}
      cli.options[:require].should == ['from/yml']
    end

    it "should expand args from YAML file's default if there are no args" do
      cli = CLI.new

      given_cucumber_yml_defined_as({'default' => '--require from/yml'})

      cli.parse_options!([])
      cli.options[:require].should == ['from/yml']
    end
    
    it "should provide a helpful error message when a specified profile does not exists in YAML file" do
      cli = CLI.new(StringIO.new, error = StringIO.new)
      
      given_cucumber_yml_defined_as({'default' => '--require from/yml', 'html_report' =>  '--format html'})
    
      cli.parse_options!(%w{--profile i_do_not_exist})
      
      expected_message = <<-END_OF_MESSAGE
Could not find profile: 'i_do_not_exist'

Defined profiles in cucumber.yml:
  * default
  * html_report
      END_OF_MESSAGE
        
      error.string.should == expected_message
    end
    
    it "should provide a helpful error message when a specified profile is not a String" do
      cli = CLI.new(StringIO.new, error = StringIO.new)

      given_cucumber_yml_defined_as({'foo' => [1,2,3]})

      cli.parse_options!(%w{--profile foo})

      error.string.should == "Profiles must be defined as a String.  The 'foo' profile was [1, 2, 3] (Array).\n"
    end
    
    it "should provide a helpful error message when a specified profile exists but is nil or blank" do
      [nil, '   '].each do |bad_input|
        cli = CLI.new(StringIO.new, error = StringIO.new)

        given_cucumber_yml_defined_as({'foo' => bad_input})

        cli.parse_options!(%w{--profile foo})

        error.string.should match(/The 'foo' profile in cucumber.yml was blank.  Please define the command line arguments for the 'foo' profile in cucumber.yml./)
      end
    end

    it "should provide a helpful error message when no YAML file exists and a profile is specified" do
      cli = CLI.new(StringIO.new, error = StringIO.new)
      
      File.should_receive(:exist?).with('cucumber.yml').and_return(false)
    
      cli.parse_options!(%w{--profile i_do_not_exist})
        
      error.string.should match(/cucumber.yml was not found.  Please refer to cucumber's documentaion on defining profiles in cucumber.yml./)
    end

    it "should provide a helpful error message when cucumber.yml is blank or malformed" do
        expected_error_message = /cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentaion on correct profile usage./
          
      ['', 'sfsadfs', "--- \n- an\n- array\n", "---dddfd"].each do |bad_input|
        cli = CLI.new(StringIO.new, error = StringIO.new)
      
        given_cucumber_yml_defined_as(bad_input)
        cli.parse_options!([])
        
        error.string.should match(expected_error_message)
      end
    end
    
    it "should procide a helpful error message when the YAML can not be parsed" do
        expected_error_message = /cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentaion on correct profile usage./
      cli = CLI.new(StringIO.new, error = StringIO.new)
      
      given_cucumber_yml_defined_as("input that causes an exception in YAML loading")
      YAML.should_receive(:load).and_raise Exception
      
      cli.parse_options!([])
      
      error.string.should match(expected_error_message)
    end

    it "should accept --no-source option" do
      cli = CLI.new
      cli.parse_options!(%w{--no-source})

      cli.options[:source].should be_false
    end

    it "should accept --no-snippets option" do
      cli = CLI.new
      cli.parse_options!(%w{--no-snippets})
      
      cli.options[:snippets].should be_false
    end

    it "should accept --quiet option" do
      cli = CLI.new
      cli.parse_options!(%w{--quiet})
      
      cli.options[:snippets].should be_false
      cli.options[:source].should be_false
    end

    it "should accept --verbose option" do
      cli = CLI.new
      cli.parse_options!(%w{--verbose})

      cli.options[:verbose].should be_true
    end

    it "should require files in support paths first" do
      File.stub!(:directory?).and_return(true)
      Dir.stub!(:[]).and_return(["/features/step_definitions/foo.rb","/features/support/env.rb"])
      
      cli = CLI.new(StringIO.new)
      cli.parse_options!(%w{--require /features})

      cli.should_receive(:require).twice.with(/treetop_parser/).ordered
      cli.should_receive(:require).with("/features/support/env.rb").ordered
      cli.should_receive(:require).with("/features/step_definitions/foo.rb").ordered
      cli.should_receive(:require).with("spec/expectations/differs/default").ordered

      cli.execute!(stub('step mother'), mock_executor, mock_features)
    end

    describe "verbose mode" do
      
      before(:each) do
        @out = StringIO.new
        @cli = CLI.new(@out)
        @cli.stub!(:require)
        Dir.stub!(:[])
      end

      it "should show ruby files required" do
        @cli.parse_options!(%w{--verbose --require example.rb})
        @cli.execute!(stub('step mother'), mock_executor, mock_features)
        
        @out.string.should include('example.rb')
      end
      
      it "should show feature files parsed" do
        TreetopParser::FeatureParser.stub!(:new).and_return(mock("feature parser", :parse_feature => nil))
          
        @cli.parse_options!(%w{--verbose example.feature})
        @cli.execute!(stub('step mother'), mock_executor, mock_features)

        @out.string.should include('example.feature')
      end
      
    end

    it "should accept --out option" do
      cli = CLI.new
      File.should_receive(:open).with('jalla.txt', 'w')
      cli.parse_options!(%w{--out jalla.txt})
    end

    it "should accept multiple --out options" do
      cli = CLI.new
      mock_file1 = stub(File, :open => nil)
      mock_file2 = stub(File, :open => nil)
      File.stub!(:open).and_return(mock_file1, mock_file2)

      cli.parse_options!(%w{--format progress --out file1 --out file2})
      cli.options[:formats].should == {'progress' => [mock_file1, mock_file2]}
    end

    it "should accept multiple --format options" do
      cli = CLI.new
      cli.parse_options!(%w{--format pretty --format progress})
      cli.options[:formats].should have_key('pretty')
      cli.options[:formats].should have_key('progress')
    end

    it "should associate --out to previous --format" do
      cli = CLI.new
      mock_file1 = stub(File, :open => nil)
      mock_file2 = stub(File, :open => nil)
      File.stub!(:open).and_return(mock_file1, mock_file2)

      cli.parse_options!(%w{--format progress --out file1 --format profile --out file2})
      cli.options[:formats].should == {'progress' => [mock_file1], 'profile' => [mock_file2]}
    end

    it "should allow a single formatter to have STDOUT and a file" do
      cli = CLI.new
      mock_file = stub(File, :open => nil)
      File.stub!(:open).and_return(mock_file)

      cli.parse_options!(%w{--format progress --format progress --out file})
      cli.options[:formats].should == {'progress' => [STDOUT, mock_file]}
    end

    it "should register --out files with an output broadcaster" do
      cli = CLI.new
      mock_file = stub(File)
      File.stub!(:open).and_return(mock_file)
      mock_output_broadcaster = mock_broadcaster
      Broadcaster.stub!(:new).and_return(mock_broadcaster, mock_output_broadcaster)
      
      mock_output_broadcaster.should_receive(:register).with(mock_file)
      cli.parse_options!(%w{--out test.file})

      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end

    it "should register --formatters with the formatter broadcaster" do
      cli = CLI.new
      mock_progress_formatter = stub(Formatters::ProgressFormatter)
      Formatters::ProgressFormatter.stub!(:new).and_return(mock_progress_formatter)
      mock_formatter_broadcaster = mock_broadcaster
      Broadcaster.stub!(:new).and_return(mock_formatter_broadcaster, mock_broadcaster)
   
      mock_formatter_broadcaster.should_receive(:register).with(mock_progress_formatter)
      cli.parse_options!(%w{--format progress})
      
      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end

    it "should setup the executor with the formatter broadcaster" do
      cli = CLI.new
      broadcaster = Broadcaster.new
      Broadcaster.stub!(:new).and_return(broadcaster)
      mock_executor = mock_executor()
      mock_executor.should_receive(:formatters=).with(broadcaster)
      cli.parse_options!(%w{--format progress})

      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end
    
    describe "--format with class" do
     
     describe "in module" do

        it "should resolve each module until it gets Formatter class" do
          cli = CLI.new
          mock_module = mock('module')
          cli.parse_options!(%w{--format ZooModule::MonkeyFormatterClass})
          Object.stub!(:const_defined?).and_return(true)
          mock_module.stub!(:const_defined?).and_return(true)

          Object.should_receive(:const_get).with('ZooModule').and_return(mock_module)
          mock_module.should_receive(:const_get).with('MonkeyFormatterClass').and_return(mock('formatter class', :new => nil))

          cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end

      end
     
      describe "exists and valid constructor" do
     
        before(:each) do
          @mock_formatter_class = mock('formatter class')
          Object.stub!(:const_get).and_return(@mock_formatter_class)
          Object.stub!(:const_defined?).with('magical').and_return(true)
        end
        
        it "should create the formatter" do
          cli = CLI.new
          mock_formatter = mock('magical formatter')
          cli.parse_options!(%w{--format magical})

          @mock_formatter_class.should_receive(:new)

          cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
                
        it "should register the formatter with broadcaster" do
          cli = CLI.new
          broadcaster = Broadcaster.new
          mock_formatter = mock('magical formatter')
          Broadcaster.stub!(:new).and_return(broadcaster, stub("output broadcaster", :register => nil))
          @mock_formatter_class.stub!(:new).and_return(mock_formatter)
          cli.parse_options!(%w{--format magical})

          broadcaster.should_receive(:register).with(mock_formatter)
        
          cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
      
      end
          
      describe "exists but invalid constructor" do

        before(:each) do
          @out = StringIO.new
          @error = StringIO.new
          @cli = CLI.new(@out, @error)
          
          mock_formatter_class = stub('formatter class')
          mock_formatter_class.stub!(:new).and_raise("No such method")
          Object.stub!(:const_get).and_return(mock_formatter_class)
          Object.stub!(:const_defined?).with('exists_but_evil').and_return(true)
          
          @cli.parse_options!(%w{--format exists_but_evil}) 
        end
        
        it "should show exception" do
          Kernel.stub!(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))

          @error.string.should include("No such method")
        end
        
        it "should exit" do
          Kernel.should_receive(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
                
      end
          
      describe "non-existent" do

        before(:each) do
          @out = StringIO.new
          @error = StringIO.new
          @cli = CLI.new(@out, @error)
          
          @cli.parse_options!(%w{--format invalid})
        end

        it "should display a format error" do
          Kernel.stub!(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
          
          @error.string.should include("Invalid format: invalid\n")
        end
        
        it "should display --help" do
          Kernel.stub!(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
          
          @out.string.should include("Usage: cucumber")
        end

        it "should exit" do
          Kernel.should_receive(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
        
      end
            
    end

    it "should accept multiple --scenario options" do
      cli = CLI.new
      cli.parse_options!(['--scenario', "User logs in", '--scenario', "User signs up"])
      cli.options[:scenario_names].should include("User logs in")
      cli.options[:scenario_names].should include("User signs up")
    end

    it "should register --scenario options with the executor" do
      cli = CLI.new
      cli.parse_options!(['--scenario', "User logs in", '--scenario', "User signs up"])
      executor = mock_executor
      executor.should_receive(:scenario_names=).with(["User logs in", "User signs up"])
      cli.execute!(stub('step mother'), executor, stub('features'))
    end

    it "should accept --color option" do
      cli = CLI.new
      cli.parse_options!(['--color'])
      cli.options[:color].should == true
      Term::ANSIColor.should_receive(:coloring=).with(true)
      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end

    it "should accept --no-color option" do
      cli = CLI.new
      cli.parse_options!(['--no-color'])
      cli.options[:color].should == false
      Term::ANSIColor.should_receive(:coloring=).with(false)
      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end

    it "should accept --color and --no-color and use the last one" do
      cli = CLI.new
      cli.parse_options!(['--color', '--no-color'])
      cli.options[:color].should == false
      Term::ANSIColor.should_receive(:coloring=).with(false)
      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end

    it "should use a default color setting if no option is given" do
      cli = CLI.new
      cli.parse_options!(['--'])
      cli.options[:color].should == nil
      Term::ANSIColor.should_not_receive(:coloring=)
      cli.execute!(stub('step mother'), mock_executor, stub('features'))
    end

    describe "--backtrace" do
      before do
        Exception.cucumber_full_backtrace = false
      end
      
      it "should show full backtrace when --backtrace is present" do
        cli = CLI.new
        cli.parse_options!(['--backtrace'])
        begin
          "x".should == "y"
        rescue => e
          e.cucumber_backtrace[0].should_not == "#{__FILE__}:#{__LINE__ - 2}"
        end
      end

      it "should strip gems when --backtrace is absent" do
        cli = CLI.new
        cli.parse_options!(['--'])
        begin
          "x".should == "y"
        rescue => e
          e.cucumber_backtrace[0].should == "#{__FILE__}:#{__LINE__ - 2}"
        end
      end

      after do
        Exception.cucumber_full_backtrace = false
      end
    end

    describe "example.feature:line file arguments" do

      it "should extract line numbers" do
        cli = CLI.new
        cli.parse_options!(%w{example.feature:10})
      
        cli.options[:lines_for_features]['example.feature'].should == [10]
      end
    
      it "should remove line numbers" do
        cli = CLI.new
        cli.parse_options!(%w{example.feature:10})
      
        cli.paths.should == ["example.feature"]
      end

      it "should support multiple feature:line numbers" do
        cli = CLI.new
        cli.parse_options!(%w{example.feature:11 another_example.feature:12})
      
        cli.options[:lines_for_features].should == {'another_example.feature' => [12], 'example.feature' => [11]}
      end

      it "should accept multiple line numbers for a single feature" do
        cli = CLI.new
        cli.parse_options!(%w{example.feature:11:12})
      
        cli.options[:lines_for_features].should == {'example.feature' => [11, 12]}
      end
    end

    it "should search for all features in the specified directory" do
      cli = CLI.new

      cli.parse_options!(%w{feature_directory/})
      File.stub!(:directory?).and_return(true)

      Dir.should_receive(:[]).with("feature_directory/**/*.feature").any_number_of_times.and_return([])
      
      cli.execute!(stub('step mother'), mock_executor, mock_features)
    end

  end
end
