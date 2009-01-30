require File.dirname(__FILE__) + '/../../spec_helper'
require 'yaml'

module Cucumber
module Cli
  describe Main do
    
    before(:each) do
      Kernel.stub!(:exit).and_return(nil)
    end

    describe "verbose mode" do
      
      before(:each) do
        @out = StringIO.new
        @empty_feature = Ast::Feature.new(Ast::Comment.new(''), Ast::Tags.new(2, []), "Feature", [])
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
     
      describe "exists and valid constructor" do
     
        before(:each) do
          @mock_formatter_class = mock('formatter class')
          Object.stub!(:const_get).and_return(@mock_formatter_class)
          Object.stub!(:const_defined?).with('magical').and_return(true)
        end
        
        xit "should create the formatter" do
          cli = Main.new
          mock_formatter = mock('magical formatter')
          cli.parse_options!(%w{--format magical})

          @mock_formatter_class.should_receive(:new)

          cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
                
        xit "should register the formatter with broadcaster" do
          cli = Main.new
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
          @cli = Main.new(@out, @error)
          
          mock_formatter_class = stub('formatter class')
          mock_formatter_class.stub!(:new).and_raise("No such method")
          Object.stub!(:const_get).and_return(mock_formatter_class)
          Object.stub!(:const_defined?).with('exists_but_evil').and_return(true)
          
          @cli.parse_options!(%w{--format exists_but_evil}) 
        end
        
        xit "should show exception" do
          Kernel.stub!(:exit)

          @cli.execute!(stub('step mother'))

          @error.string.should include("No such method")
        end
        
        xit "should exit" do
          Kernel.should_receive(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
                
      end
          
      describe "non-existent" do

        before(:each) do
          @out = StringIO.new
          @error = StringIO.new
          @cli = Main.new(@out, @error)
          
          @cli.parse_options!(%w{--format invalid})
        end

        xit "should display a format error" do
          Kernel.stub!(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
          
          @error.string.should include("Invalid format: invalid\n")
        end
        
        xit "should display --help" do
          Kernel.stub!(:exit)

          @cli.execute!(stub('step mother'))
          
          @out.string.should include("Usage: cucumber")
        end

        xit "should exit" do
          Kernel.should_receive(:exit)

          @cli.execute!(stub('step mother'), mock_executor, stub('features'))
        end
        
      end
            
    end

  end
end
end