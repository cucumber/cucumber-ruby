module Cucumber
  module Cli

    class ProfileLoader

      def args_from(profile)
        unless cucumber_yml.has_key?(profile)
          raise(ProfileNotFound, <<-END_OF_ERROR)
Could not find profile: '#{profile}'

Defined profiles in cucumber.yml:
  * #{cucumber_yml.keys.join("\n  * ")}
        END_OF_ERROR
        end

        args_from_yml = cucumber_yml[profile] || ''

        case(args_from_yml)
          when String
            raise YmlLoadError, "The '#{profile}' profile in cucumber.yml was blank.  Please define the command line arguments for the '#{profile}' profile in cucumber.yml.\n" if args_from_yml =~ /^\s*$/
            args_from_yml = args_from_yml.split(' ')
          when Array
            raise YmlLoadError, "The '#{profile}' profile in cucumber.yml was empty.  Please define the command line arguments for the '#{profile}' profile in cucumber.yml.\n" if args_from_yml.empty?
          else
            raise YmlLoadError, "The '#{profile}' profile in cucumber.yml was a #{args_from_yml.class}. It must be a String or Array"
        end
        args_from_yml
      end

      def has_profile?(profile)
        cucumber_yml.has_key?(profile)
      end

      def cucumber_yml_defined?
        @defined ||= File.exist?('cucumber.yml')
      end

    private

      def cucumber_yml
        return @cucumber_yml if @cucumber_yml
        unless cucumber_yml_defined?
          raise(ProfilesNotDefinedError,"cucumber.yml was not found.  Please refer to cucumber's documentation on defining profiles in cucumber.yml.  You must define a 'default' profile to use the cucumber command without any arguments.\nType 'cucumber --help' for usage.\n")
        end

        require 'erb'
        require 'yaml'
        begin 
          @cucumber_erb = ERB.new(IO.read('cucumber.yml')).result
        rescue Exception => e 
          raise(YmlLoadError,"cucumber.yml was found, but could not be parsed with ERB.  Please refer to cucumber's documentation on correct profile usage.\n#{$!.inspect}")
        end

        begin
          @cucumber_yml = YAML::load(@cucumber_erb)
        rescue StandardError => e
          raise(YmlLoadError,"cucumber.yml was found, but could not be parsed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        if @cucumber_yml.nil? || !@cucumber_yml.is_a?(Hash)
          raise(YmlLoadError,"cucumber.yml was found, but was blank or malformed. Please refer to cucumber's documentation on correct profile usage.\n")
        end

        return @cucumber_yml
      end

    end
  end
end

