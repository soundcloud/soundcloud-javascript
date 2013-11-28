BUILD_DIR=build
NODEJS_VERSION=0.8.9
NODEJS=nodejs-0.8.9
DESTDIR=system
TMP=.tmp

build: build_deps prepare_build_dir build_vendor build_coffee build_examples build_tests minify pkgignore
	echo "ok" > build/desktop
	test -z "$(WEBER_HOST)" || $(MAKE) weber
	git log | head -n1 > $(BUILD_DIR)/commit.txt
	echo "done"

pkgignore:
	find . -mindepth 1 -maxdepth 1 | grep -v $(BUILD_DIR) | grep -v weber | sed 's/^\.\///' > .pkgignore

prepare_build_dir:
	rm -rf $(BUILD_DIR)/sdk.unminified.js
	mkdir -p $(BUILD_DIR)

build_deps: $(DESTDIR)/usr/bin/node
	LD_LIBRARY_PATH=$(DESTDIR)/lib PATH=$(DESTDIR)/usr/bin:$(PATH) HOME=$(PWD) npm install

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
	LD_LIBRARY_PATH=$(DESTDIR)/lib PATH=$(DESTDIR)/usr/bin:$(PATH) HOME=$(PWD) node_modules/coffee-script/bin/coffee --join /tmp/sdk.unminified.js --compile src/*.coffee src/sc/*.coffee
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
	LD_LIBRARY_PATH=$(DESTDIR)/lib PATH=$(DESTDIR)/usr/bin:$(PATH) HOME=$(PWD) ./node_modules/uglify-js/bin/uglifyjs $(BUILD_DIR)/sdk.unminified.js > $(BUILD_DIR)/sdk.js

weber: Makefile Procfile
	curl -o weber --compressed http://$(WEBER_HOST)/weber/weber-$(shell uname)-$(shell uname -m)
	chmod +x weber

clean:
	rm -rf $(BUILD_DIR)/* node_modules $(TMP)

### nodejs
$(TMP):
	mkdir -p $(TMP)

$(TMP)/$(NODEJS)/configure:
	# nodejs extracts to joyent-nodes-<git-sha> ... let's use a more predictable path
	mkdir -p $(TMP)/${NODEJS}
	curl -L https://github.com/joyent/node/tarball/v$(NODEJS_VERSION) | tar xzv -C $(TMP)/$(NODEJS) --strip-components 1

$(TMP)/$(NODEJS)/config.gypi: $(TMP)/$(NODEJS)/configure
	cd $(TMP)/$(NODEJS); PKG_CONFIG_PATH=/usr/lib/pkgconfig/openssl.pc ./configure --prefix=/usr

$(DESTDIR)/usr/bin/node: $(TMP)/$(NODEJS)/config.gypi
	PORTABLE=1 make -j4 -C $(TMP)/$(NODEJS) DESTDIR=$(PWD)/$(DESTDIR) install
