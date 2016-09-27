# frozen_string_literal: true
task :ruby_env do
  RUBY_APP ||= RUBY_PLATFORM =~ /java/ ? 'jruby' : 'ruby'
end
