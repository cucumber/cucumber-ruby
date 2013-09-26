
module Cucumber
  module FeatureGraph
    
    class HeapState
      include Comparable

      attr_accessor :objects
      attr_reader :out_edge, :in_edge


      def initialize
        @objects = Cucumber::FeatureGraph::HOArray.new
        @out_edge = []
        @in_edge = []
      end

      def add_object(object)
        #check if object already inserted      
        objs2class = @objects.find(object.class_name)
        #check if var_list is the same
        found = false
        objs2class.each do |obj|
          if obj == object then
            if obj.var_list == object.var_list then
              found = true
              break
            end
          end
        end
        @objects << object if !found
      end

      def add_out_edge(new_edge)
        @out_edge.push(new_edge) 
      end

      def add_in_edge(new_edge)
        @in_edge.push(new_edge)
      end

      def to_s
        vertex_name = ""
        @objects.each do |obj|
          vertex_name += obj.class_name.to_s + "(" + obj.id.to_s + ") "
          vertex_name +="with: " if obj.var_list.size > 0
          obj.var_list.each_pair do |var, value|
            vertex_name += " #{var}->#{value}, "
          end if !obj.var_list.empty?
          vertex_name += "\\n" if @objects.index(obj) < (@objects.size-1)
        end
        if vertex_name.empty? then
          vertex_name = "INIT\\n"
        end
        vertex_name
      end


      def erase_object_ids
        @objects.each do |object|
          object.id = 0
        end
      end


      def <=>(other)
        if other.objects.size > @objects.size then 
          return 1
        elsif other.objects.size < @objects.size then
          return -1
        else
          if other.objects.sort == @objects.sort then 
            return 0
          else
            pos1 = 0
            other.objects.sort.each do |obj|
              #find position in other array
              pos2 = @objects.index(obj)
              if pos2 > pos1 then
                return -1
              elsif pos2 < pos2 then
                return 1
              end
              pos1 +=1 #save position in this array
            end
            return 0
          end
        end
      end #<=>
    end #class end

    class StepEdge
      attr_accessor :step_name, :keyword, :start_state, :end_state;
      attr_accessor :lines_of_test_code #TODO debug 

      def initialize(step_name, keyword)
        @step_name = step_name
        @keyword = keyword
      end
    end

    # graph structure for feature graph
    class Graph
      attr_accessor :init_state
      attr_reader :states, :edges

      def initialize
        @init_state = Cucumber::FeatureGraph::HeapState.new #always creates an empty initial state at start-up
        @states = [@init_state]
        @edges = []
      end

      def erase_object_ids
        states.each do |state|
          state.erase_object_ids
        end
      end

      # connect a new node to the init state with an edge
      def add_to_init_state(step_name, keyword, objects, lines=0)
        new_state = add_new_node(objects)
        new_edge = Cucumber::FeatureGraph::StepEdge.new(step_name, keyword)
        new_edge.lines_of_test_code = lines
        @init_state.add_out_edge(new_edge)
        new_state.add_in_edge(new_edge)
        new_edge.start_state = @init_state
        new_edge.end_state = new_state
        @edges << new_edge
      end


      def same_vars(old_vars, new_vars)
        old_vars.each do |var, value|
          if new_vars[var] != value then    
            return false
          end
        end
        true
      end

      def compare(state, objects)
        return false if state.objects.size != objects.size 
        state.objects.each do |object|
          if object.id != 0 then
            return false if objects.index(object).nil?
          else 
            found = false
            objects.each do |obj|
              if object.class_name == obj.class_name then
                if object.var_list == obj.var_list then
                  found = true
                end
              end
            end
            return false if !found
          end
        end
        return true
      end

      def already_in_graph(objects)
        @states.each do |state|
          if compare(state, objects) then
            return state
          end
        end
        return nil
      end

      def add_new_node(objects)
        #check if node is already in graph
        new_state = already_in_graph(objects)
        if new_state.nil? then
          new_state = Cucumber::FeatureGraph::HeapState.new
          objects.each do |object|
            new_state.add_object(object)
          end
          @states << new_state
        end
        new_state
      end


      def edge_in_graph?(step_name, keyword, lines=0)
        new_edge = Cucumber::FeatureGraph::StepEdge.new(step_name, keyword)
        new_edge.lines_of_test_code = lines
        @edges << new_edge
        return new_edge 
      end

      def add_transititon_to(last_state, step_name, keyword, lines)
        #check if edge already exists
        new_edge = edge_in_graph?(step_name, keyword, lines)
        #check if there exists a state from
        if new_edge.start_state.nil? then
          #completely new edge
          new_edge.start_state = last_state
          last_state.add_out_edge(new_edge)
          return new_edge
        elsif new_edge.start_state == last_state
          return new_edge
        else 
          #need a new edge (but the same)
          edge = new_edge.clone
          edge.start_state = last_state
          last_state.add_out_edge(new_edge)
          return edge 
        end
      end

      def add_node_to(new_edge, objects)
        new_node = add_new_node(objects)
        new_edge.end_state = new_node
        new_node.add_in_edge(new_edge)
        new_node
      end

      def edge_in_graph? step_name
        @edges.each do |edge|
          if edge.step_name == step_name then
            return edge
          end
        end
        return nil
      end

      def create_edge(step_name, keyword, lines=0)
        edge = Cucumber::FeatureGraph::StepEdge.new(step_name, keyword)
        edge.lines_of_test_code = lines
        @edges << edge
        edge
      end

      def add_edge_w_node(last_state, step_name, keyword, lines, objects)
        edge = edge_in_graph? step_name
        if edge.nil? then
          #add to state
          edge = create_edge(step_name, keyword, lines)
          edge.start_state = last_state
          last_state.add_out_edge(edge)
          return add_node_to(edge, objects)
        elsif edge.start_state == last_state then
          #if same states than check to state
          #is the to state known
          node_known = already_in_graph(objects)
          if node_known then
            #both states are known, do not insert anything
            return add_new_node(objects)
          else
            new_edge = create_edge(step_name, keyword, lines)
            new_edge.start_state = last_state
            last_state.add_out_edge(new_edge)
            return add_node_to(new_edge, objects)
          end
        else 
          #from node is not the same but is known
          new_edge = create_edge(step_name, keyword, lines)
          new_edge.start_state = last_state
          last_state.add_out_edge(new_edge)
          return add_node_to(new_edge, objects)
        end
      end

      def dot_node(state, index)
        label="#{index} [label=\""
        if state == @init_state then
          label += "INIT"
        else
          label += "No objects created" if state.objects.size==0
          state.objects.each do |object|
            label += object.class_name.to_s + "\\n"
            #insert variable list
            label += "Attributes:\\n" if !object.var_list.empty?
            object.var_list.each_pair do |var, value|
              label += " #{var}->#{value}\\n "
            end if !object.var_list.empty?
          end
        end
        label += "\"];\n"
        label
      end

      def dot_edge(state, index)
        edges = ""
        state.in_edge.each do |trans|
          #find index of state
          from_index = @states.index(trans.start_state) 
          to_index = @states.index(trans.end_state) 
          edges += "#{from_index} -> #{to_index} [label=\"#{trans.keyword}#{trans.step_name}\"];\n"
        end
        edges
        
      end

      def write_to_dot(io)
        #write DOT header
        io.puts("digraph feature_graph {\n")
        
        i = 0 
        @states.each do |state|
          #write dot node with label
          io.puts(dot_node(state, i))
          #write edges between nodes
          io.puts(dot_edge(state, i))
          i+=1
        end

        #write DOT closing
        io.puts("}\n")
      end

    end
  end
end
