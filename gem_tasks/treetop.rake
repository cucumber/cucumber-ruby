namespace :tt do
  files = %w{lib/cucumber/parser/common.tt lib/cucumber/parser/feature.tt lib/cucumber/parser/py_string.tt lib/cucumber/parser/table.tt}

  desc 'Compile .tt files'
  task :compile do
    files.each {|tt| sh("tt #{tt}") }
  end

  desc 'Remove compiled .tt files'
  task :rm do
    rm_rf files.map{|tt| tt.gsub(/\.tt$/, '.rb')}
  end
end