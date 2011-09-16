task :help do 
  puts "No Help. You are all on your own."
end

task :build => [:create_build_dir, :copy_static, :build_js, :build_examples] do
  
end

task :create_build_dir do
  sh "mkdir #{build_dir}"
end

task :copy_static do
  sh "cp -R static/* #{build_dir}/"
end

task :build_js do
  sh coffee_script_cmd
end

task :watch_js do
  sh coffee_script_cmd(true)
end

task :clean do
  sh "rm -r #{build_dir}"
end

task :test do
  sh "open test/test.html"
end


task :build_examples do
  sh "mkdir -p #{build_dir}/examples"
  sh example_build_cmd
end


task :server do
  sh "cd #{build_dir} && ponyhost server &"
  sh "#{coffee_script_cmd(true)} &"
  sh "cat"
  #sh ""
end


task :compress do |t|
  sh "closure-compiler --js #{SOURCE_FILE} > #{SOURCE_MIN_FILE}"
end


def example_build_cmd
  cmd = ""
  (Dir.new("examples").to_a - [".", ".."]).each do |file|
    cmd += "cat examples/#{file} "
    if environment == "production"
      cmd += %{| sed -e 's/connect.soundcloud.dev\\/dev/connect.soundcloud.com/g' | sed -e 's/2b5365454f556fa263eef48cf86c342d/i2crZYFkI1NQCqvOBpAjNA/' }
    end
    cmd += " > #{build_dir}/examples/#{file};\n"
  end
  cmd
end

def build_dir
  "build/#{environment}"
end

def environment
  ENV["ENV"] || "development"
end

def coffee_script_cmd(watch=false)
#  "coffee --bare --lint --join #{build_dir}/sdk.js --#{watch ? "watch" : "compile"} src/*.coffee"
  "coffee --bare --lint -o #{build_dir} --#{watch ? "watch" : "compile"}  src/sdk.coffee"
end
