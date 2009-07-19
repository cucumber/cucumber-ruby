module Cucumber
  module Parser
    module I18n
      class Language
        KEYWORD_KEYS = %w{name native encoding feature background scenario scenario_outline examples given when then but}

        class << self
          LANGUAGES = Hash.new{|h,k| h[k] = Language.new(k)}
          
          def [](key)
            LANGUAGES[key]
          end

          def alias_step_definitions(keywords) #:nodoc:
            all_keywords = %w{given when then and but}.map{|keyword| keywords[keyword].split('|')}.flatten
            alias_steps(all_keywords)
          end

          # Sets up additional method aliases for Given, When and Then.
          # This does *not* affect how feature files are parsed. If you
          # want to create aliases in the parser, you have to do this in
          # languages.yml. For example:
          #
          # and: And|With
          def alias_steps(keywords)
            keywords.each do |adverb|
              StepMother.alias_adverb(adverb)
              World.alias_adverb(adverb)
            end
          end
        end

        alias_step_definitions(Cucumber::LANGUAGES['en'])

        def initialize(lang)
          @keywords = Cucumber::LANGUAGES[lang]
          raise "Language not supported: #{lang.inspect}" if @keywords.nil?
          @keywords['grammar_name'] = @keywords['name'].gsub(/\s/, '')
        end
        
        def parser
          return @parser if @parser
          i18n_tt = File.expand_path(File.dirname(__FILE__) + '/../i18n.tt')
          template = File.open(i18n_tt, Cucumber.file_mode('r')).read
          erb = ERB.new(template)
          grammar = erb.result(binding)
          Treetop.load_from_string(grammar)
          self.class.alias_step_definitions(@keywords)
          @parser = Parser::I18n.const_get("#{@keywords['grammar_name']}Parser").new
        end

        def parse(source, path, filter)
          feature = parser.parse_or_fail(source, path, filter)
          feature.language = self if feature
          feature
        end

        def keywords(key, raw=false)
          return @keywords[key] if raw
          return nil unless @keywords[key]
          values = @keywords[key].split('|')
          values.map{|value| "'#{value}'"}.join(" / ")
        end

        def incomplete?
          KEYWORD_KEYS.detect{|key| @keywords[key].nil?}
        end

        def scenario_keyword
          @keywords['scenario'].split('|')[0] + ':'
        end

        def but_keywords
          @keywords['but'].split('|')
        end

        def and_keywords
          @keywords['and'].split('|')
        end
      end
    end
  end
end
