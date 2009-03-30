require 'cucumber/platform'

module Cucumber
  class ArityMismatchError < StandardError
  end
end

class Object
  def cucumber_instance_exec(check_arity, pseudo_method, *args, &block)
    cucumber_run_with_backtrace_filtering(pseudo_method) do
      if check_arity && !cucumber_compatible_arity?(args, block)
        instance_exec do
          s1 = cucumber_arity(block) == 1 ? "" : "s"
          s2 = args.length == 1 ? "" : "s"
          raise Cucumber::ArityMismatchError.new(
            "Your block takes #{cucumber_arity(block)} argument#{s1}, but the Regexp matched #{args.length} argument#{s2}."
          )
        end
      else
        instance_exec(*args, &block)
      end
    end
  end
  
  def cucumber_arity(block)
    a = block.arity
    Cucumber::RUBY_1_9 ? a : (a == -1 ? 0 : a)
  end
  
  def cucumber_compatible_arity?(args, block)
    a = cucumber_arity(block)
    return true if (a == -1) && Cucumber::RUBY_1_9
    a == args.length
  end
  
  def cucumber_run_with_backtrace_filtering(pseudo_method)
    begin
      yield
    rescue Exception => e
      instance_exec_invocation_line = "#{__FILE__}:#{__LINE__ - 2}:in `cucumber_run_with_backtrace_filtering'"
      Exception.cucumber_strip_backtrace!((e.backtrace || []), instance_exec_invocation_line, pseudo_method)
      raise e
    end
  end
  
  unless defined? instance_exec # 1.9
    # http://eigenclass.org/hiki/bounded+space+instance_exec
    module InstanceExecHelper; end
    include InstanceExecHelper
    def instance_exec(*args, &block)
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(mname="__instance_exec#{n}")
        InstanceExecHelper.module_eval{ define_method(mname, &block) }
      ensure
        Thread.critical = old_critical
      end
      begin
        ret = send(mname, *args)
      ensure
        InstanceExecHelper.module_eval{ remove_method(mname) } rescue nil
      end
      ret
    end
  end
end
