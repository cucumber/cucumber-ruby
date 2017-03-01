# frozen_string_literal: true
require 'cucumber/rake/task'
require 'cucumber/platform'

class Cucumber::Rake::Task
  def set_profile_for_current_ruby
    self.profile = if Cucumber::JRUBY
                     Cucumber::WINDOWS ? 'jruby_win' : 'jruby'
                   elsif Cucumber::WINDOWS_MRI
                     'windows_mri'
                   elsif Cucumber::RUBY_1_9
                     'ruby_1_9'
                   elsif Cucumber::RUBY_2_0
                     'ruby_2_0'
                   elsif Cucumber::RUBY_2_1
                     'ruby_2_1'
                   elsif Cucumber::RUBY_2_2
                     'ruby_2_2'
                   elsif Cucumber::RUBY_2_3
                     'ruby_2_3'
                   elsif Cucumber::RUBY_2_4
                     'ruby_2_4'
                   end
  end
end

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = true
  t.set_profile_for_current_ruby
end

desc 'Run Cucumber features'
task :cucumber => :features
