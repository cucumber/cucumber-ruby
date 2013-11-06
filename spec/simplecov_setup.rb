if ENV['SIMPLECOV']
  begin
    require 'simplecov'
    SimpleCov.root(File.expand_path(File.dirname(__FILE__) + '/..'))
    SimpleCov.start do
      add_filter 'iso-8859-1_steps.rb'
      add_filter '.-ruby-core/'
      add_filter '/spec/'
      add_filter '/features/'
    end
  rescue LoadError
    warn("Unable to load simplecov")
  end
end

