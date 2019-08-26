begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end

require 'cucumber/formatter/unicode'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'calculadora'
