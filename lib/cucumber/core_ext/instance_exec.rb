require 'cucumber/platform'

module Cucumber
  class ArityMismatchError < StandardError
  end
end

class Object
  def cucumber_instance_exec(check_arity, pseudo_method, *args, &block)
    arity = block.arity
    arity = 0 if arity == -1
    cucumber_run_with_backtrace_filtering(pseudo_method) do
      if check_arity && args.length != arity
        instance_exec do
          raise Cucumber::ArityMismatchError.new("expected #{arity} block argument(s), got #{args.length}")
        end
      else
        instance_exec(*args, &block)
      end
    end
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
