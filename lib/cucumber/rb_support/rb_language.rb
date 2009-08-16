require 'cucumber/rb_support/rb_dsl'
require 'cucumber/rb_support/rb_step_definition'

module Cucumber
  module RbSupport
    class NilWorld < StandardError
      def initialize
        super("World procs should never return nil")
      end
    end

    class MultipleWorld < StandardError
      def initialize(first_proc, second_proc)
        message = "You can only pass a proc to #World once, but it's happening\n"
        message << "in 2 places:\n\n"
        message << first_proc.backtrace_line('World') << "\n"
        message << second_proc.backtrace_line('World') << "\n\n"
        message << "Use Ruby modules instead to extend your worlds. See the Cucumber::StepMother#World RDoc\n"
        message << "or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.\n\n"
        super(message)
      end
    end

    class RbLanguage
      include LanguageSupport::LanguageMethods
      attr_reader :current_world, :step_mother
      
      def initialize(step_mother)
        @step_mother = step_mother
        RbDsl.step_mother = step_mother
        RbDsl.rb_language = self
      end
      
      def load_step_def_file(step_def_file)
        begin
          require step_def_file
        rescue LoadError => e
          e.message << "\nFailed to load #{step_def_file}"
          raise e
        end
      end
      
      def build_world_factory(*world_modules, &proc)
        if(proc)
          raise MultipleWorld.new(@world_proc, proc) if @world_proc
          @world_proc = proc
        end
        @world_modules ||= []
        @world_modules += world_modules
      end

      def begin_scenario
        create_world
        extend_world
        connect_world(@step_mother)
      end

      def end_scenario
        @current_world = nil
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class = nil)
        escaped = Regexp.escape(step_name).gsub('\ ', ' ').gsub('/', '\/')
        escaped = escaped.gsub(PARAM_PATTERN, ESCAPED_PARAM_PATTERN)

        n = 0
        block_args = escaped.scan(ESCAPED_PARAM_PATTERN).map do |a|
          n += 1
          "arg#{n}"
        end
        block_args << multiline_arg_class.default_arg_name unless multiline_arg_class.nil?
        block_arg_string = block_args.empty? ? "" : " |#{block_args.join(", ")}|"
        multiline_class_comment = ""
        if(multiline_arg_class == Ast::Table)
          multiline_class_comment = "# #{multiline_arg_class.default_arg_name} is a #{multiline_arg_class.to_s}\n  "
        end

        "#{step_keyword} /^#{escaped}$/ do#{block_arg_string}\n  #{multiline_class_comment}pending\nend"
      end

      def alias_adverbs(adverbs)
        adverbs.each do |adverb|
          RbDsl.alias_adverb(adverb)
          World.alias_adverb(adverb)
        end
      end

      private

      PARAM_PATTERN = /"([^\"]*)"/
      ESCAPED_PARAM_PATTERN = '"([^\\"]*)"'

      def create_world
        if(@world_proc)
          @current_world = @world_proc.call
          check_nil(@current_world, @world_proc)
        else
          @current_world = Object.new
        end
      end

      def extend_world
        @current_world.extend(World)
        @current_world.extend(::Spec::Matchers) if defined?(::Spec::Matchers)
        (@world_modules || []).each do |mod|
          @current_world.extend(mod)
        end
      end

      def connect_world(step_mother)
        @current_world.__cucumber_step_mother = step_mother
      end

      def check_nil(o, proc)
        if o.nil?
          begin
            raise NilWorld.new
          rescue NilWorld => e
            e.backtrace.clear
            e.backtrace.push(proc.backtrace_line("World"))
            raise e
          end
        else
          o
        end
      end
    end
  end
end