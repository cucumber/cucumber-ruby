require File.dirname(__FILE__) + '/../../spec_helper'

module Cucumber
  module TreetopParser
    describe FeatureParser do
      it "should parse features with weird spaces" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/spaces.feature')
        
        v = Object.new.instance_eval do
          def visit_header(h)
            h.should == "Some title"
          end

          def visit_scenario(s)
            def self.visit_scenario(s)
              s.name.should == "second"
              s.accept(self)
            end

            s.name.should == "first"
            s.accept(self)
          end
          
          def visit_regular_scenario(s)
          end

          def visit_step(s)
            def self.visit_step(s)
              s.name.should == "b"
            end

            s.name.should == "a"
          end
          
          self
        end
        
        f.accept(v)
      end
      
      it "should parse GivenScenario" do
        p = FeatureParser.new
        f = p.parse_feature(File.dirname(__FILE__) + '/given_scenario.feature')

        f.header.should == "Some title"
        f.should have(2).scenarios

        first = f.scenarios[0]
        first.should have(2).steps

        second = f.scenarios[1]
        second.should have(3).steps
      end
      
      it "should allow spaces between FIT values" do
        p = FeatureParser.new
        Cucumber::Tree::RowScenario.should_receive(:new).with(anything,anything, ['I can have spaces'], anything)
        
        f = p.parse_feature(File.dirname(__FILE__) + '/fit_scenario.feature')
      end
      
    end
  end
end