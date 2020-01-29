When('a step passes') do
  true
end

When('a step throws an exception') do
  raise StandardError, 'An exception is raised here'
end
