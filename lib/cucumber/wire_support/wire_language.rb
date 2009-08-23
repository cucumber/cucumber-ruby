module Cucumber
  module WireSupport
    # The wire-protocol lanugage independent implementation of the programming language API.
    class WireLanguage
      include LanguageSupport::LanguageMethods

      def initialize(step_mother)
        @python_path = ENV['PYTHONPATH'] ? ENV['PYTHONPATH'].split(':') : []
        add_to_python_path(File.dirname(__FILE__))

        RubyPython.start
        at_exit{RubyPython.stop}

        import(File.dirname(__FILE__) + '/py_language.py')
      end

      def alias_adverbs(adverbs)
      end

      def step_definitions_for(py_file)
        mod = import(py_file)
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class = nil)
        "python snippet: #{step_keyword}, #{step_name}"
      end

      protected

      def begin_scenario
      end

      def end_scenario
      end

      

      end
    end
  end
end