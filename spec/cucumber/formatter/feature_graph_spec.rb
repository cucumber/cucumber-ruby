require 'spec_helper'
require 'cucumber/formatter/spec_helper'
require 'cucumber/formatter/feature_graph'
require 'cucumber/cli/options'
require 'tempfile'

module Cucumber
  module Formatter
    describe FeatureGraph do
      extend SpecHelperDsl
      include SpecHelper
        before(:each) do
          Cucumber::Term::ANSIColor.coloring = false
          @out = StringIO.new
          @formatter = FeatureGraph.new(runtime, @out, {})
        end

        describe "HeapObject" do
        
          before (:each) do
            @obj1 = Cucumber::FeatureGraph::HeapObject.new(20, "Test1", {"some var" => "Some value"})
            @obj1_not_the_same = Cucumber::FeatureGraph::HeapObject.new(20, "Test1", {"some var" => "Some value", :test => 29})#same class but different attributes
            @obj1_same = Cucumber::FeatureGraph::HeapObject.new(20, "Test1", {"some var" => "Some value"})
            @obj2 = Cucumber::FeatureGraph::HeapObject.new(21, "Test2", {:test => 29, :test2 => 25})
            @obj3 = Cucumber::FeatureGraph::HeapObject.new(22, "Test3", {"some var" => "Some value", :test => 29})#
          end

          it "compares 2 unequal heap-objects" do
            @obj1.should_not eq (@obj1_not_the_same)
            @obj1.should_not eq (@obj2)
            @obj1.should_not eq (@obj3)
          end

          it "compares 2 equal heap-objects" do
            @obj1.should eq (@obj1_same)
          end
         
        end

        describe "States" do

          before(:all) do
            @obj1 = Cucumber::FeatureGraph::HeapObject.new(20, "Test1", {})
            @obj2 = Cucumber::FeatureGraph::HeapObject.new(21, "Test2", {})
            @obj3 = Cucumber::FeatureGraph::HeapObject.new(22, "Test1", {"some var"=>"some value"})
          end
          
          it "compares 2 equal states" do
            state1 = Cucumber::FeatureGraph::HeapState.new
            state1.add_object(@obj1)
            state1.add_object(@obj2)
            state2 = Cucumber::FeatureGraph::HeapState.new
            state2.add_object(@obj1)
            state2.add_object(@obj2)
            state1.should eq (state2)
          end

          it "compares 2 not so equal states" do
            state1 = Cucumber::FeatureGraph::HeapState.new
            state1.add_object(@obj1)
            state1.add_object(@obj2)
            state2 = Cucumber::FeatureGraph::HeapState.new
            state2.add_object(@obj3)
            state2.add_object(@obj2)
            state1.should_not eq (state2)
          end

          it "erases the objects ids" do
            state1 = Cucumber::FeatureGraph::HeapState.new
            state1.add_object(@obj1)
            state1.add_object(@obj2)
            state1.erase_object_ids
            state1.objects.each do |obj|
              obj.id.should eq (0)
            end
          end
        end

        describe "Graph" do
          before(:all) do
            @graph = Cucumber::FeatureGraph::Graph.new
          end

          it "creates an emtpy graph" do
            #should only contain the INIT node
            @graph.states.size.should eq (1)
            @graph.states[0].objects.size.should eq (0)
            @graph.states[0].should eq (@graph.init_state)
          end

          it "does not create a new empty state" do
            @graph.add_new_node([])
            @graph.states.size.should eq (1)
            @graph.states[0].objects.size.should eq (0) #is init state
          end

          it "does not insert the same node twice" do
            obj1 = Cucumber::FeatureGraph::HeapObject.new(20, "Test1", {})
            obj2 = Cucumber::FeatureGraph::HeapObject.new(21, "Test2", {})
            obj3 = Cucumber::FeatureGraph::HeapObject.new(22, "Test1", {"some var"=>"some value"})
            objs = []
            objs << obj1 << obj2 << obj3
            @graph.add_new_node(objs)
            @graph.add_new_node(objs)
            @graph.states.size.should eq (2)
          end
          
          it "insert two nodes" do
            obj1 = Cucumber::FeatureGraph::HeapObject.new(20, "Test1", {})
            obj2 = Cucumber::FeatureGraph::HeapObject.new(21, "Test2", {})
            obj3 = Cucumber::FeatureGraph::HeapObject.new(22, "Test1", {"some var"=>"some value"})
            objs1 = []
            objs2 = []
            objs1 << obj1 << obj2
            objs2 << obj1 << obj2 << obj3
            state1 = @graph.add_new_node(objs1)
            state2 = @graph.add_new_node(objs2)
            state1.should_not eq (state2)
            @graph.states.index(state1).should_not be_nil
            @graph.states.index(state2).should_not be_nil
            @graph.states.index(state2).should_not eq @graph.states.index(state1) 
          end
          
          it "does creates a loop edge at the initial state" do
            @graph.add_edge_w_node(@graph.init_state, "loop edge", "Given ",0, [])
            @graph.init_state.out_edge[0].end_state.should eq (@graph.init_state)
          end
        end

       describe "parsing Ruby classes" do
         before(:all) do
           @class_file = Tempfile
           @class_file = Tempfile.new("class_impl.rb")
           @class_file.write(
             """
           module NotAClass
           end
           module ModuleWithClass
             class TheClass
             end
           end
           module ModuleWithClasses
           class FirstClass
               class SecondClass
               end
             end
           end
           class StandAloneClass1
           end
           class StandAloneClass2
           end
           class ClassHasA::SubClassed::Name
           end
             """
           )
           @class_file.close
           @class_file.open
         end

         after(:all) do
           @class_file.close
           @class_file.unlink    # deletes the temp file
         end

         #parsing files
         it "reads a class in a module" do
           heap_getter = Cucumber::FeatureGraph::HeapGetter.new(@class_file.path, @out)
           heap_getter.classes.should include("ModuleWithClass::TheClass")
         end

         it "does not save a module" do
           heap_getter = Cucumber::FeatureGraph::HeapGetter.new(@class_file.path, @out)
           heap_getter.classes.should_not include("NotAClass")
         end

         it "reads two stand-alone classes " do
           heap_getter = Cucumber::FeatureGraph::HeapGetter.new(@class_file.path, @out)
           heap_getter.classes.should include("StandAloneClass1")
           heap_getter.classes.should include("StandAloneClass2")
         end

         it "reads combined classes " do
           heap_getter = Cucumber::FeatureGraph::HeapGetter.new(@class_file.path, @out)
           heap_getter.classes.should include("ModuleWithClasses::FirstClass::SecondClass")
           heap_getter.classes.should include("ModuleWithClasses::FirstClass")
           heap_getter.classes.should_not include("ModuleWithClasses")
           heap_getter.classes.should_not include("SecondClass")
           heap_getter.classes.should_not include("FirstClass")
         end

         it "reads combined classes " do
           heap_getter = Cucumber::FeatureGraph::HeapGetter.new(@class_file.path, @out)
           heap_getter.classes.should include("ClassHasA::SubClassed::Name")
         end
       end

       describe "DotWriter" do
         before (:each) do
           @graph = Cucumber::FeatureGraph::Graph.new
           @last_state = @graph.init_state
           
           @output = Tempfile.new('my_test_graph.dot')
         end

         after (:each) do
           @output.close
           @output.unlink    # deletes the temp file
         end

         #DOT tests

         # Example:
         # no objects being created by scenarios
         it "prints an empty graph before any objects are created" do
            @graph.write_to_dot(@output)
            @output.open
            lines = @output.read
            lines.should match "0\s\\[label=\"INIT\""
           
            #check if it creates a valid dot file TODO not complete
            lines.start_with?("digraph feature_graph {").should == true
           lines.end_with?("}\n").should == true
         end

         it "prints a dot file while an object has been created" do 
           objs = Cucumber::FeatureGraph::HOArray.new
           obj = Cucumber::FeatureGraph::HeapObject.new(20, "Test", {})
           objs << obj

           @graph.add_edge_w_node(@last_state, "test step", "Given", 10 , objs)
           @graph.write_to_dot(@output)
           @output.open
           lines = @output.read
           lines.should match "1\s\\[.*Test"
           lines.should match "0 -> 1.*;"
           lines.should_not match "[2-9|0]+\\[.*\\]"
         end

         it "prints a dot file while an object with attributes has been created" do 
           objs = Cucumber::FeatureGraph::HOArray.new
           obj = Cucumber::FeatureGraph::HeapObject.new(20, "Test", {"i" => 20})
           objs << obj

           keyword = "Given "
           step = "a test step"
           @graph.add_edge_w_node(@last_state, step, keyword, 10 , objs)
           @graph.write_to_dot(@output)
           @output.open
           lines = @output.read
           lines.should match "1\s\\[.*Test"
           lines.should match "0 -> 1\s\\[label=\"#{keyword}#{step}\"\\];"
           lines.should match "i->20"
         end

         it "prints a dot file with a two nodes on a tree path" do 
           objs = Cucumber::FeatureGraph::HOArray.new
           obj = Cucumber::FeatureGraph::HeapObject.new(20, "First", {})
           objs << obj
           objs2 = Cucumber::FeatureGraph::HOArray.new
           obj2 = Cucumber::FeatureGraph::HeapObject.new(21, "Second", {})
           objs2 << obj2

           new_node = @graph.add_edge_w_node(@last_state, "a first step", "Given", 10 , objs)
           @graph.add_edge_w_node(new_node, "a second step", "Given", 10 , objs2)
           @graph.write_to_dot(@output)
           @output.open
           lines = @output.read
           lines.should match "0\s\\[.*INIT"
           lines.should match "1\s\\[.*First"
           lines.should match "2\s\\[.*Second"
           lines.should match "0 -> 1.*;"
           lines.should match "1 -> 2.*;"
         end

         it "prints a dot file with a two nodes starting from the init state" do 
           objs = Cucumber::FeatureGraph::HOArray.new
           obj = Cucumber::FeatureGraph::HeapObject.new(20, "First", {})
           objs << obj
           objs2 = Cucumber::FeatureGraph::HOArray.new
           obj2 = Cucumber::FeatureGraph::HeapObject.new(21, "First", {}) #same class but different obj
           objs2 << obj2

           @graph.add_edge_w_node(@last_state, "a first step", "Given", 10 , objs)
           @graph.add_edge_w_node(@last_state, "a second step", "Given", 10 , objs2)
           @graph.write_to_dot(@output)
           @output.open
           lines = @output.read
           lines.should match "0\s\\[.*INIT"
           lines.should match "1\s\\[.*First"
           lines.should match "2\s\\[.*First"
           lines.should match "0 -> 1.*;"
           lines.should match "0 -> 2.*;"
         end

         it "prints a dot file with a loop" do 
           objs = Cucumber::FeatureGraph::HOArray.new
           obj = Cucumber::FeatureGraph::HeapObject.new(20, "First", {})
           objs << obj

           new_node = @graph.add_edge_w_node(@last_state, "a first step", "Given", 10 , objs)
           @graph.add_edge_w_node(new_node, "a second step loops", "When", 10 , objs)
           @graph.write_to_dot(@output)
           @output.open
           lines = @output.read
           lines.should match "0\s\\[.*INIT"
           lines.should match "1\s\\[.*First"
           lines.should match "0 -> 1.*;"
           lines.should match "1 -> 1.*;"
         end
       end
    end
  end
end

