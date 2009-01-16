require 'cucumber/platform'

module Cucumber
  class ArityMismatchError < StandardError
  end
end

class Object
  def cucumber_instance_exec(check_arity, pseudo_method, *args, &block)
    arity = block.arity
    arity = 0 if arity == -1
    if check_arity && args.length != arity
      raise Cucumber::ArityMismatchError.new("expected #{arity} block argument(s), got #{args.length}")
    else
      begin
        instance_exec(*args, &block)
      rescue Exception => e
        instance_exec_invocation_line = "#{__FILE__}:#{__LINE__ - 2}:in `cucumber_instance_exec'"
        e.cucumber_strip_backtrace!(instance_exec_invocation_line, pseudo_method)
        raise e
      end
    end
  end
  
  unless Cucumber::RUBY_1_9
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
