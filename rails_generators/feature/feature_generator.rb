# This generator bootstraps a Rails project for use with Cucumber
class FeatureGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.directory 'features/step_definitions'
      m.template  'feature.erb', "features/manage_#{plural_name}.feature"
      m.template  'steps.erb', "features/step_definitions/#{singular_name}_steps.rb"
    end
  end

protected

  def banner
    "Usage: #{$0} feature ModelName [field:type, field:type]"
  end
end