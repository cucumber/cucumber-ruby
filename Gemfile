source "http://rubygems.org"
gemspec

# Use source from sibling folders (if available) instead of gems
%w[gherkin].each do |g|
  if File.directory?(File.dirname(__FILE__) + "/../#{g}")
    @dependencies.reject!{|dep| dep.name == g}
    gem g, :path => "../#{g}"
  end
end
