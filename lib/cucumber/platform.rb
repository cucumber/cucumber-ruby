# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

module Cucumber
  LANGUAGE_FILE = File.expand_path(File.dirname(__FILE__) + '/languages.yml')
  BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/cucumber')
  JRUBY         = defined?(JRUBY_VERSION)
  IRONRUBY      = Config::CONFIG['sitedir'] =~ /IronRuby/
  WINDOWS       = Config::CONFIG['host_os'] =~ /mswin|mingw/
  WINDOWS_MRI   = WINDOWS && !JRUBY && !IRONRUBY
  RAILS         = defined?(Rails)
  RUBY_BINARY   = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  RUBY_1_9      = RUBY_VERSION =~ /^1\.9/

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