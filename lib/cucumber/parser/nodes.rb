module Cucumber
  module Parser
    # This is the root node of a story execution
    class StoriesNode
      def initialize(files, parser)
        @stories = files.map{|f| StoryNode.parse(f, parser)}
      end

      def accept(visitor)
        @stories.each{|story| visitor.visit_story(story)}
      end
    end
    
    class StoryNode < Treetop::Runtime::SyntaxNode
      def self.parse(file, parser)
        story = parser.parse(IO.read(file))
        if story.nil?
          raise parser.compile_error(file)
        end
        story.file = file
        story
      end
      
      attr_accessor :file

      def accept(visitor)
        visitor.visit_header(header)
        visitor.visit_narrative(narrative)
        scenario_nodes.elements.each do |scenario_node|
          visitor.visit_scenario(scenario_node)
        end
      end
    end
    
    class HeaderNode < Treetop::Runtime::SyntaxNode
      def name
        sentence_line.text_value.strip
      end
    end
    
    class NarrativeNode < Treetop::Runtime::SyntaxNode
      def narrative
        text_value
      end
    end
    
    class ScenarioNode < Treetop::Runtime::SyntaxNode
      def accept(visitor)
        step_nodes.elements.each do |step_node|
          visitor.visit_step(step_node)
        end
      end

      def name
        sentence.text_value.strip
      end

      def file
        parent.parent.file
      end
    end
    
    class StepNode < Treetop::Runtime::SyntaxNode
      class << self
        def new_id!
          @next_id ||= -1
          @next_id += 1
        end
      end

      attr_reader :error

      def regexp
        @regexp || //
      end
      
      PENDING = lambda do |*_| 
        raise Pending
      end
      PENDING.extend(CoreExt::CallIn)
      PENDING.name = "PENDING"
      
      def proc
        @proc || PENDING
      end

      def attach(regexp, proc, args)
        if @regexp
          raise <<-EOM
"#{name}" matches several step definitions:

#{@proc.backtrace_line}
#{proc.backtrace_line}

Please give your steps unambiguous names
          EOM
        end
        @regexp, @proc, @args = regexp, proc, args
      end

      def execute_in(world)
        begin
          proc.call_in(world, *@args)
        rescue ArgCountError => e
          e.backtrace[0] = @proc.backtrace_line
          strip_pos = e.backtrace.index("#{__FILE__}:#{__LINE__-3}:in `execute_in'")
          format_error(strip_pos, e)
        rescue => e
          method_line = "#{__FILE__}:#{__LINE__-6}:in `execute_in'"
          method_line_pos = e.backtrace.index(method_line)
          if method_line_pos
            strip_pos = method_line_pos - (Pending === e ? 3 : 2)
          else
            # This happens with rails, because they screw up the backtrace
            # before we get here (injecting erb stactrace and such)
      	  end
          format_error(strip_pos, e)
        end
      end

      def format_error(strip_pos, e)
        @error = e
        # Remove lines underneath the plain text step
        e.backtrace[strip_pos..-1] = nil unless strip_pos.nil?
        e.backtrace.flatten
        # Replace the step line with something more readable
        e.backtrace.replace(e.backtrace.map{|l| l.gsub(/`#{@proc.meth}'/, "`#{keyword} #{@proc.name}'")})
        e.backtrace << "#{file}:#{line}:in `#{keyword} #{name}'"
        raise e
      end

      def gzub(format=nil, &proc)
        name.gzub(regexp, format, &proc)
      end

      def line
        input.line_of(interval.first)
      end

      def name
        sentence.text_value.strip
      end

      def keyword
        step_type.text_value.strip
      end

      def file
        parent.parent.file
      end
      
      def id
        @id ||= self.class.new_id!
      end

    end
  end
end