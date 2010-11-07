require "aruba"

AfterStep do
  @last_stderr.gsub!(/#{Dir.pwd}\/tmp\/aruba/, '.') if @last_stderr
  @last_stdout.gsub!(/#{Dir.pwd}\/tmp\/aruba/, '.') if @last_stdout
end