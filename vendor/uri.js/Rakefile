task :build => [:create_build_dir, :build_js, :compress] do
  
end

task :create_build_dir do
  sh "mkdir -p build/"
end

task :build_js do
  sh coffee_script_cmd
end

task :watch do
  sh coffee_script_cmd(true)
end

task :clean do
  sh "rm -rf build/*"
end

task :test do
  sh "open tests/index.html"
end

task :compress do |t|
  sh "closure-compiler --js build/uri.js > build/uri.min.js "
end

def coffee_script_cmd(watch=false)
  "coffee --bare --lint -o build --#{watch ? "watch" : "compile"}  src/uri.coffee"
end

