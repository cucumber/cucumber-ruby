require 'cucumber/rake/task'
require 'cucumber/platform'

class Cucumber::Rake::Task
  def set_profile_for_current_ruby
    self.profile = if(Cucumber::JRUBY)
      Cucumber::WINDOWS ? 'jruby_win' : 'jruby'
    elsif(Cucumber::WINDOWS_MRI)
      'windows_mri'
    elsif(Cucumber::RUBY_1_9)
      'ruby_1_9'
    end
  end
end

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = false
  t.set_profile_for_current_ruby
end

Cucumber::Rake::Task.new(:legacy_features) do |t|
  t.fork = false
  t.cucumber_opts = %w{legacy_features}
  t.set_profile_for_current_ruby
  t.rcov = ENV['RCOV']
end

task :cucumber => [:features, :legacy_features]
