$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cucumber/platform'
require 'rubygems'
require 'cucumber/parser'
require 'cucumber/version'
require 'cucumber/step_methods'
require 'cucumber/tree'
require 'cucumber/model'
require 'cucumber/executor'
require 'cucumber/step_mother'
require 'cucumber/formatters'
require 'cucumber/treetop_parser/feature_parser'
require 'cucumber/cli'
require 'cucumber/broadcaster'
require 'cucumber/world'
require 'cucumber/core_ext/exception'

module Cucumber
  class << self
    def languages
      LANGUAGES.keys.sort
    end
    
    def keywords
      @keyword_hash
    end
    
    def load_language(lang)
      return if @lang
      @lang = lang
      @keyword_hash = LANGUAGES[@lang]

      keywords = %w{given when then and but}.map{|keyword| @keyword_hash[keyword]}
      alias_steps(keywords)
      Parser.load_parser(@keyword_hash)
    end
    
    # Sets up additional aliases for Given, When and Then.
    # Try adding the following to your <tt>support/env.rb</tt>:
    #
    #   # Given When Then in Norwegian
    #   Cucumber.alias_steps %w{Gitt Når Så}
    #
    def alias_steps(keywords) #:nodoc:
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
end