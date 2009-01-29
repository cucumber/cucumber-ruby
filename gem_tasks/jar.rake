task :download_jruby => [:clean, :gem] do
  sh 'wget http://dist.codehaus.org/jruby/1.1.6/jruby-complete-1.1.6.jar -O cucumber.jar'
end

task :install_gems do
  mkdir 'pkg/jar_gems'
  sh 'java -jar cucumber.jar -S gem install -i ./pkg/jar_gems pkg/cucumber-0.1.99.14.gem'
end