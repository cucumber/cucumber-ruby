require 'rubygems'
require 'tcl'

Before do
  file_name = File.dirname(__FILE__) + '/../../src/fib.tcl'
  @fib = Tcl::Interp.load_from_file(file_name)
end
