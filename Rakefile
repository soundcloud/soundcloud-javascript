task :help do 
  puts "No Help. You are all on your own."
end

task :build => [:create_build_dir, :build_js, :copy_static, :build_examples] do
end

task :create_build_dir do
  sh "mkdir -p #{build_dir}"
end

task :copy_static do
  #sh "cp -R static/*.* #{build_dir}/"
  
  # uri.js
  sh "cat static/uri/build/uri.js | sed -e 's/window.URI/window.SC.URI/g' >> #{build_dir}/sdk.js"
  
  # soundManager 2 
  sh "mkdir -p #{build_dir}/soundmanager2/script #{build_dir}/soundmanager2/swf"
  sh "cp -R static/soundmanager2/script/soundmanager2-nodebug-jsmin.js #{build_dir}/soundmanager2/soundmanager2.js"
  sh "cp -R static/soundmanager2/swf/soundmanager2_flash_xdomain/*.swf #{build_dir}/soundmanager2/"
end

task :build_js do
  sh coffee_script_cmd
end

task :watch do
  sh "fs-watch src 'echo && echo Rebuilding... && rake build'"
end

task :clean do
  sh "rm -rf #{build_dir}"
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
end


task :compress do |t|
  sh "closure-compiler --js #{SOURCE_FILE} > #{SOURCE_MIN_FILE}"
end


def example_build_cmd
  cmd = ""
  (Dir.new("examples").to_a - [".", ".."]).each do |file|
    cmd += "cat examples/#{file} "
    if environment == "production"
      # should  be applied to everything.
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
