$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'kalkilatris'

Before do
  @kalk = Kalkilatris.new
end

Sipoze('mwen te antre {int} nan kalkilatris la') do |int|
  @kalk.push int
end

Lè('mwen peze {word}') do |op|
  @result = @kalk.send op
end

Lè('sa a rezilta a ta dwe {float} sou ekran an') do |rezilta|
  expect(@result).to eq(rezilta)
end
