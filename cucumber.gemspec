(in /Users/aslakhellesoy/scm/radiant_ba/vendor/plugins/cucumber)
Gem::Specification.new do |s|
  s.name = %q{cucumber}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aslak Helles\303\270y"]
  s.date = %q{2008-08-06}
  s.default_executable = %q{cucumber}
  s.description = %q{Executable Feature scenarios}
  s.email = ["aslak.hellesoy@gmail.com"]
  s.executables = ["cucumber"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "Manifest.txt", "TODO.txt", "website/index.txt"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.textile", "Rakefile", "TODO.txt", "bin/cucumber", "config/hoe.rb", "config/requirements.rb", "examples/java/README.textile", "examples/java/Rakefile", "examples/java/features/hello.feature", "examples/java/features/steps/hello_steps.rb", "examples/java/features/steps/tree_steps.rb", "examples/java/features/tree.feature", "examples/java/src/cucumber/demo/Hello.java", "examples/pure_ruby/Rakefile", "examples/pure_ruby/features/addition.rb", "examples/pure_ruby/features/steps/addition_steps.rb", "examples/simple/Rakefile", "examples/simple/features/addition.feature", "examples/simple/features/division.feature", "examples/simple/features/steps/addition_steps.rb", "examples/simple_norwegian/Rakefile", "examples/simple_norwegian/features/steps/matte_steg.rb.rb", "examples/simple_norwegian/features/summering.feature", "examples/web/Rakefile", "examples/web/features/search.feature", "examples/web/features/steps/stories_steps.rb", "gem_tasks/deployment.rake", "gem_tasks/environment.rake", "gem_tasks/fix_cr_lf.rake", "gem_tasks/rspec.rake", "gem_tasks/treetop.rake", "gem_tasks/website.rake", "lib/cucumber.rb", "lib/cucumber/cli.rb", "lib/cucumber/core_ext/proc.rb", "lib/cucumber/core_ext/string.rb", "lib/cucumber/executor.rb", "lib/cucumber/formatters.rb", "lib/cucumber/formatters/ansicolor.rb", "lib/cucumber/formatters/html_formatter.rb", "lib/cucumber/formatters/pretty_formatter.rb", "lib/cucumber/formatters/progress_formatter.rb", "lib/cucumber/languages.yml", "lib/cucumber/rails/world.rb", "lib/cucumber/rake/task.rb", "lib/cucumber/step_methods.rb", "lib/cucumber/step_mother.rb", "lib/cucumber/tree.rb", "lib/cucumber/tree/feature.rb", "lib/cucumber/tree/features.rb", "lib/cucumber/tree/scenario.rb", "lib/cucumber/tree/step.rb", "lib/cucumber/tree/table.rb", "lib/cucumber/tree/top_down_visitor.rb", "lib/cucumber/treetop_parser/feature.treetop.erb", "lib/cucumber/treetop_parser/feature_en.rb", "lib/cucumber/treetop_parser/feature_fr.rb", "lib/cucumber/treetop_parser/feature_no.rb", "lib/cucumber/treetop_parser/feature_parser.rb", "lib/cucumber/treetop_parser/feature_pt.rb", "lib/cucumber/version.rb", "script/console", "script/console.cmd", "script/destroy", "script/destroy.cmd", "script/generate", "script/generate.cmd", "script/txt2html", "script/txt2html.cmd", "setup.rb", "spec/cucumber/core_ext/string_spec.rb", "spec/cucumber/executor_spec.rb", "spec/cucumber/formatters/ansicolor_spec.rb", "spec/cucumber/formatters/features.html", "spec/cucumber/formatters/html_formatter_spec.rb", "spec/cucumber/sell_cucumbers.feature", "spec/spec.opts", "spec/spec_helper.rb", "website/index.html", "website/index.txt", "website/javascripts/rounded_corners_lite.inc.js", "website/stylesheets/screen.css", "website/template.html.erb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/aslakhellesoy/cucumber}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{cucumber}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Executable Feature scenarios}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 1.0.3"])
      s.add_runtime_dependency(%q<treetop>, [">= 1.2.4"])
      s.add_runtime_dependency(%q<rspec>, [">= 1.1.4"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 1.0.3"])
      s.add_dependency(%q<treetop>, [">= 1.2.4"])
      s.add_dependency(%q<rspec>, [">= 1.1.4"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 1.0.3"])
    s.add_dependency(%q<treetop>, [">= 1.2.4"])
    s.add_dependency(%q<rspec>, [">= 1.1.4"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
