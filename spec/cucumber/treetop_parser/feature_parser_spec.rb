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

          def visit_scenario(h)
            def self.visit_scenario(h)
              h.name.should == "second"
              h.accept(self)
            end

            h.name.should == "first"
            h.accept(self)
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
        first.should have(1).steps

        second = f.scenarios[1]
        second.should have(1).given_scenarios
      end
    end
  end
end