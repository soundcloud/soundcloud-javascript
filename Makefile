build: build_deps prepare_build_dir build_coffee build_vendor build_examples build_tests minify
	echo "done"

prepare_build_dir:
	mkdir -p build

build_deps:
	npm install

build_recorder_js:
	mkdir -p build/recorder.js
	cp vendor/recorder.js/soundcloudRecorder.swf build/recorder.js/recorder-`cat vendor/recorder.js/VERSION`.swf
	cat vendor/recorder.js/recorder.js >> build/sdk.unminified.js

build_soundmanager2:
	mkdir -p build/soundmanager2
	cp vendor/soundmanager2/script/soundmanager2-nodebug-jsmin.js build/soundmanager2/soundmanager2.js
	unzip -j -o vendor/soundmanager2/swf/soundmanager2_flash_xdomain.zip soundmanager2_flash_xdomain/soundmanager2.swf soundmanager2_flash_xdomain/soundmanager2_flash9.swf -d build/soundmanager2/

build_uri_js:
	cat vendor/uri.js/build/uri.js | sed -e 's/window.URI/window.SC.URI/g' >> build/sdk.unminified.js

build_legacy:
	cp -R vendor/legacy/* build/

build_vendor: build_recorder_js build_soundmanager2 build_uri_js build_dialogs build_legacy

build_coffee:
	node_modules/coffee-script/bin/coffee --join build/sdk.unminified.js --compile src/*.coffee src/sc/*.coffee

build_dialogs:
	mkdir -p build/dialogs
	cp -R vendor/dialogs/* build/dialogs/

build_examples:
	cp -R examples build/

build_tests:
	cp -R test build/

minify:
	./node_modules/uglify-js/bin/uglifyjs build/sdk.unminified.js > build/sdk.js

clean:
	rm -rf build/*
	rm -rf node_modules
