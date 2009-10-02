if Cucumber::VERSION::STRING != '<%= Cucumber::VERSION::STRING %>'
warning = <<-WARNING
(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) 

         (::)   R O T T E N   C U C U M B E R   A L E R T    (::)

Your #{__FILE__.gsub(/version_check.rb$/, 'env.rb')} file was generated with Cucumber <%= Cucumber::VERSION::STRING %>,
but you seem to be running Cucumber #{Cucumber::VERSION::STRING}. If you're running an older 
version than #{Cucumber::VERSION::STRING}, just upgrade your gem. If you're running a newer 
version than #{Cucumber::VERSION::STRING} you should:

  1) Read http://wiki.github.com/aslakhellesoy/cucumber/upgrading
  
  2) Regenerate your cucumber environment with the following command:

     ruby script/generate cucumber

If you get prompted to replace a file, hit 'd' to see the difference.
When you're sure you have captured any personal edits, confirm that you
want to overwrite #{__FILE__.gsub(/version_check.rb$/, 'env.rb')} by pressing 'y'. Then reapply any
personal changes that may have been overwritten. 

This message will then self destruct.

(::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) (::) 
WARNING
warn(warning)
at_exit {warn(warning)}
end