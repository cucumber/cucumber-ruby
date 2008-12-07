require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'
require 'cucumber/tree/top_down_visitor'

module Cucumber
  module Formatters
    class MiniExecutor < Cucumber::Tree::TopDownVisitor
      def initialize(f)
        @f = f
      end
      
      def visit_step(step)
        if step.regexp == //
          # Just make sure there are some params so we can get <span>s
          proc = lambda do |_|
            case(step.id % 3)
            when 0
              raise Pending
            when 1
              raise "This one failed"
            end
          end
          proc.extend(CoreExt::CallIn)
          proc.name = "WHATEVER"
          step.attach(/(\w+).*/, proc, ['xxx'])
          o = Object.new
          step.execute_in(o) rescue nil
        else
          @f.step_executed(step)
        end
      end
    end
  
    describe HtmlFormatter do
      SIMPLE_DIR = File.dirname(__FILE__) + '/../../../examples/simple'

      def mock_row_step(stubs = {})
        mock('row step', {:id => 1, :outline? => true, :regexp_args_proc => [nil, nil, nil], :visible_args => []}.merge(stubs))
      end
      
      def mock_step(stubs = {})
        mock('step', {:id => 1, :keyword => 'Given', :format => '', :regexp_args_proc => [nil, nil, nil]}.merge(stubs))
      end
      
      def mock_scenario_outline(stubs = {})
        mock('scenario outline', {:table_header => nil, :accept => nil}.merge(stubs))
      end
      
      before do
        p = Cucumber::TreetopParser::FeatureParser.new
        @features = Tree::Features.new
      	Dir["#{SIMPLE_DIR}/*.feature"].each do |f|
          @features << p.parse_feature(f)
        end
        @io = StringIO.new
        step_mother = mock('step mother')
        @formatter = HtmlFormatter.new(@io, step_mother)
        @me = MiniExecutor.new(@formatter)
      end
      
      xit "should render HTML" do
        @me.visit_features(@features) # set regexp+proc+args and execute
        @formatter.visit_features(@features)
        @me.visit_features(@features) # output result of execution
        @formatter.dump
        expected_html = File.dirname(__FILE__) + '/features.html'
        #File.open(expected_html, 'w') {|io| io.write(@io.string)}
        @io.string.should eql(IO.read(expected_html))
      end
      
      it "should render FIT table headers" do
        scenario = mock('scenario', :name => 'test', :accept => nil)
        row_scenario = mock('row scenario', :name => 'test', :accept => nil)
        scenario.stub!(:table_header).and_return(['test', 'fit', 'headers'])
                
        @formatter.visit_regular_scenario(scenario)
        @formatter.visit_row_scenario(row_scenario)
        
        ['test', 'fit' ,'headers'].each do |column_header|
          @io.string.should include(column_header)
        end
      end

      it "should only show arguments in a row step outline that are visible" do
        @formatter.visit_row_step(mock_row_step(:outline? => true, :regexp_args_proc => [nil, ['mouse', 'monkey'], nil], :visible_args => ['mouse']))
        
        @io.string.should_not =~ /monkey/
      end

      it "should escape placeholders in step outline" do
        CGI.should_receive(:escapeHTML).with("I'm a <placeholder>")
                
        @formatter.visit_step_outline(mock_step(:format => "I'm a <placeholder>"))
      end
      
      it "should show Scenario Outline keyword for scenario outline" do
        @formatter.visit_scenario_outline(mock_scenario_outline(:name => "outline", :accept => nil))
        
        @io.string.should =~ /Scenario Outline/
      end
      
    end
  end
end
