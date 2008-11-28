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
      stub('features', :<< => nil)
    end
    
    before(:each) do
      Kernel.stub!(:exit)
    end
    
    def given_cucumber_yml_defined_as(hash)
      File.stub!(:exist?).and_return(true)
      cucumber_yml = hash.to_yaml
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
    
    it "should provide a helpful error message when no YAML file exists and a profile is specified" do
      cli = CLI.new(StringIO.new, error = StringIO.new)
      
      File.should_receive(:exist?).with('cucumber.yml').and_return(false)
    
      cli.parse_options!(%w{--profile i_do_not_exist})
        
      error.string.should match(/cucumber.yml was not found.  Please define your 'i_do_not_exist' and other profiles in cucumber.yml./)
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

    describe "external formatter" do

      describe "exists and valid constructor" do
        
        before(:each) do
          @mock_formatter_class = mock('formatter class')
          Kernel.stub!(:const_get).and_return(@mock_formatter_class)
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
          Kernel.stub!(:const_get).and_return(mock_formatter_class)
          
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
