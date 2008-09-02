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
      
      before do
        p = Cucumber::TreetopParser::FeatureParser.new
        @features = Tree::Features.new
      	Dir["#{SIMPLE_DIR}/*.feature"].each do |f|
          @features << p.parse_feature(f)
        end
        @io = StringIO.new
        @formatter = HtmlFormatter.new(@io)
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
    end
  end
end
