# frozen_string_literal: true

require 'shellwords'

module Cucumber
  module Formatter
    class CurlOptionParser
      def self.parse(options)
        args = Shellwords.split(options)

        url = nil
        http_method = 'PUT'
        headers = {}

        until args.empty?
          arg = args.shift
          case arg
          when '-X', '--request'
            http_method = remove_arg_for(args, arg)
          when '-H'
            header_arg = remove_arg_for(args, arg)
            headers = headers.merge(parse_header(header_arg))
          else
            raise StandardError, "#{options} was not a valid curl command. Can't set url to #{arg} it is already set to #{url}" if url

            url = arg
          end
        end
        raise StandardError, "#{options} was not a valid curl command" unless url

        [url, http_method, headers]
      end

      private

      def self.remove_arg_for(args, arg)
        return args.shift unless args.empty?

        raise StandardError, "Missing argument for #{arg}"
      end

      def self.parse_header(header_arg)
        parts = header_arg.split(':', 2)
        raise StandardError, "#{header_arg} was not a valid header" unless parts.length == 2

        { parts[0].strip => parts[1].strip }
      end
    end
  end
end
