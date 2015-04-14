require 'rake/clean'

R_SOURCE_FILES = Rake::FileList["**/*.rmd"]

RUBY_SOURCE_FILES = Rake::FileList.new("**/*.rb") do |fl|
  fl.exclude(/^common\//)
  fl.exclude(/^old_not_converted\//)
end


task :default => :html


task :csv => RUBY_SOURCE_FILES.ext(".csv")
task :html => [:csv, R_SOURCE_FILES.ext(".html")].flatten


rule ".csv" => ".rb" do |t|
  puts "Running #{t.source}"
  puts `ruby #{t.source}`
end

rule ".html" => ".Rmd" do |t|
   puts "Running #{t.source}"
   puts `R -e "rmarkdown::render('#{t.source}')"`
end



CLEAN.include(RUBY_SOURCE_FILES.ext(".csv"))
CLOBBER.include(R_SOURCE_FILES.ext(".html"))