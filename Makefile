OS             := $(shell uname)

BUILD_DIR      := $(PWD)/build
TMP            := $(PWD)/.tmp
DEP            := $(TMP)/deps
DESTDIR        := $(BUILD_DIR)/system/$(OS)
DESTBIN        := $(DESTDIR)/bin

NODE_VERSION   := 4.1.0
NODE_MODULES   := $(PWD)/node_modules
NODE           := nodejs-$(NODE_VERSION)
NODE_BIN       := $(DESTBIN)/node
NPM_BIN        := $(DESTBIN)/npm
NM_BIN         := $(PWD)/node_modules/.bin

NODE_HOST      := https://nodejs.org/download/release
NODE_SRC       := node-v$(NODE_VERSION).tar.gz

NPM_REGISTRY := http://npm.dev.s-cloud.net

export PATH := $(DESTBIN):$(NM_BIN):$(PATH)

.PHONY: setup build sc-vendor-libs test run publish dirs clean sc-vendor-libs

setup: $(NODE_BIN)

build: $(NODE_BIN)
	$(NPM_BIN) install
	$(NPM_BIN) run build

test: build
	$(NPM_BIN) run test

run: build
	$(NPM_BIN) run serve

run-with-watcher: build
	$(NPM_BIN) run start

publish: test
	IS_NPM=1 $(NPM_BIN) run build
	$(NPM_BIN) publish

dirs:
	echo $(DESTDIR)
	echo $(DESTBIN)
	echo $(NPM_BIN)

clean:
	rm -rf $(NODE_MODULES) $(BUILD_DIR)/* $(TMP) sdk.js

vendor/audiomanager.js:
	$(NPM_BIN) install @sc/audiomanager --registry=$(NPM_REGISTRY)
	cp $(NODE_MODULES)/@sc/audiomanager/build/audiomanager.min.js vendor/audiomanager.js

vendor/scaudio.js:
	$(NPM_BIN) install @sc/scaudio --registry=$(NPM_REGISTRY)
	cp $(NODE_MODULES)/@sc/scaudio/scaudio.min.js vendor/scaudio.js

sc-vendor-libs: vendor/audiomanager.js vendor/scaudio.js

### nodejs
$(TMP):
	mkdir -p $(TMP)

$(TMP)/$(NODE)/configure:
	mkdir -p $(TMP)/${NODE}
	curl -L $(NODE_HOST)/v$(NODE_VERSION)/$(NODE_SRC) | tar xzv -C $(TMP)/$(NODE) --strip-components 1

$(TMP)/$(NODE)/config.gypi: $(TMP)/$(NODE)/configure
	cd $(TMP)/$(NODE); PKG_CONFIG_PATH=/usr/lib/pkgconfig/openssl.pc ./configure --prefix=$(DESTDIR)

$(NODE_BIN): $(TMP)/$(NODE)/config.gypi
	PORTABLE=1 make -j4 -C $(TMP)/$(NODE) install



