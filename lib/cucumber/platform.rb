# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'
require 'yaml'

module Cucumber
  # TODO: Move these constants and the file to Language. Update wiki
  LANGUAGE_FILE = File.expand_path(File.dirname(__FILE__) + '/languages.yml')
  LANGUAGES     = YAML.load_file(LANGUAGE_FILE)
  BINARY        = File.expand_path(File.dirname(__FILE__) + '/../../bin/cucumber')
  LIBDIR        = File.expand_path(File.dirname(__FILE__) + '/../../lib')
  JRUBY         = defined?(JRUBY_VERSION)
  IRONRUBY      = Config::CONFIG['sitedir'] =~ /IronRuby/
  WINDOWS       = Config::CONFIG['host_os'] =~ /mswin|mingw/
  WINDOWS_MRI   = WINDOWS && !JRUBY && !IRONRUBY
  RAILS         = defined?(Rails)
  RUBY_BINARY   = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
  RUBY_1_9      = RUBY_VERSION =~ /^1\.9/
  
  def self.file_mode(m)
    RUBY_1_9 ? "#{m}:UTF-8" : m
  end
end