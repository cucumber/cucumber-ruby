require File.dirname(__FILE__) + '/../../spec_helper'
require 'yaml'

module Cucumber
module Cli
  describe Configuration do

    def given_cucumber_yml_defined_as(hash_or_string)
      File.stub!(:exist?).and_return(true)
      cucumber_yml = hash_or_string.is_a?(Hash) ? hash_or_string.to_yaml : hash_or_string
      IO.stub!(:read).with('cucumber.yml').and_return(cucumber_yml)
    end

    def given_the_following_files(*files)
      File.stub!(:directory?).and_return(true)
      Dir.stub!(:[]).and_return(files)
    end

    before(:each) do
      Kernel.stub!(:exit).and_return(nil)
    end

    it "should require files in support paths first" do
      given_the_following_files("/features/step_definitions/foo.rb","/features/support/bar.rb")

      config = Configuration.new(StringIO.new)
      config.parse!(%w{--require /features})

      config.files_to_require.should == [
        "/features/support/bar.rb",
        "/features/step_definitions/foo.rb"
      ]
    end

    it "should require env.rb files first" do
      given_the_following_files("/features/support/a_file.rb","/features/support/env.rb")

      config = Configuration.new(StringIO.new)
      config.parse!(%w{--require /features})

      config.files_to_require.should == [
        "/features/support/env.rb",
        "/features/support/a_file.rb"
      ]
    end

    it "should not require env.rb files when --dry-run" do
      given_the_following_files("/features/support/a_file.rb","/features/support/env.rb")

      config = Configuration.new(StringIO.new)
      config.parse!(%w{--require /features --dry-run})

      config.files_to_require.should == [
        "/features/support/a_file.rb"
      ]
    end

    describe "--exclude" do

      it "excludes a ruby file from requiring when the name matches exactly" do
        given_the_following_files("/features/support/a_file.rb","/features/support/env.rb")

        config = Configuration.new(StringIO.new)
        config.parse!(%w{--require /features --exclude a_file.rb})

        config.files_to_require.should == [
          "/features/support/env.rb"
        ]
      end

      it "excludes all ruby files that match the provided patterns from requiring" do
        given_the_following_files("/features/support/foof.rb","/features/support/bar.rb",
                                  "/features/support/food.rb","/features/blah.rb",
                                  "/features/support/fooz.rb")

        config = Configuration.new(StringIO.new)
        config.parse!(%w{--require /features --exclude foo[df] --exclude blah})

        config.files_to_require.should == [
          "/features/support/bar.rb",
          "/features/support/fooz.rb"
        ]
      end
    end

    describe '#drb?' do
      it "indicates whether the --drb flag was passed in or not" do
        config = Configuration.new(StringIO.new)

        config.parse!(%w{features})
        config.drb?.should == false


        config.parse!(%w{features --drb})
        config.drb?.should == true
      end
    end

    context '--drb' do
      it "removes the --drb flag from the args" do
        config = Configuration.new(StringIO.new)

        args = %w{features --drb}
        config.parse!(args)
        args.should == %w{features}
      end

      it "keeps all other flags intact" do
        config = Configuration.new(StringIO.new)

        args = %w{features --drb --format profile}
        config.parse!(args)
        args.should == %w{features --format profile}
      end

    end

    context '--drb in a profile' do
      it "removes the --drb flag from the args" do
        given_cucumber_yml_defined_as({'server' => '--drb features'})
        config = Configuration.new(StringIO.new)

        args = %w{--profile server}
        config.parse!(args)
        args.should == %w{features}
      end

      it "keeps all other flags intact from all profiles involved" do
        given_cucumber_yml_defined_as({'server' => '--drb features --profile nested',
                                       'nested' => '--verbose'})

        config = Configuration.new(StringIO.new)

        args = %w{--profile server --format profile}
        config.parse!(args)
        args.should == %w{features --verbose --format profile}
      end

    end

    it "should expand args from YAML file" do
      given_cucumber_yml_defined_as({'bongo' => '--require from/yml'})

      config = Configuration.new
      config.parse!(%w{--format progress --profile bongo})
      config.options[:formats].should == {'progress' => STDOUT}
      config.options[:require].should == ['from/yml']
    end

    it "should expand args from YAML file's default if there are no args" do
      given_cucumber_yml_defined_as({'default' => '--require from/yml'})

      config = Configuration.new
      config.parse!([])
      config.options[:require].should == ['from/yml']
    end

    it "should provide a helpful error message when a specified profile does not exists in YAML file" do
      given_cucumber_yml_defined_as({'default' => '--require from/yml', 'html_report' =>  '--format html'})

      config = Configuration.new(StringIO.new, error = StringIO.new)
      expected_message = <<-END_OF_MESSAGE
Could not find profile: 'i_do_not_exist'

Defined profiles in cucumber.yml:
  * default
  * html_report
END_OF_MESSAGE

      lambda{config.parse!(%w{--profile i_do_not_exist})}.should raise_error(expected_message)
    end

    it "should allow array as profile" do
      given_cucumber_yml_defined_as({'foo' => [1,2,3]})

      config = Configuration.new(StringIO.new, error = StringIO.new)
      config.parse!(%w{--profile foo})
      config.paths.should == [1,2,3]
    end

    it "should provide a helpful error message when a specified profile exists but is nil or blank" do
      [nil, '   '].each do |bad_input|
        given_cucumber_yml_defined_as({'foo' => bad_input})

        config = Configuration.new(StringIO.new, error = StringIO.new)
        expected_error = /The 'foo' profile in cucumber.yml was blank.  Please define the command line arguments for the 'foo' profile in cucumber.yml./
        lambda{config.parse!(%w{--profile foo})}.should raise_error(expected_error)
      end
    end

    it "should provide a helpful error message when no YAML file exists and a profile is specified" do
      File.should_receive(:exist?).with('cucumber.yml').and_return(false)

      config = Configuration.new(StringIO.new, error = StringIO.new)
      expected_error = /cucumber.yml was not found.  Please refer to cucumber's documentation on defining profiles in cucumber.yml./
      lambda{config.parse!(%w{--profile i_do_not_exist})}.should raise_error(expected_error)
    end

    it "should provide a helpful error message when cucumber.yml is blank or malformed" do
        expected_error_message = /cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentation on correct profile usage./

      ['', 'sfsadfs', "--- \n- an\n- array\n", "---dddfd"].each do |bad_input|
        given_cucumber_yml_defined_as(bad_input)

        config = Configuration.new(StringIO.new, error = StringIO.new)
        lambda{config.parse!([])}.should raise_error(expected_error_message)
      end
    end

    it "should procide a helpful error message when the YAML can not be parsed" do
      expected_error_message = /cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentation on correct profile usage./

      given_cucumber_yml_defined_as("input that causes an exception in YAML loading")
      YAML.should_receive(:load).and_raise ArgumentError

      config = Configuration.new(StringIO.new, error = StringIO.new)
      lambda{config.parse!([])}.should raise_error(expected_error_message)
    end

    it "should accept --dry-run option" do
      config = Configuration.new(StringIO.new)
      config.parse!(%w{--dry-run})
      config.options[:dry_run].should be_true
    end

    it "should accept --no-source option" do
      config = Configuration.new
      config.parse!(%w{--no-source})

      config.options[:source].should be_false
    end

    it "should accept --no-snippets option" do
      config = Configuration.new
      config.parse!(%w{--no-snippets})

      config.options[:snippets].should be_false
    end

    it "should set snippets and source to false with --quiet option" do
      config = Configuration.new
      config.parse!(%w{--quiet})

      config.options[:snippets].should be_nil
      config.options[:source].should be_nil
    end

    it "should accept --verbose option" do
      config = Configuration.new
      config.parse!(%w{--verbose})

      config.options[:verbose].should be_true
    end

    it "should accept --out option" do
      config = Configuration.new(StringIO.new)
      config.parse!(%w{--out jalla.txt})
      config.options[:formats]['pretty'].should == 'jalla.txt'
    end

    it "should accept multiple --out options" do
      config = Configuration.new(StringIO.new)
      config.parse!(%w{--format progress --out file1 --out file2})
      config.options[:formats].should == {'progress' => 'file2'}
    end

    it "should accept multiple --format options" do
      config = Configuration.new(StringIO.new)
      config.parse!(%w{--format pretty --format progress})
      config.options[:formats].should have_key('pretty')
      config.options[:formats].should have_key('progress')
    end

    it "should associate --out to previous --format" do
      config = Configuration.new(StringIO.new)
      config.parse!(%w{--format progress --out file1 --format profile --out file2})
      config.options[:formats].should == {"profile"=>"file2", "progress"=>"file1"}
    end

    it "should accept --color option" do
      Term::ANSIColor.should_receive(:coloring=).with(true)
      config = Configuration.new(StringIO.new)
      config.parse!(['--color'])
    end

    it "should accept --no-color option" do
      Term::ANSIColor.should_receive(:coloring=).with(false)
      config = Configuration.new(StringIO.new)
      config.parse!(['--no-color'])
    end

    it "should parse tags" do
      config = Configuration.new(nil)
      includes, excludes = config.parse_tags("one,~two,@three,~@four")
      includes.should == ['one', 'three']
      excludes.should == ['two', 'four']
    end

    describe "--backtrace" do
      before do
        Exception.cucumber_full_backtrace = false
      end

      it "should show full backtrace when --backtrace is present" do
        config = Main.new(['--backtrace'])
        begin
          "x".should == "y"
        rescue => e
          e.backtrace[0].should_not == "#{__FILE__}:#{__LINE__ - 2}"
        end
      end

      after do
        Exception.cucumber_full_backtrace = false
      end
    end

    describe "diff output" do

      it "is enabled by default" do
        config = Configuration.new
        config.diff_enabled?.should be_true
      end

      it "is disabled when the --no-diff option is supplied" do
        config = Configuration.new
        config.parse!(%w{--no-diff})

        config.diff_enabled?.should be_false
      end

    end

    it "should accept multiple --name options" do
      config = Configuration.new
      config.parse!(['--name', "User logs in", '--name', "User signs up"])

      config.options[:name_regexps].should include(/User logs in/)
      config.options[:name_regexps].should include(/User signs up/)
    end

    it "should accept multiple -n options" do
      config = Configuration.new
      config.parse!(['-n', "User logs in", '-n', "User signs up"])

      config.options[:name_regexps].should include(/User logs in/)
      config.options[:name_regexps].should include(/User signs up/)
    end

    it "should search for all features in the specified directory" do
      File.stub!(:directory?).and_return(true)
      Dir.should_receive(:[]).with("feature_directory/**/*.feature").
        any_number_of_times.and_return(["cucumber.feature"])

      config = Configuration.new(StringIO)
      config.parse!(%w{feature_directory/})

      config.feature_files.should == ["cucumber.feature"]
    end

  end
end
end
