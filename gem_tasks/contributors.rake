task :contributors do
  contributors = `git log --pretty=short --no-merges | git shortlog -ne | egrep -ve '^ +' | egrep -ve '^$'`
  puts contributors.split("\n").length
end