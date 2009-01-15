# http://eigenclass.org/hiki/bounded+space+instance_exec
module Cucumber
  class ArityMismatchError < StandardError
  end
end

class Object
  def cucumber_instance_exec(*args, &block)
    arity = block.arity
    arity = 0 if arity == -1
    if args.length != block.arity
      raise Cucumber::ArityMismatchError.new("expected #{arity} block argument(s), got #{args.length}")
    else
      instance_exec(*args, &block)
    end
  end
  
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
