require 'cucumber/platform'

module Cucumber
  # Raised if the number of a StepDefinition's Regexp match groups
  # is different from the number of Proc arguments.
  class ArityMismatchError < StandardError
  end
end

class Object #:nodoc:
  # TODO: Move most of this stuff out to an InstanceExecutor class.
  def cucumber_instance_exec(check_arity, pseudo_method, *args, &block)
    cucumber_run_with_backtrace_filtering(pseudo_method) do
      if check_arity && !cucumber_compatible_arity?(args, block)
        instance_exec do
          ari = cucumber_arity(block)
          ari = ari < 0 ? (ari.abs-1).to_s+"+" : ari
          s1 = ari == 1 ? "" : "s"
          s2 = args.length == 1 ? "" : "s"
          raise Cucumber::ArityMismatchError.new(
            "Your block takes #{ari} argument#{s1}, but the Regexp matched #{args.length} argument#{s2}."
          )
        end
      else
        instance_exec(*args, &block)
      end
    end
  end

  private

  def cucumber_arity(block)
    # TODO: inline method
    block.arity
  end

  def cucumber_compatible_arity?(args, block)
    ari = cucumber_arity(block)
    len = args.length
    return true if ari == len or ari < 0 && len >= ari.abs-1
    false
  end

  def cucumber_run_with_backtrace_filtering(pseudo_method)
    begin
      yield
    rescue Exception => e
      instance_exec_invocation_line = "#{__FILE__}:#{__LINE__ - 2}:in `cucumber_run_with_backtrace_filtering'"
      replace_instance_exec_invocation_line!((e.backtrace || []), instance_exec_invocation_line, pseudo_method)
      raise e
    end
  end

  INSTANCE_EXEC_OFFSET = (Cucumber::RUBY_2_0 || Cucumber::RUBY_1_9 || Cucumber::JRUBY) ? -3 : -4

  def replace_instance_exec_invocation_line!(backtrace, instance_exec_invocation_line, pseudo_method)
    return if Cucumber.use_full_backtrace

    instance_exec_pos = backtrace.index(instance_exec_invocation_line)
    if instance_exec_pos
      replacement_line = instance_exec_pos + INSTANCE_EXEC_OFFSET
      backtrace[replacement_line].gsub!(/`.*'/, "`#{pseudo_method}'") if pseudo_method

      depth = backtrace.count { |line| line == instance_exec_invocation_line }
      end_pos = depth > 1 ? instance_exec_pos : -1

      backtrace[replacement_line+1..end_pos] = nil
      backtrace.compact!
    else
      # This happens with rails, because they screw up the backtrace
      # before we get here (injecting erb stacktrace and such)
    end
  end
end
