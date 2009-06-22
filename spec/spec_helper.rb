require 'rubygems'
gem 'rspec'
require 'spec'
require 'spec/autorun'

ENV['CUCUMBER_COLORS']=nil
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'cucumber'
$:.unshift(File.dirname(__FILE__))

::Term::ANSIColor.coloring = true

alias running lambda
