build: prepare_build_dir build_coffee build_vendor build_examples build_tests minify
	echo "done"

prepare_build_dir: 
	mkdir -p build

build_recorder_js:
	mkdir -p build/recorder.js
	cp vendor/recorder.js/soundcloudRecorder.swf build/recorder.js/recorder-`cat vendor/recorder.js/VERSION`.swf
	cat vendor/recorder.js/recorder.js >> build/sdk.tmp.js

build_soundmanager2:
	mkdir -p build/soundmanager2
	cp vendor/soundmanager2/script/soundmanager2-nodebug-jsmin.js build/soundmanager2/soundmanager2.js
	unzip -j -o vendor/soundmanager2/swf/soundmanager2_flash_xdomain.zip soundmanager2_flash_xdomain/soundmanager2.swf soundmanager2_flash_xdomain/soundmanager2_flash9.swf -d build/soundmanager2/

build_uri_js:
	cat vendor/uri.js/build/uri.js | sed -e 's/window.URI/window.SC.URI/g' >> build/sdk.tmp.js

build_legacy:
	cp -R vendor/legacy/* build/

build_vendor: build_recorder_js build_soundmanager2 build_uri_js build_legacy

build_coffee:
	coffee --join build/sdk.tmp.js --compile src/*.coffee src/sc/*.coffee

build_examples:
	cp -R examples build/

build_tests:
	cp -R test build/
	cat test/test.coffee | sed -e 's/TestSuite.inDevelopmentMode = true/TestSuite.inDevelopmentMode = false/g' > build/test/test.coffee

minify:
	closure-compiler --js build/sdk.tmp.js > build/sdk.js
	rm build/sdk.tmp.js

clean:
	rm -rf build/*
