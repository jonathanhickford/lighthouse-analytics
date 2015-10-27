require 'rake/clean'

R_SOURCE_FILES = Rake::FileList["**/*.rmd"]

RUBY_SOURCE_FILES = Rake::FileList.new("**/*.rb") do |fl|
  fl.exclude(/^common\//)
  fl.exclude(/^old_not_converted\//)
end


SHAREPOINT_OUTPUT = "\\\\spintranet\\DatabaseDelivery\\Shared Documents\\Product Management\\DLM Dashboard\\Metrics\\Raw Metrics\\"


task :default => :html


task :csv => RUBY_SOURCE_FILES.ext(".csv")
task :html => [:csv, R_SOURCE_FILES.ext(".html")].flatten


rule ".csv" => ".rb" do |t|
  puts "Running #{t.source}"
  run_command "ruby #{t.source}"
  #cp t.name, SHAREPOINT_OUTPUT + File.basename(t.name)
end

rule ".html" => ".Rmd" do |t|
   puts "Running #{t.source}"
   run_command "R -e \"rmarkdown::render('#{t.source}')\""
   #cp t.name, SHAREPOINT_OUTPUT + File.basename(t.name)
end


def run_command(cmd)
  IO.popen(cmd) do |f| 
    while (line = f.gets) do
      puts line
    end
  end
end



CLEAN.include(RUBY_SOURCE_FILES.ext(".csv"))
CLOBBER.include(R_SOURCE_FILES.ext(".html"))