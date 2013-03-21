require 'spec_helper'
require 'open3'
require 'cucumber/rake/task'
require 'rake'

module Cucumber
  module Rake

    describe Task::ForkedCucumberRunner do

      let(:libs) { ['lib'] }
      let(:binary) { Cucumber::BINARY }
      let(:cucumber_opts) { ['--cuke-option'] }
      let(:feature_files) { ['./some.feature'] }

      context "when running with bundler" do

        let(:bundler) { true }

        subject { Task::ForkedCucumberRunner.new(
            libs, binary, cucumber_opts, bundler, feature_files) }

        it "does use bundler if bundler is set to true" do
          subject.use_bundler.should be_true
        end

        it "uses bundle exec to find cucumber and libraries" do
          subject.cmd.should == [Cucumber::RUBY_BINARY,
                                 '-S',
                                 'bundle',
                                 'exec',
                                 'cucumber',
                                 '--cuke-option'] + feature_files
        end

      end

      context "when running without bundler" do

        let(:bundler) { false }

        subject { Task::ForkedCucumberRunner.new(
            libs, binary, cucumber_opts, bundler, feature_files) }

        it "does not use bundler if bundler is set to false" do
          subject.use_bundler.should be_false
        end

        it "uses well known cucumber location and specified libraries" do
          subject.cmd.should == [Cucumber::RUBY_BINARY,
                                 "-I",
                                 "\"lib\"",
                                 "\"#{Cucumber::BINARY }\"",
                                 "--cuke-option"] + feature_files
        end

      end

      describe "cucumber's rake task" do

        let(:rake_cmd) { "rake --rakefile fixtures/self_test/Rakefile" }

        context "when cucumber failed" do

          it "should return non-zero exit status code and report should not contains rake's backtrace" do
            Open3.popen2e("#{rake_cmd} fail") do |stdin, stdout_err, wait_thr|
              wait_thr.value.success?.should be_false
              stdout_err.read.should_not include("rake aborted!\nCommand failed with status (#{wait_thr.value.exitstatus}):")
            end
          end

        end

        context "when cucumber succeed" do

          it "should return zero exit status code" do
            Open3.popen2e("#{rake_cmd} pass") do |stdin, stdout_err, wait_thr|
              wait_thr.value.success?.should be_true
            end
          end

        end

      end

    end

  end
end
