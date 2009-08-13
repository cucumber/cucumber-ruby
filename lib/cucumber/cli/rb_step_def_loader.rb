module Cucumber
  module Cli
    class RbStepDefLoader
      def load_step_def_file(main, step_def_file)
        begin
          require step_def_file
        rescue LoadError => e
          e.message << "\nFailed to load #{step_def_file}"
          raise e
        end
      end
    end
  end
end