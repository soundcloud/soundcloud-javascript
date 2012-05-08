BUILD_DIR=build

build: build_deps prepare_build_dir build_vendor build_coffee build_examples build_tests minify pkgignore
	git log | head -n1 > $(BUILD_DIR)/commit.txt
	echo "done"

pkgignore:
	find . -mindepth 1 -maxdepth 1 | grep -v $(BUILD_DIR) | sed 's/^\.\///' > .pkgignore

prepare_build_dir:
	rm -r $(BUILD_DIR)/sdk.unminified.js
	mkdir -p $(BUILD_DIR)

build_deps:
	npm install

build_recorder_js:
	mkdir -p $(BUILD_DIR)/recorder.js
	cp vendor/recorder.js/soundcloudRecorder.swf $(BUILD_DIR)/recorder.js/recorder-0.8.swf
	cp vendor/recorder.js/soundcloudRecorder.swf $(BUILD_DIR)/recorder.js/recorder-`cat vendor/recorder.js/VERSION`.swf
	cat vendor/recorder.js/recorder.js >> $(BUILD_DIR)/sdk.unminified.js

build_soundmanager2:
	mkdir -p $(BUILD_DIR)/soundmanager2
	cp vendor/soundmanager2/script/soundmanager2-nodebug-jsmin.js $(BUILD_DIR)/soundmanager2/soundmanager2.js
	unzip -j -o vendor/soundmanager2/swf/soundmanager2_flash_xdomain.zip soundmanager2_flash_xdomain/soundmanager2.swf soundmanager2_flash_xdomain/soundmanager2_flash9.swf -d $(BUILD_DIR)/soundmanager2/

build_uri_js:
	cat vendor/uri.js/build/uri.js | sed -e 's/window.URI/window.SC = window.SC || {}; window.SC.URI/g' >> $(BUILD_DIR)/sdk.unminified.js

build_legacy:
	cp -R vendor/legacy/* $(BUILD_DIR)/

build_vendor: build_recorder_js build_soundmanager2 build_uri_js build_dialogs build_legacy

build_coffee:
	node_modules/coffee-script/bin/coffee --join /tmp/sdk.unminified.js --compile src/*.coffee src/sc/*.coffee
	cat /tmp/sdk.unminified.js >> $(BUILD_DIR)/sdk.unminified.js
	rm -rf /tmp/sdk.unminified.js

build_dialogs:
	mkdir -p $(BUILD_DIR)/dialogs
	cp -R vendor/dialogs/* $(BUILD_DIR)/dialogs/

build_examples:
	cp -R examples $(BUILD_DIR)/

build_tests:
	cp -R test $(BUILD_DIR)/

minify:
	./node_modules/uglify-js/bin/uglifyjs $(BUILD_DIR)/sdk.unminified.js > $(BUILD_DIR)/sdk.js

clean:
	rm -rf $(BUILD_DIR)/*
	rm -rf node_modules
