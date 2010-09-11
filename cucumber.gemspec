# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cucumber/platform"

Gem::Specification.new do |s|
  s.name        = 'cucumber'
  s.version     = Cucumber::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Aslak Hellesøy"]
  s.description = 'Behaviour Driven Development with elegance and joy'
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = "http://cukes.info"
  s.summary     = "cucumber-#{Cucumber::VERSION}"
  s.description = 'Behaviour Driven Development with elegance and joy'

  s.rubygems_version   = "1.3.7"
  s.default_executable = "cucumber"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "History.txt"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"

  s.post_install_message = %q{
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)

                     (::)   U P G R A D I N G    (::)

Thank you for installing cucumber-#{Cucumber::VERSION}.
Please be sure to read http://wiki.github.com/aslakhellesoy/cucumber/upgrading
for important information about this release. Happy cuking!

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::)

}
end
