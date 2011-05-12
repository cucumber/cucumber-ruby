require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'cucumber/rake/task'
require 'rake'

module Cucumber
  module Rake

    describe Task do

      context "when running rcov" do
        let(:task) { Task.new { |t| t.rcov = true } }

        it "correctly builds an RCovCucumberRunner" do
          runner = task.runner
          runner.should be_a(Task::RCovCucumberRunner)
        end

      end
    end

  end
end