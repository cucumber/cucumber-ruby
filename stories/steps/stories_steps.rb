Given 'I have some failing steps' do |n|
end

When 'I run a story' do |n|
end

Then 'the execution should fail' do |n|
  Foo.new.doit
end

class Foo
  def doit
    domore
  end
  
  def domore
    evenmore
  end
  
  def evenmore
    raise "I give up"
  end
end