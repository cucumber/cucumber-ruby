require 'rubygems'
require 'tempfile'
require 'spec/expectations'
require 'fileutils'
require 'forwardable'

class CucumberWorld
  extend Forwardable
  def_delegators CucumberWorld, :examples_dir, :self_test_dir, :working_dir, :cucumber_lib_dir

  def self.examples_dir(subdir=nil)
    @examples_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../examples'))
    subdir ? File.join(@examples_dir, subdir) : @examples_dir
  end

  def self.self_test_dir
    @self_test_dir ||= examples_dir('self_test')
  end

  def self.working_dir
    @working_dir ||= examples_dir('self_test/tmp')
  end

  def cucumber_lib_dir
    @cucumber_lib_dir ||= File.expand_path(File.join(File.dirname(__FILE__), '../../lib'))
  end

  def initialize
    @current_dir = self_test_dir
  end

  private
  attr_reader :last_exit_status, :last_stdout, :last_stderr

  def create_file(file_name, file_content)
    file_content.gsub!("CUCUMBER_LIB", "'#{cucumber_lib_dir}'") # Some files, such as Rakefiles need to use the lib dir
    in_current_dir do
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

  def run(command)
    stderr_file = Tempfile.new('cucumber')
    stderr_file.close
    in_current_dir do
      @last_stdout = `#{command} 2> #{stderr_file.path}`
      @last_exit_status = $?.exitstatus
    end
    @last_stderr = IO.read(stderr_file.path)
  end

end

World do
  CucumberWorld.new
end

Before do
  FileUtils.rm_rf CucumberWorld.working_dir
  FileUtils.mkdir CucumberWorld.working_dir
end
