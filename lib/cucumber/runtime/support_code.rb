require 'cucumber/constantize'

module Cucumber
  class Runtime
    
    class SupportCode
      class StepInvoker
        include Gherkin::Rubify

        def initialize(support_code)
          @support_code = support_code
        end

        def uri(uri)
        end

        def step(step)
          cucumber_multiline_arg = case(rubify(step.multiline_arg))
          when Gherkin::Formatter::Model::PyString
            step.multiline_arg.value
          when Array
            Ast::Table.new(step.multiline_arg.map{|row| row.cells})
          else
            nil
          end
          @support_code.invoke(step.name, cucumber_multiline_arg) 
        end

        def eof
        end
      end
    
      include Constantize

      def initialize(step_mother, in_guess_mode)
        @step_mother = step_mother
        @guess_step_matches = in_guess_mode
        @unsupported_programming_languages = []
        @programming_languages = []
        @language_map = {}
      end
    
      def invoke_steps(steps_text, i18n, file_colon_line)
        file, line = file_colon_line.split(':')
        parser = Gherkin::Parser::Parser.new(StepInvoker.new(self), true, 'steps')
        parser.parse(steps_text, file, line.to_i)
      end

      def load_programming_language!(ext)
        return @language_map[ext] if @language_map[ext]
        programming_language_class = constantize("Cucumber::#{ext.capitalize}Support::#{ext.capitalize}Language")
        programming_language = programming_language_class.new(@step_mother)
        @programming_languages << programming_language
        @language_map[ext] = programming_language
        programming_language
      end
    
      def load_files!(files)
        log.debug("Code:\n")
        files.each do |file|
          load_file(file)
        end
        log.debug("\n")
      end
      
      def load_files_from_paths(paths)
        files = paths.map { |path| Dir["#{path}/**/*"] }.flatten
        load_files! files
      end
    
      def unmatched_step_definitions
        @programming_languages.map do |programming_language| 
          programming_language.unmatched_step_definitions
        end.flatten
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class) #:nodoc:
        load_programming_language!('rb') if unknown_programming_language?
        @programming_languages.map do |programming_language|
          programming_language.snippet_text(step_keyword, step_name, multiline_arg_class)
        end.join("\n")
      end
    
      def unknown_programming_language?
        @programming_languages.empty?
      end
    
      def fire_hook(name, *args)
        @programming_languages.each do |programming_language|
          programming_language.send(name, *args)
        end
      end
    
      def around(scenario, block)
        @programming_languages.reverse.inject(block) do |blk, programming_language|
          proc do
            programming_language.around(scenario) do
              blk.call(scenario)
            end
          end
        end.call
      end
      
      def step_definitions
        @programming_languages.map do |programming_language|
          programming_language.step_definitions
        end.flatten
      end
    
      def step_match(step_name, name_to_report=nil) #:nodoc:
        matches = matches(step_name, name_to_report)
        raise Undefined.new(step_name) if matches.empty?
        matches = best_matches(step_name, matches) if matches.size > 1 && guess_step_matches?
        raise Ambiguous.new(step_name, matches, guess_step_matches?) if matches.size > 1
        matches[0]
      end
    
      def invoke(step_name, multiline_argument=nil)
        begin
          step_match(step_name).invoke(multiline_argument)
        rescue Exception => e
          e.nested! if Undefined === e
          raise e
        end
      end

    private
  
      def guess_step_matches?
        @guess_step_matches
      end
    
      def matches(step_name, name_to_report)
        @programming_languages.map do |programming_language| 
          programming_language.step_matches(step_name, name_to_report).to_a
        end.flatten
      end

      def best_matches(step_name, step_matches) #:nodoc:
        no_groups      = step_matches.select {|step_match| step_match.args.length == 0}
        max_arg_length = step_matches.map {|step_match| step_match.args.length }.max
        top_groups     = step_matches.select {|step_match| step_match.args.length == max_arg_length }

        if no_groups.any?
          longest_regexp_length = no_groups.map {|step_match| step_match.text_length }.max
          no_groups.select {|step_match| step_match.text_length == longest_regexp_length }
        elsif top_groups.any?
          shortest_capture_length = top_groups.map {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } }.min
          top_groups.select {|step_match| step_match.args.inject(0) {|sum, c| sum + c.to_s.length } == shortest_capture_length }
        else
          top_groups
        end
      end
    
      def load_file(file)
        if programming_language = programming_language_for(file)
          log.debug("  * #{file}\n")
          programming_language.load_code_file(file)
        else
          log.debug("  * #{file} [NOT SUPPORTED]\n")
        end
      end
    
      def log
        Cucumber.logger
      end
    
      def programming_language_for(step_def_file) #:nodoc:
        if ext = File.extname(step_def_file)[1..-1]
          return nil if @unsupported_programming_languages.index(ext)
          begin
            load_programming_language!(ext)
          rescue LoadError => e
            log.debug("Failed to load '#{ext}' programming language for file #{step_def_file}: #{e.message}\n")
            @unsupported_programming_languages << ext
            nil
          end
        else
          nil
        end
      end
    
    end
  end
end