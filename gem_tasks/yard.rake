require 'yard'
require 'yard/rake/yardoc_task'
require File.expand_path(File.dirname(__FILE__) + '/../lib/cucumber/platform')

DOC_DIR      = File.expand_path(File.dirname(__FILE__) + '/../doc')
SITE_DIR     = File.expand_path(File.dirname(__FILE__) + '/../../cucumber.github.com')
API_DIR      = File.join(SITE_DIR, 'api', 'cucumber', 'ruby', 'yardoc')
TEMPLATE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'yard'))
YARD::Templates::Engine.register_template_path(TEMPLATE_DIR)

namespace :api do
  YARD::Rake::YardocTask.new(:yard) do |yard|
    yard.options = ["--out", DOC_DIR]
  end

  task :sync_with_git do
    unless File.directory?(SITE_DIR)
      raise "You need to git clone git@github.com:cucumber/cucumber.github.com.git #{SITE_DIR}"
    end
    Dir.chdir(SITE_DIR) do
      sh 'git pull -u'
    end
  end

  task :copy_to_website do
    rm_rf API_DIR
    cp_r DOC_DIR, API_DIR
  end

  task :release do
    Dir.chdir(SITE_DIR) do
      sh 'git add .'
      sh "git commit -m 'Update API docs for Cucumber-Ruby v#{Cucumber::VERSION}'"
      sh 'git push'
    end
  end

  desc "Generate YARD docs for Cucumber's API"
  task :doc => [:yard, :sync_with_git, :copy_to_website, :release]
end
