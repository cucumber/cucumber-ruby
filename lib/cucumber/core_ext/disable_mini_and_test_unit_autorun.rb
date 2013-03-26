begin
  require 'test/unit'

  if defined?(Test::Unit::AutoRunner.need_auto_run?)
    # For test-unit gem >= 2.4.9
    Test::Unit::AutoRunner.need_auto_run = false
  elsif defined?(Test::Unit.run?)
    # For test-unit gem < 2.4.9
    Test::Unit.run = true
  elsif defined?(Test::Unit::Runner)
    # For test/unit bundled in Ruby >= 1.9.3
    Test::Unit::Runner.module_eval("@@stop_auto_run = true")
  end
rescue LoadError => ignore
end
