def unable_to_load
  STDERR.puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
    
EOS
  nil
end

def require_spec
  require 'spec/expectations'
rescue LoadError
  require_spec_with_rubygems
end

def require_spec_with_rubygems
  require 'rubygems'
  require 'spec/expectations'
rescue LoadError
  unable_to_load
end

if require_spec
  begin
    require 'spec/rake/spectask'
  rescue LoadError
    unable_to_load
  end

  def undefine_task(*names)
    app = Rake.application
    tasks = app.instance_variable_get('@tasks')
    names.flatten.each { |name| tasks.delete(name) }
  end
  undefine_task('spec') # Hoe 1.2.12 is broken - it defines a spec task that we can't tweak.

  desc "Run the Cucumber specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = ENV['RCOV']
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
    t.verbose = true
  end
end
