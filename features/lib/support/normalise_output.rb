# override aruba to filter out some stuff
module NormaliseArubaOutput
  def all_stdout
    normalise_output(super)
  end

  def normalise_output(out)
    out = out.gsub(/#{Dir.pwd}\/tmp\/aruba/, '.') # Remove absolute paths
    out = out.gsub(/tmp\/aruba\//, '')            # Fix aruba path
    out = out.gsub(/^.*cucumber_process\.rb.*$\n/, '')
    out = out.gsub(/^\d+m\d+\.\d+s$/, '0m0.012s') # Make duration predictable
    out = out.gsub(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage.*\n$/, '') # Remove SimpleCov message
  end
end
World(NormaliseArubaOutput)

