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
