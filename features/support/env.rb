require 'spec'
require 'fileutils'

Before do
  FileUtils.rm_rf 'examples/self_test/tmp'
  FileUtils.mkdir 'examples/self_test/tmp'
end