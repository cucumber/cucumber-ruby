require 'fileutils'
require 'cucumber/formatter/feature_graph/heap_getter'
require 'cucumber/formatter/feature_graph/graph'
require 'cucumber/formatter/io'

module Cucumber
  module Formatter
    class FeatureGraph
      include Io

      def initialize(runtime, path_or_io, options)
        @io = ensure_io(path_or_io, "fg")
        @runtime = runtime
        @options = options
        @heap_getter = Cucumber::FeatureGraph::HeapGetter.new("lib/**/*.rb", @io)
        @heap_getter.save_obj_space
        
        @classes = @heap_getter.classes #all classes
        create_class_methods
        
        #create graph
        @graph = Cucumber::FeatureGraph::Graph.new
        
        #the last state is the init state of all steps (should not contain any objects)
        @last_state = @graph.init_state
        @last_transition = nil
        @current_test_code_lines = 0
      end
     
      # hooks 
      def after_step( step )
        objs = @heap_getter.save_obj_space
        new_node = @graph.add_edge_w_node(@last_state, step.name, step.keyword, @current_test_code_lines, objs)
        @last_state = new_node
      end

      def before_feature_element( feature_element )
        #erase object ids to be able to compare objects from other scenarios
        @graph.erase_object_ids
      end
      
      def after_feature_element( feature_element)
        #trashing all objects from last scenario (they are not new!)
        @heap_getter.trash_objects
        #reset last state to init_state (start point)
        @last_state = @graph.init_state
      end


      def after_features(features)
        @graph.write_to_dot(@io)
      end

      # Helper methods
      def create_class_methods
        @class_methods = {}

        @classes.each do |klass|
          methods = @heap_getter.get_class_methods(klass)

          if  methods != false and methods.empty? then
            if @class_methods[methods].nil? then
              @class_methods[methods] = [klass]
            else
              @class_methods[methods] = @class_methods[methods].push(klass)
            end
          end

          if methods != false then
            methods.each do |method| 
              if @class_methods[method].nil? then
                @class_methods[method] = [klass]
              else
                @class_methods[method] = @class_methods[method].push(klass)
              end
            end
          end
        end
        @class_methods
      end
    end
  end

end
