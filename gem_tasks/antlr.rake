namespace :antlr do
  jars = File.dirname(__FILE__) + '/antlr'
  classpath = %w{antlr-3.1.1.rubyfix.jar stringtemplate-3.2.jar antlr-2.7.7.jar}.map{|f| "#{jars}/#{f}"}.join(':')
  src  = File.expand_path(File.dirname(__FILE__) + '/../lib/cucumber/antlr')
  spec = File.expand_path(File.dirname(__FILE__) + '/../spec/cucumber/antlr')

  desc 'Compile grammar'
  task :compile do
    sh "java -cp #{classpath} org.antlr.Tool -o #{src} #{src}/Gherkin.g"
    sh "javac -cp #{classpath} #{src}/*.java"
  end
  
  desc 'Run gUnit'
  task :gunit do
    sh "java -cp #{classpath}:#{src} org.antlr.gunit.Interp #{spec}/Gherkin.gunit"
  end
end