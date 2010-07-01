require 'webrat'
require 'rspec'

Webrat.configure do |config|
  config.mode = :mechanize
end

class WebratWorld
  include RSpec::Matchers
  include Webrat::Methods
  include Webrat::Matchers
end

World do
  WebratWorld.new
end
 