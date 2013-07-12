require 'spec_helper'
require 'cucumber/formatter/spec_helper'

require 'cucumber/formatter/junit'
require 'nokogiri'

module Cucumber::Formatter
  describe Junit do
    extend SpecHelperDsl
    include SpecHelper

    class TestDoubleJunitFormatter < Junit
      attr_reader :written_files

      def write_file(feature_filename, data)
        @written_files ||= {}
        @written_files[feature_filename] = data
      end
    end

    before(:each) do
      File.stub(:directory?).and_return(true)
      @formatter = TestDoubleJunitFormatter.new(step_mother, '', {})
    end

    describe "should be able to strip control chars from cdata" do
      before(:each) do
        run_defined_feature
        @doc = Nokogiri.XML(@formatter.written_files.values.first)
      end
      define_feature "
          Feature: One passing scenario, one failing scenario

            Scenario: Passing
              Given a passing ctrl scenario
        "
      class Junit
        def before_step(step)
          if step.name.match("a passing ctrl scenario")
            Interceptor::Pipe.unwrap! :stdout
            @fake_io = $stdout = StringIO.new
            $stdout.sync = true
            @interceptedout = Interceptor::Pipe.wrap(:stdout)
          end
        end

        def after_step(step)
          if step.name.match("a passing ctrl scenario")
            @interceptedout.write("boo\b\cx\e\a\f boo ")
            $stdout = STDOUT
            @fake_io.close
          end
        end
      end
      
      it { @doc.xpath('//testsuite/system-out').first.content.should match(/\s+boo boo\s+/) }
    end

    describe "a feature with no name" do
      define_feature <<-FEATURE
        Feature:
          Scenario: Passing
            Given a passing scenario
      FEATURE

      it "should raise an exception" do
        lambda { run_defined_feature }.should raise_error(Junit::UnNamedFeatureError)
      end
    end

    describe "given a single feature" do
      before(:each) do
        run_defined_feature
        @doc = Nokogiri.XML(@formatter.written_files.values.first)
      end

      describe "with a single scenario" do
        define_feature <<-FEATURE
          Feature: One passing scenario, one failing scenario

            Scenario: Passing
              Given a passing scenario
        FEATURE

        it { @doc.to_s.should =~ /One passing scenario, one failing scenario/ }

        it 'should have a root system-out node' do
          @doc.xpath('//testsuite/system-out').size.should == 1
        end

        it 'should have a root system-err node' do
          @doc.xpath('//testsuite/system-err').size.should == 1
        end

        it 'should have a system-out node under <testcase/>' do
          @doc.xpath('//testcase/system-out').size.should == 1
        end

        it 'should have a system-err node under <testcase/>' do
          @doc.xpath('//testcase/system-err').size.should == 1
        end
      end

      describe "with a scenario in a subdirectory" do
        define_feature %{
          Feature: One passing scenario, one failing scenario

            Scenario: Passing
              Given a passing scenario
        }, File.join('features', 'some', 'path', 'spec.feature')

        it 'writes the filename including the subdirectory' do
          @formatter.written_files.keys.first.should == File.join('', 'TEST-features-some-path-spec.xml')
        end
      end

      describe "with a scenario outline table" do
        define_steps do
          Given(/.*/) {  }
        end

        define_feature <<-FEATURE
          Feature: Eat things when hungry

            Scenario Outline: Eat things
              Given <Things>
              And stuff:
                | foo |
                | bar |

            Examples: Good
              | Things   |
              | Cucumber |
              | Whisky   |
            Examples: Evil
              | Things   |
              | Big Mac  |
        FEATURE

        it { @doc.to_s.should =~ /Eat things when hungry/ }
        it { @doc.to_s.should =~ /Cucumber/ }
        it { @doc.to_s.should =~ /Whisky/ }
        it { @doc.to_s.should =~ /Big Mac/ }
        it { @doc.to_s.should_not =~ /Things/ }
        it { @doc.to_s.should_not =~ /Good|Evil/ }
        it { @doc.to_s.should_not =~ /type="skipped"/}
      end

      describe "scenario with skipped test in junit report" do
        define_feature <<-FEATURE
          Feature: junit report with skipped test

            Scenario Outline: skip a test and junit report of the same
              Given a <skip> scenario

            Examples:
              | skip   |
              | undefined |
              | undefined  |
        FEATURE

        it { @doc.to_s.should =~ /skipped="2"/}
      end

      describe "with a regular data table scenario" do
        define_steps do
          Given(/the following items on a shortlist/) { |table| }
          When(/I go.*/) {  }
          Then(/I should have visited at least/) { |table| }
        end

        define_feature <<-FEATURE
          Feature: Shortlist

            Scenario: Procure items
              Given the following items on a shortlist:
                | item    |
                | milk    |
                | cookies |
              When I get some..
              Then I'll eat 'em

        FEATURE
        # these type of tables shouldn't crash (or generate test cases)
        it { @doc.to_s.should_not =~ /milk/ }
        it { @doc.to_s.should_not =~ /cookies/ }
      end
    end
  end
end
