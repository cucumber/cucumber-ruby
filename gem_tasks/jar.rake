# http://blog.nicksieger.com/articles/2009/01/10/jruby-1-1-6-gems-in-a-jar

task :jar => [
  :clean,
  'jar:download_jruby',
  'jar:install_gems',
  'jar:bundle_gems',
  'jar:download_jars_deps',
  'jar:unpack_jar_deps',
  'jar:test_jar'
]

namespace :jar do
  task :download_jruby do
    sh 'wget http://dist.codehaus.org/jruby/1.1.6/jruby-complete-1.1.6.jar -O cucumber.jar'
  end

  task :install_gems => :gem do
    mkdir 'pkg/jar_gems'
    sh 'java -jar cucumber.jar -S gem install -i ./pkg/jar_gems pkg/cucumber-0.1.99.14.gem --no-ri --no-rdoc'
  end

  task :bundle_gems do
    sh 'jar uf cucumber.jar -C pkg/jar_gems .'
  end

  task :download_jars_deps do
    mkdir 'pkg/jar_deps'
    sh 'wget http://repository.codehaus.org/org/jbehave/jbehave-core/2.1/jbehave-core-2.1.jar -O pkg/jar_deps/jbehave.jar'
    sh 'wget http://mirrors.ibiblio.org/pub/mirrors/maven2/junit/junit/4.5/junit-4.5.jar -O pkg/jar_deps/junit.jar'
    sh 'wget http://hamcrest.googlecode.com/files/hamcrest-all-1.1.jar -O pkg/jar_deps/hamcrest.jar'
  end

  task :unpack_jar_deps do
    Dir.chdir 'pkg/jar_deps' do
      Dir['*.jar'].each do |jar|
        sh "jar xvf #{jar}"
        rm_rf jar
        rm_rf 'META-INF'
      end
    end
  end

  task :bundle_jars do
    sh 'jar uf cucumber.jar -C pkg/jar_deps .'
  end
  
  task :fix_gem_binaries do
    mkdir_p 'pkg/gem_binaries/META-INF/jruby.home'
    Dir.chdir 'pkg/gem_binaries/META-INF/jruby.home' do
      sh 'jar xvf ../../../../cucumber.jar bin'
    end
    sh 'jar uf cucumber.jar -C pkg/gem_binaries .'
  end

  task :test_jar do
    sh 'java -cp examples/jbehave/target/classes -jar cucumber.jar -S cucumber examples/jbehave/features'
  end
end
