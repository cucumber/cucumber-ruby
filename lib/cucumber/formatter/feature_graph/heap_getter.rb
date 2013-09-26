require 'fileutils'
require 'ruby_parser'

module Cucumber
  module FeatureGraph

    class HeapObject
      include Comparable

      #var_list, Hash, var -> value 
      attr_accessor :id, :class_name, :var_list

      def initialize(id, class_name, var_list)
        @id = id
        @class_name = class_name
        @var_list = var_list
      end

      def <=>(other)
        if @class_name == other.class_name then
          if @id == other.id then
            return @var_list <=> other.var_list
          else
            return @id <=> other.id
          end
        else
          return @class_name <=> other.class_name
        end
      end

    end


    class HOArray < Array
      def find(class_name)
        ruby_objects = []
        self.each do |ruby_object|
          if ruby_object.class_name == class_name then
            ruby_objects << ruby_object
          end
        end
        ruby_objects
      end
    end

    class HeapGetter
      attr_reader :classes

      def initialize(file_list, io)
        @io = io 
        @classes = []
        get_all_classes(file_list)

        @current_obj_map = HOArray.new
        @trash_list = {}
      end


      #parses module-class-names
      def parse(s_exp)
        name = ""
        names = []
        return [] if s_exp == nil
        if s_exp[0] == :class || s_exp[0] == :module 
          if s_exp[1].instance_of? (Symbol)
            name = s_exp[1].to_s
          elsif s_exp[1].instance_of? (Sexp)
            x = s_exp[1].flatten
            subclassed_name = []
            x.each do |elem|
              if elem != :colon2 && elem != :const then
                subclassed_name << elem.to_s
              end
            end
            name= subclassed_name.join("::")
          else
            fail "Not implemented, sorry" #TODO impl failure handling
          end
          start = 2
          ende = s_exp.size
          while start <= ende do
            result = parse(s_exp[start])
            result.uniq!
            if result.empty? then
              names << [name, s_exp[0]]
            else
              result.each do |namepart|
                new_name = [name, s_exp[0]] + namepart.flatten
                names << new_name
              end
            end
            start+=1
          end
          return names
        else 
          #something else, look again
          return parse(s_exp[1])
        end
      end

      # Parse the given string, and return the parsed classes
      def parse_file file_content
        s_exp = RubyParser.new.parse(file_content)
        if s_exp[0] == :module || s_exp[0] == :class
          parse(s_exp).each do |e|
            #only insert classes
            if e[-1] == :class 
              if !e[-2].eql? "HeapObject" then
                @classes << (0).step(e.size-1, 2).map {|i| e[i]}.join("::")
              end
            end
          end
        else
          s_exp.each do |s|
            classes = parse(s)
            if !classes.empty? then
              classes.each do |e|
                #only insert classes
                if e[-1] == :class 
                  if !e[-2].eql? "HeapObject" then
                    @classes << (0).step(e.size-1, 2).map {|i| e[i]}.join("::")
                  end
                end
              end
            end
          end
        end
      end
     
      #get all class names (full path):
      # MODULE::[..]::CLASS
      def get_all_classes(file_list)
        Dir.glob(file_list) do |filepath| 
          filecontent = File.read(filepath)
          parse_file(filecontent) 
        end 
      end


      def trash_objects
        @classes.each do |a_class|
          if (class_exists?(a_class))
            #look for module and get CLASS
            parts = a_class.split("::")
            klass = Class.const_get(parts[0])
            parts = parts.drop(1)
            while parts.size > 0 do
              klass = klass.const_get(parts[0])
              parts = parts.drop(1)
            end
            ObjectSpace.each_object(klass) {|o|
              @trash_list[o.object_id] = o
            }
          end
        end
      end

      def class_exists?(class_name)
        ObjectSpace.each_object(Class) {|c| return true if c.to_s == class_name }
        false
      end

      def get_class_methods(class_name)
        return false if !class_exists?(class_name)
        parts = class_name.split("::")
        klass = Class.const_get(parts[0])
        parts = parts.drop(1)
        while parts.size > 0 do
          klass = klass.const_get(parts[0])
          parts = parts.drop(1)
        end
        (klass.instance_methods - Object.methods) # without initialize and inherited methods TODO
      end

      def create_object_map
        object_map = HOArray.new
        @classes.uniq!
        index = @classes.index("Object") 
        @classes.delete_at(index) if !index.nil?
        @classes.each do |a_class|
          if (class_exists?(a_class))
            #look for module and get CLASS
            parts = a_class.split("::")
            klass = Class.const_get(parts[0])
            parts = parts.drop(1)
            while parts.size > 0 do
              klass = klass.const_get(parts[0])
              parts = parts.drop(1)
            end
            #puts "This class is being run: #{klass}"
            ObjectSpace.each_object(klass) {|o|
              if @trash_list[o.object_id].nil? then
                vars = {}
                o.instance_variables.each do |var|
                  if  o.instance_variable_get(var).instance_of?(Fixnum) || o.instance_variable_get(var).instance_of?(Float) then
                    vars[var] = o.instance_variable_get(var)
                  else
                    vars[var] = o.instance_variable_get(var).to_s
                  end
                end
                object_map << HeapObject.new(o.object_id, klass, vars)
              end
            }
          end
        end
        object_map
      end

      def save_obj_space
        @current_obj_map = create_object_map
        if @current_obj_map.nil? then
          @current_obj_map = {}
        end
        @current_obj_map
      end

    end
  end
end
