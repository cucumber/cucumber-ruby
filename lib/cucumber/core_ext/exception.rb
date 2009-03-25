# Exception extension that tweaks Exception backtraces:
#
# * The line of the failing .feature line is appended to the backtrace
# * The line that calls #cucumber_instance_exec is replaced with the StepDefinition's regexp
# * Non intersting lines are stripped out
#
# The result is that backtraces look like this:
#
#   features/step_definitions/the_step_definition.rb:in `/some step/'
#   features/the_feature_file.feature:41:in `Given some step'
#
# or if the exception is raised in the tested code:
#
#   lib/myapp/some_file.rb:in `/some_method/'
#   lib/myapp/some_other_file.rb:in `/some_other_method/'
#   features/step_definitions/the_step_definition.rb:in `/some step/'
#   features/the_feature_file.feature:41:in `Given some step'
#
# All backtrace munging can be turned off with the <tt>--backtrace</tt> switch
#
class Exception
  CUCUMBER_FILTER_PATTERNS = [
    /vendor\/rails|lib\/cucumber|bin\/cucumber:|lib\/rspec|gems\//
  ]

  INSTANCE_EXEC_OFFSET = (Cucumber::RUBY_1_9 || Cucumber::JRUBY) ? -3 : -4

  def self.cucumber_full_backtrace=(v)
    @@cucumber_full_backtrace = v
  end
  self.cucumber_full_backtrace = false

  # Strips the backtrace from +line+ and down
  def self.cucumber_strip_backtrace!(backtrace, instance_exec_invocation_line, pseudo_method)
    return if @@cucumber_full_backtrace

    instance_exec_pos = backtrace.index(instance_exec_invocation_line)
    if instance_exec_pos
      replacement_line = instance_exec_pos + INSTANCE_EXEC_OFFSET
      backtrace[replacement_line].gsub!(/`.*'/, "`#{pseudo_method}'") if pseudo_method
      backtrace[replacement_line+1..-1] = nil

      backtrace.compact!
    else
      # This happens with rails, because they screw up the backtrace
      # before we get here (injecting erb stacktrace and such)
    end

    backtrace.reject! do |line|
      CUCUMBER_FILTER_PATTERNS.detect{|p| line =~ p}
    end
  end
end