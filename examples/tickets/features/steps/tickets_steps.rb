require 'spec'

def run_step(name)
  _, args, proc = $executor.instance_variable_get(:@step_mother).regexp_args_proc(name)
  world = $executor.instance_variable_get(:@world)
  proc.call_in(world, *args)
end

Given "be_empty" do
  [1,2].should_not be_empty
end

Given "calling step is called" do
  run_step "nested step"
end

Given "nested step" do
  @magic = 'mushroom'
end

Then "nested step should be executed" do
  @magic.should == 'mushroom'
end
