require 'cucumber/rake/task'
require 'cucumber/platform'

class Cucumber::Rake::Task
  def set_profile_for_current_ruby
    self.profile = if Cucumber::JRUBY
      Cucumber::WINDOWS ? 'jruby_win' : 'jruby'
    elsif Cucumber::WINDOWS_MRI
      'windows_mri'
    elsif Cucumber::RUBY_1_8_7
      'ruby_1_8_7'
    elsif Cucumber::RUBY_1_9
      'ruby_1_9'
    elsif Cucumber::RUBY_2_0
      'ruby_2_0'
    end
  end
end

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = true
  t.set_profile_for_current_ruby
end

Cucumber::Rake::Task.new(:legacy_features) do |t|
  t.fork = true
  t.profile = :legacy
end

task :cucumber => [:features, :legacy_features]
