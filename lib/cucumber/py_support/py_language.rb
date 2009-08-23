require 'rubypython'

module Cucumber
  module PySupport
    class PyLanguage
#      include LanguageSupport::LanguageMethods

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

      private

      def import(path)
        modname = File.basename(path)[0...-File.extname(path).length]
        begin
          mod = RubyPython.import(modname)
        rescue PythonError => e
          e.message << "Couldn't load #{path}\nConsider adding #{File.expand_path(File.dirname(path))} to your PYTHONPATH"
          raise e
        end
      end

      def add_to_python_path(dir)
        dir = File.expand_path(dir)
        @python_path.unshift(dir)
        @python_path.uniq!
        ENV['PYTHONPATH'] = @python_path.join(':')
      end
    end
  end
end

class String #:nodoc:
  # RubyPython incorrectly to expects String#end_with? to exist.
  unless defined? end_with? # 1.9
    def end_with?(str) #:nodoc:
      str = str.to_str
      tail = self[-str.length, str.length]
      tail == str      
    end
  end
end