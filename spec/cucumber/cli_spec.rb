require File.dirname(__FILE__) + '/../spec_helper'
require 'yaml'

module Cucumber
  describe CLI do
    
    def mock_executor(stubs = {})
      stub('executor', {:visit_features => nil, :failed => false, :formatters= => nil}.merge(stubs))
    end
    
    def mock_broadcaster(stubs = {})
      stub(Broadcaster, {:register => nil}.merge(stubs))
    end
    
    it "should expand args from YAML file" do
      cli = CLI.new

      cucumber_yml = {'bongo' => '--require from/yml'}.to_yaml
      IO.should_receive(:read).with('cucumber.yml').and_return(cucumber_yml)

      cli.parse_options!(%w{--format progress --profile bongo})
      cli.options.should == {
        :formats => {'progress' => [STDOUT]},
        :require => ['from/yml'],
        :dry_run => false,
        :lang => 'en',
        :source => true,
        :snippets => true,
        :excludes => [],
        :scenario_names => nil
      }
    end

    it "should expand args from YAML file's default if there are no args" do
      cli = CLI.new

      cucumber_yml = {'default' => '--require from/yml'}.to_yaml
      IO.should_receive(:read).with('cucumber.yml').and_return(cucumber_yml)

      cli.parse_options!([])
      cli.options.should == {
        :formats => {'pretty' => [STDOUT]},
        :require => ['from/yml'],
        :dry_run => false,
        :lang => 'en',
        :source => true,
        :snippets => true,
        :excludes => [],
        :scenario_names => nil
      }
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

    it "should search for all features in the specified directory" do
      cli = CLI.new

      cli.parse_options!(%w{feature_directory/})
      File.stub!(:directory?).and_return(true)

      Dir.should_receive(:[]).with("feature_directory/**/*.feature").any_number_of_times.and_return([])
      
      cli.execute!(stub('step mother'), mock_executor, stub('features', :<< => nil))
    end

  end
end
