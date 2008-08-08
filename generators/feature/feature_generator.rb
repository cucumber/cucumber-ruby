# This generator bootstraps a Rails project for use with Cucumber
class FeatureGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory 'features/steps'
      m.template  'feature.erb', "features/manage_#{plural_name}.feature"
      m.template  'steps.erb', "features/steps/#{singular_name}_steps.rb"
    end
  end

protected

  def banner
    "Usage: #{$0} cucumber"
  end

end