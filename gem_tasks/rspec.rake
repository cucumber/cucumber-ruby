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

  desc "Run the Cucumber specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "specs/spec.opts"]
    t.spec_files = FileList['specs/**/*_spec.rb']
    t.rcov = ENV['RCOV']
    t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
    t.verbose = true
  end
end