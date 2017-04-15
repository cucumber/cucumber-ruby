class CustomWorld
end

World do
  CustomWorld.new
end

Around do |scenario, block|
  $around_ran = true
  $world_class = self.class
  puts "I am a #{self.class}"
  block.call
  $around_ran = false
end