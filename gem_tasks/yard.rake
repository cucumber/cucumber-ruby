begin
  require 'yard'
  
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb']
  end
rescue LoadError => ignore
end