$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cucumber/platform'
require 'rubygems'
require 'cucumber/parser'
require 'cucumber/version'
require 'cucumber/step_mother'
require 'cucumber/cli'
require 'cucumber/broadcaster'
require 'cucumber/core_ext/exception'

module Cucumber
  class << self
    # Returns the keyword Hash for the current language
    def keywords
      LANGUAGES['en'].merge(LANGUAGES[@lang])
    end
    
    def load_language(lang) #:nodoc:
      return if @lang
      @lang = lang
      alias_step_definitions(@lang)
      Parser.load_parser(keywords)
    end
    
    def alias_step_definitions(lang) #:nodoc:
      keyword_hash = LANGUAGES[lang]
      keywords = %w{given when then and but}.map{|keyword| keyword_hash[keyword]}
      alias_steps(keywords)
    end
    
    # Sets up additional aliases for Given, When and Then.
    # Try adding the following to your <tt>support/env.rb</tt>:
    #
    #   # Given When Then in Norwegian
    #   Cucumber.alias_steps %w{Gitt Naar Saa}
    #
    def alias_steps(keywords)
      keywords.each do |adverb|
        StepMom.class_eval do
          alias_method adverb, :register_step_definition
        end

        StepMom::WorldMethods.class_eval do
          alias_method adverb, :__cucumber_invoke
        end
      end
    end
  end  

  # Make sure we always have English aliases
  alias_step_definitions('en')
end