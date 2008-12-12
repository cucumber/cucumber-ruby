$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'cucumber/platform'
require 'rubygems'
require 'treetop/runtime'
require 'treetop/ruby_extensions'
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
  LANGUAGE_FILE = File.expand_path(File.dirname(__FILE__) + '/cucumber/languages.yml')

  class << self
    attr_reader :language
    
    def load_language(lang)
      @language = config[lang]
    end
    
    def languages
      config.keys.sort
    end
    
    def config
      require 'yaml'
      @config ||= YAML.load_file(LANGUAGE_FILE)
    end
  end  
end