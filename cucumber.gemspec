(in /Users/aslakhellesoy/scm/radiant_ba/vendor/plugins/cucumber)
Gem::Specification.new do |s|
  s.name = %q{cucumber}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aslak Helles\303\270y"]
  s.date = %q{2008-08-04}
  s.default_executable = %q{cucumber}
  s.description = %q{Executable user stories}
  s.email = ["aslak.hellesoy@gmail.com"]
  s.executables = ["cucumber"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "website/index.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/cucumber", "config/hoe.rb", "config/requirements.rb", "examples/Rakefile", "examples/java/README.textile", "examples/java/build.sh", "examples/java/hello.story", "examples/java/hello_steps.rb", "examples/java/src/cucumber/demo/Hello.java", "examples/java/tree.story", "examples/java/tree_steps.rb", "examples/pure_ruby/addition.rb", "examples/pure_ruby/steps/addition_steps.rb", "examples/simple/addition.story", "examples/simple/division.story", "examples/simple/steps/addition_steps.rb", "examples/simple_norwegian/steg/matte_steg.rb.rb", "examples/simple_norwegian/summering.story", "examples/web/run_stories.story", "examples/web/steps/stories_steps.rb", "gem_tasks/deployment.rake", "gem_tasks/environment.rake", "gem_tasks/fix_cr_lf.rake", "gem_tasks/rspec.rake", "gem_tasks/treetop.rake", "gem_tasks/website.rake", "lib/cucumber.rb", "lib/cucumber/cli.rb", "lib/cucumber/core_ext/proc.rb", "lib/cucumber/core_ext/string.rb", "lib/cucumber/executor.rb", "lib/cucumber/formatters.rb", "lib/cucumber/formatters/ansicolor.rb", "lib/cucumber/formatters/html_formatter.rb", "lib/cucumber/formatters/pretty_formatter.rb", "lib/cucumber/formatters/progress_formatter.rb", "lib/cucumber/parser/languages.yml", "lib/cucumber/parser/nodes.rb", "lib/cucumber/parser/story_parser.rb", "lib/cucumber/parser/story_parser.treetop.erb", "lib/cucumber/parser/story_parser_en.rb", "lib/cucumber/parser/story_parser_fr.rb", "lib/cucumber/parser/story_parser_no.rb", "lib/cucumber/parser/story_parser_pt.rb", "lib/cucumber/parser/top_down_visitor.rb", "lib/cucumber/rails/world.rb", "lib/cucumber/rake/task.rb", "lib/cucumber/ruby_tree.rb", "lib/cucumber/ruby_tree/nodes.rb", "lib/cucumber/step_methods.rb", "lib/cucumber/step_mother.rb", "lib/cucumber/tree.rb", "lib/cucumber/version.rb", "script/console", "script/console.cmd", "script/destroy", "script/destroy.cmd", "script/generate", "script/generate.cmd", "script/txt2html", "script/txt2html.cmd", "setup.rb", "spec/cucumber/core_ext/string_spec.rb", "spec/cucumber/executor_spec.rb", "spec/cucumber/formatters/ansicolor_spec.rb", "spec/cucumber/formatters/html_formatter_spec.rb", "spec/cucumber/formatters/stories.html", "spec/cucumber/sell_cucumbers.story", "spec/spec.opts", "spec/spec_helper.rb", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{http://cucumber.rubyforge.org}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cucumber}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Executable user stories}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 1.0.3"])
      s.add_runtime_dependency(%q<treetop>, [">= 1.2.4"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 1.0.3"])
      s.add_dependency(%q<treetop>, [">= 1.2.4"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 1.0.3"])
    s.add_dependency(%q<treetop>, [">= 1.2.4"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
