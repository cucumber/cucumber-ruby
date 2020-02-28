# frozen_string_literal: true
require 'net/http'

module Cucumber
  module Formatter
    module Io
      module_function

      def ensure_io(path_or_url_or_io)
        return nil if path_or_url_or_io.nil?
        return path_or_url_or_io if path_or_url_or_io.respond_to?(:write)
        if path_or_url_or_io.match(/^http/)
          io = HTTPIO.new(path_or_url_or_io) 
        else
          io = File.open(path_or_url_or_io, Cucumber.file_mode('w'))
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
      
      class HTTPIO
        def initialize(url)
          @url = url
          @closed = false
          @body = ''
        end
        
        def write(chunk)
          @body += chunk
        end
        
        def closed?
          @closed
        end
        
        def flush
          uri = URI(@url)
          req = Net::HTTP::Post.new(uri)
          req.body = @body
          http = Net::HTTP.new(uri.hostname, uri.port)
          http.use_ssl = uri.scheme == 'https'
          res = http.request(req)
          raise "Not OK" unless Net::HTTPOK === res
        end
        
        def close
          @closed = true
        end
      end
    end
  end
end
