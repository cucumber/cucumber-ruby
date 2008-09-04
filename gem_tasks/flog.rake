desc "Run flog over significant files"
task :flog do
  sh "find lib -name \\*.rb | grep -v feature_..\\.rb | xargs flog"
end