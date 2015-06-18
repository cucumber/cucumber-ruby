module Cucumber
  module Cli
    class RerunFile
      attr_reader :path

      def self.rerun_file?(path)
        path[0] == '@' && File.file?(real_path(path))
      end

      def self.real_path(path)
        path[1..-1] # remove leading @
      end

      def initialize(path)
        @path = self.class.real_path(path)
      end

      def features
        lines.map { |l| l.scan(/(?:^| )(.*?\.feature(?:(?::\d+)*))/) }
      end

      private

      def lines
        IO.read(@path).split("\n")
      end
    end
  end
end
