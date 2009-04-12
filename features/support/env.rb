require 'rubygems'
require 'spec/expectations'
require 'fileutils'
require 'forwardable'


class CucumberWorld
  extend Forwardable
  def_delegators CucumberWorld, :examples_dir, :self_test_dir, :working_dir

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

  def initialize
    @current_dir = self_test_dir
  end

  private

  def create_file(file_name, file_content)
    in_current_dir do
      File.open(file_name, 'w') { |f| f << file_content }
    end
  end

  def in_current_dir(&block)
    Dir.chdir(@current_dir, &block)
  end

end

World do
  CucumberWorld.new
end

After do
  FileUtils.rm_rf CucumberWorld.working_dir
  FileUtils.mkdir CucumberWorld.working_dir
end
