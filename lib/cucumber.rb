$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cucumber/platform'
require 'cucumber/parser'
require 'cucumber/version'
require 'cucumber/step_mother'
require 'cucumber/cli/main'
require 'cucumber/broadcaster'
require 'cucumber/core_ext/exception'

module Cucumber
  KEYWORD_KEYS = %w{name native encoding feature background scenario scenario_outline examples given when then but}
  
  class << self
    # The currently active language
    attr_reader :lang
    
    def load_language(lang) #:nodoc:
      return if @lang
      @lang = lang
      alias_step_definitions(lang)
      Parser.load_parser(keyword_hash)
    end

    def language_incomplete?(lang=@lang)
      KEYWORD_KEYS.detect{|key| keyword_hash(lang)[key].nil?}
    end

    # File mode that accounts for Ruby platform and current language
    def file_mode(m)
      Cucumber::RUBY_1_9 ? "#{m}:#{keyword_hash['encoding']}" : m
    end

    # Returns a Hash of the currently active
    # language, or for a specific language if +lang+ is
    # specified.
    def keyword_hash(lang=@lang)
      LANGUAGES[lang]
    end

    def scenario_keyword
      keyword_hash['scenario'].split('|')[0] + ':'
    end
    
    def alias_step_definitions(lang) #:nodoc:
      keywords = %w{given when then and but}.map{|keyword| keyword_hash(lang)[keyword].split('|')}
      alias_steps(keywords.flatten)
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

  # Make sure we always have English aliases
  alias_step_definitions('en')
end