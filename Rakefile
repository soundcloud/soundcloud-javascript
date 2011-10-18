task :help do 
  puts "No Help. You are all on your own."
end

task :build => [:create_build_dir, :build_js, :build_static, :build_examples] do
end

task :create_build_dir do
  sh "mkdir -p #{build_dir}"
end

task :build_static => [:build_static_legacy, :build_static_crossdomain_js, :build_static_soundmanager, :build_static_uri] do
end

task :build_static_legacy do
  sh "cp -R static/legacy/* #{build_dir}"
end

task :build_static_crossdomain_js do
  sh "mkdir -p #{build_dir}/crossdomain-requests-js"
  sh "cp -R static/crossdomain-requests-js/public/* #{build_dir}/crossdomain-requests-js"
  sh compress_cmd("#{build_dir}/crossdomain-requests-js/crossdomain-ajax.js", "#{build_dir}/crossdomain-requests-js/crossdomain-ajax.min.js")
end

task :build_static_soundmanager do 
  sh "mkdir -p #{build_dir}/soundmanager2/script #{build_dir}/soundmanager2/swf"
  sh "cp -R static/soundmanager2/script/soundmanager2-nodebug-jsmin.js #{build_dir}/soundmanager2/soundmanager2.js"
  sh "cp -R static/soundmanager2/swf/soundmanager2_flash_xdomain/*.swf #{build_dir}/soundmanager2/"
end

task :build_static_uri do
  sh "cat static/uri/build/uri.js | sed -e 's/window.URI/window.SC.URI/g' >> #{build_dir}/sdk.js"
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
  sh compress_cmd("#{build_dir}/sdk.js", "#{build_dir}/sdk.min.js")
end

def compress_cmd(from, to)
  "closure-compiler --js #{from} > #{to}"
end

def example_build_cmd
  cmd = ""
  (Dir.new("examples").to_a - [".", ".."]).each do |file|
    cmd += "cat examples/#{file} "
    if target == "release"
      # should  be applied to everything.
      cmd += %{| sed -e 's/.soundcloud.dev\\/dev/.soundcloud.com/g' | sed -e 's/694f15bbffd7ae8e6e399f49dd228725/c202b469a633a7a5b15c9e10b5272b78/' }
    end
    cmd += " > #{build_dir}/examples/#{file};\n"
  end
  cmd
end

def build_dir
  "build/#{target}"
end

def target
  ENV["TARGET"] || "development"
end

def coffee_script_cmd(watch=false)
  "coffee --bare --lint -o #{build_dir} --#{watch ? "watch" : "compile"}  src/sdk.coffee"
end
