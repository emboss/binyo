require 'rake'
require 'rake/extensiontask'
require 'rspec/core/rake_task'
require 'rdoc/task'

$config_options = []

task :default => :compile

task :clean do
  rm_f FileList['*.gcov']
end

Rake::ExtensionTask.new('binyo') do |ext|
  ext.ext_dir = "ext/binyo"
  ext.lib_dir = "lib"
  ext.config_options = $config_options
  ext.cross_compile = true
  ext.cross_platform = 'i386-mswin32'
end

RSpec::Core::RakeTask.new('spec-run') do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.fail_on_error = false
end

task 'enable-coverage' do
  # ugly, but we cannot define 2 ExtensionTasks for the same ext.name.
  $config_options << '-g'
end

task 'enable-profiler' do
  #to enable profiling run
  #rake build-profiler -- --with-profiler-dir=<path_to>/gperftools/'
  $config_options << '-p'
end

desc 'requires gcov and lcov in $PATH'
task 'report-coverage' do
  outdir = File.dirname(Dir['tmp/**/Makefile'].first)
  curdir = Dir.pwd
  Dir.chdir(outdir) do
    sh "lcov -c -i -d . -o binyo_base.info"
    Dir.entries("#{curdir}/ext/binyo").each do |f|
      next if File.directory? f || f !~ /\.[hc]$/
      # See http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=535755
      sh "gcov -o . #{f}"
    end
    sh "lcov -c -d . -o binyo.info"
    sh "lcov -a binyo.info -a binyo_base.info -o binyo_total.info"
    sh "lcov -r binyo_total.info ruby.h --output-file binyo_total.info"
    sh "lcov -r binyo_total.info '*include*' --output-file binyo_total.info"
    sh "genhtml -o coverage binyo_total.info"
  end
end

desc 'Build ext for coverage and generate a coverage report of spec.'
task 'coverage' => ['clean', 'enable-coverage', 'compile', 'spec-run', 'report-coverage']

desc 'Build and run RSpec code examples'
task 'spec' => ['compile', 'spec-run']

task 'build' => 'compile'

task 'build-debug' => ['enable-coverage', 'build']
task 'build-profiler' => ['enable-profiler', 'build']
  
Rake::RDocTask.new("doc") do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = "binyo"
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('ext/**/*')
end

desc 'Ensure that bundle is installed for spec run'
task 'bundler-install' do
  sh 'bundle install'
end

desc 'Run the specs for valgrind analysis'
task 'valgrind-spec-run' do
  sh 'valgrind --suppressions=.ruby.supp --leak-check=full --num-callers=50 --partial-loads-ok=yes --undef-value-errors=no --trace-children=yes bundle exec rake spec'
end

desc 'Build from scratch with debug symbols and run valgrind on a spec run (requires valgrind on PATH)'
task 'valgrind' => ['clean', 'build-debug', 'bundler-install', 'valgrind-spec-run']
