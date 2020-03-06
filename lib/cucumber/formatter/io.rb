# frozen_string_literal: true

require 'cucumber/formatter/http_io'

module Cucumber
  module Formatter
    module Io
      module_function

      def ensure_io(path_or_url_or_io)
        return nil if path_or_url_or_io.nil?
        return path_or_url_or_io if path_or_url_or_io.respond_to?(:write)
        io = if path_or_url_or_io.match(%r{^https?://})
               HTTPIO.open(path_or_url_or_io)
             else
               File.open(path_or_url_or_io, Cucumber.file_mode('w'))
             end
        at_exit do
          unless io.closed?
            io.flush
            io.close
          end
        end
        io
      end

      def ensure_file(path, name)
        raise "You *must* specify --out FILE for the #{name} formatter" unless String == path.class
        raise "I can't write #{name} to a directory - it has to be a file" if File.directory?(path)
        raise "I can't write #{name} to a file in the non-existing directory #{File.dirname(path)}" unless File.directory?(File.dirname(path))
        ensure_io(path)
      end

      def ensure_dir(path, name)
        raise "You *must* specify --out DIR for the #{name} formatter" unless String == path.class
        raise "I can't write #{name} reports to a file - it has to be a directory" if File.file?(path)
        FileUtils.mkdir_p(path) unless File.directory?(path)
        File.absolute_path path
      end
    end
  end
end
