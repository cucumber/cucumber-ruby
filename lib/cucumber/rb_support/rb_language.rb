require 'cucumber/rb_support/rb_dsl'
require 'cucumber/rb_support/rb_world'
require 'cucumber/rb_support/rb_step_definition'

module Cucumber
  module RbSupport
    # Raised if a World block returns Nil.
    class NilWorld < StandardError
      def initialize
        super("World procs should never return nil")
      end
    end

    # Raised if there are 2 or more World blocks.
    class MultipleWorld < StandardError
      def initialize(first_proc, second_proc)
        message = "You can only pass a proc to #World once, but it's happening\n"
        message << "in 2 places:\n\n"
        message << first_proc.backtrace_line('World') << "\n"
        message << second_proc.backtrace_line('World') << "\n\n"
        message << "Use Ruby modules instead to extend your worlds. See the Cucumber::RbSupport::RbDsl#World RDoc\n"
        message << "or http://wiki.github.com/aslakhellesoy/cucumber/a-whole-new-world.\n\n"
        super(message)
      end
    end

    # The Ruby implementation of the programming language API.
    class RbLanguage
      include LanguageSupport::LanguageMethods
      attr_reader :current_world
      
      def initialize(step_mother)
        @step_mother = step_mother
        RbDsl.rb_language = self
      end

      def alias_adverbs(adverbs)
        adverbs.each do |adverb|
          RbDsl.alias_adverb(adverb)
          RbWorld.alias_adverb(adverb)
        end
      end

      def step_definitions_for(code_file)
        begin
          load_code_file(code_file)
          step_definitions
        rescue LoadError => e
          e.message << "\nFailed to load #{code_file}"
          raise e
        ensure
          @step_definitions = nil
        end
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

      def begin_rb_scenario
        create_world
        extend_world
        connect_world
      end

      def register_rb_hook(phase, tag_names, proc)
        add_hook(phase, RbHook.new(self, tag_names, proc))
      end

      def register_rb_step_definition(regexp, proc)
        add_step_definition(RbStepDefinition.new(self, regexp, proc))
      end

      def build_rb_world_factory(world_modules, proc)
        if(proc)
          raise MultipleWorld.new(@world_proc, proc) if @world_proc
          @world_proc = proc
        end
        @world_modules ||= []
        @world_modules += world_modules
      end

      protected

      def load_code_file(code_file)
        require code_file # This will cause self.add_step_definition and self.add_hook to be called from RbDsl
      end

      def begin_scenario
        begin_rb_scenario
      end
      
      def end_scenario
        @current_world = nil
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
        @current_world.extend(RbWorld)
        @current_world.extend(::Spec::Matchers) if defined?(::Spec::Matchers)
        (@world_modules || []).each do |mod|
          @current_world.extend(mod)
        end
      end

      def connect_world
        @current_world.__cucumber_step_mother = @step_mother
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