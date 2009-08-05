ENV['NODOT'] = 'true' # We don't want class diagrams in RDoc
require 'config/requirements'
require 'config/hoe' # setup Hoe + all gem configuration

Dir['gem_tasks/**/*.rake'].each { |rake| load rake }

# Hoe gives us :default => :test, but we don't have Test::Unit tests.
Rake::Task[:default].clear_prerequisites rescue nil # For some super weird reason this fails for some...
task :default => [:spec, :cucumber]
