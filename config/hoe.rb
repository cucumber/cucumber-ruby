# encoding: utf-8
require 'cucumber/version'

AUTHOR = 'Aslak Hellesøy'  # can also be an array of Authors
EMAIL = "aslak.hellesoy@gmail.com"
DESCRIPTION = "Executable Feature scenarios"
GEM_NAME = 'cucumber' # what ppl will type to install your gem
HOMEPATH = "http://cukes.info"
RUBYFORGE_PROJECT = 'rspec'

@config_file = "~/.rubyforge/user-config.yml"
@config = nil
RUBYFORGE_USERNAME = "aslak_hellesoy"
def rubyforge_username
  unless @config
    begin
      @config = YAML.load(File.read(File.expand_path(@config_file)))
    rescue
      puts <<-EOS
ERROR: No rubyforge config file found: #{@config_file}
Run 'rubyforge setup' to prepare your env for access to Rubyforge
 - See http://newgem.rubyforge.org/rubyforge.html for more details
      EOS
      exit
    end
  end
  RUBYFORGE_USERNAME.replace @config["username"]
end


REV = nil 
# UNCOMMENT IF REQUIRED: 
# REV = YAML.load(`svn info`)['Revision']
VERS = Cucumber::VERSION::STRING + (REV ? ".#{REV}" : "")
RDOC_OPTS = ['--quiet', '--title', 'Cucumber documentation',
    "--opname", "index.html",
    "--line-numbers", 
    "--main", "README.textile",
    "--inline-source"]

# Remove Hoe dependency
class Hoe
  def extra_dev_deps
    @extra_dev_deps.reject! { |dep| dep[0] == "hoe" }
    @extra_dev_deps
  end
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec(GEM_NAME) do |p|
  p.version = VERS
  p.developer(AUTHOR, EMAIL)
  p.description = DESCRIPTION
  p.summary = DESCRIPTION
  p.url = HOMEPATH
  p.rubyforge_name = RUBYFORGE_PROJECT if RUBYFORGE_PROJECT
  p.clean_globs |= ['**/.*.sw?', '*.gem', '.config', '**/.DS_Store', '**/*.class', '**/*.jar', '**/tmp']  #An array of file patterns to delete on clean.
  
  # == Optional
  p.changes = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  #p.extra_deps = []     # An array of rubygem dependencies [name, version], e.g. [ ['active_support', '>= 1.3.1'] ]
  p.extra_deps = [ 
    ['term-ansicolor', '>= 1.0.3'], 
    ['treetop', '>= 1.3.0'], 
    ['diff-lcs', '>= 1.1.2'],
    ['builder', '>= 2.1.2']
  ]

  #p.spec_extras = {}    # A hash of extra values to set in the gemspec.
  
end

CHANGES = $hoe.paragraphs_of('History.txt', 0..1).join("\\n\\n")
PATH    = (RUBYFORGE_PROJECT == GEM_NAME) ? RUBYFORGE_PROJECT : "#{RUBYFORGE_PROJECT}/#{GEM_NAME}"
$hoe.remote_rdoc_dir = File.join(PATH.gsub(/^#{RUBYFORGE_PROJECT}\/?/,''), 'rdoc')
$hoe.rsync_args = '-av --delete --ignore-errors'