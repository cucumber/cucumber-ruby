Dir[File.dirname(__FILE__) + '/events/*.rb'].each do |event_file|
  require event_file
end
