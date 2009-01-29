# http://blog.nicksieger.com/articles/2009/01/10/jruby-1-1-6-gems-in-a-jar

USE_JRUBY_VERSION    = '1.1.6'
USE_JBEHAVE_VERSION  = '2.1'
USE_JUNIT_VERSION    = '4.5'
USE_HAMCREST_VERSION = '1.1'
CUCUMBER_VERSIONED   = "cucumber-#{Cucumber::VERSION::STRING}"

task :jar => [
  :clean,
  'jar:download_jruby',
  'jar:install_gems',
  'jar:bundle_gems',
  'jar:download_jars_deps',
  'jar:unpack_jar_deps',
  'jar:bundle_jars',
  'jar:fix_gem_binaries',
  'jar:test_jar'
]

namespace :jar do
  task :download_jruby do
    sh "wget http://dist.codehaus.org/jruby/#{USE_JRUBY_VERSION}/jruby-complete-#{USE_JRUBY_VERSION}.jar -O #{CUCUMBER_VERSIONED}.jar"
  end

  task :install_gems => :gem do
    mkdir 'pkg/jar_gems'
    sh "java -jar #{CUCUMBER_VERSIONED}.jar -S gem install -i ./pkg/jar_gems pkg/#{CUCUMBER_VERSIONED}.gem --no-ri --no-rdoc"
  end

  task :bundle_gems do
    sh "jar uf #{CUCUMBER_VERSIONED}.jar -C pkg/jar_gems ."
  end

  task :download_jars_deps do
    mkdir 'pkg/jar_deps'
    sh "wget http://repository.codehaus.org/org/jbehave/jbehave-core/#{USE_JBEHAVE_VERSION}/jbehave-core-#{USE_JBEHAVE_VERSION}.jar -O pkg/jar_deps/jbehave-core-#{USE_JBEHAVE_VERSION}.jar"
    sh "wget http://mirrors.ibiblio.org/pub/mirrors/maven2/junit/junit/#{USE_JUNIT_VERSION}/junit-#{USE_JUNIT_VERSION}.jar -O pkg/jar_deps/junit-#{USE_JUNIT_VERSION}.jar"
    sh "wget http://hamcrest.googlecode.com/files/hamcrest-all-#{USE_HAMCREST_VERSION}.jar -O pkg/jar_deps/hamcrest-all-#{USE_HAMCREST_VERSION}.jar"
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
    sh "jar uf #{CUCUMBER_VERSIONED}.jar -C pkg/jar_deps ."
  end
  
  task :fix_gem_binaries do
    mkdir_p 'pkg/gem_binaries/META-INF/jruby.home'
    Dir.chdir 'pkg/gem_binaries/META-INF/jruby.home' do
      sh "jar xvf ../../../../#{CUCUMBER_VERSIONED}.jar bin"
    end
    sh "jar uf #{CUCUMBER_VERSIONED}.jar -C pkg/gem_binaries ."
  end

  task :test_jar do
    sh "java -cp examples/jbehave/target/classes -jar #{CUCUMBER_VERSIONED}.jar -S cucumber examples/jbehave/features"
  end
end
