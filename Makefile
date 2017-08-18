OS             := $(shell uname)

BUILD_DIR      := $(PWD)/build
DESTDIR        := $(BUILD_DIR)/system/$(OS)
DESTBIN        := $(DESTDIR)/bin
NM_BIN         := $(PWD)/node_modules/.bin

DEP := vendor

NODE_VERSION := 6.11.1
NODE         := nodejs-$(NODE_VERSION)
NPM_BIN      := $(DESTBIN)/npm

export PATH := $(DESTBIN):$(NM_BIN):$(PATH)

.PHONY: setup build sc-vendor-libs test run publish dirs clean

node_modules: $(NPM_BIN) package.json
	$(NPM_BIN) install
	@touch $@

setup: $(NPM_BIN)

build: node_modules
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
	rm -rf $(NODE_MODULES) $(BUILD_DIR)/* $(TMP) $(DEP)/node sdk.js vendor/playback/playback.js

sc-vendor-libs: node_modules
	$(NPM_BIN) install \
		@sc/scaudio \
		@sc/scaudio-public-api-stream-url-retriever \
		@sc/maestro-core \
		@sc/maestro-loaders \
		@sc/maestro-html5-player \
		@sc/maestro-hls-mse-player
	$(NPM_BIN) run buildPlayback

$(NPM_BIN): $(DESTDIR)/usr/lib/$(NODE)/bin/node
	@mkdir -p $(@D)
	ln -sf $(DESTDIR)/usr/lib/$(NODE)/bin/npm $@
	@touch $@

$(DESTDIR)/usr/lib/$(NODE)/bin/node: $(DEP)/node/$(OS)/$(NODE_VERSION).tar.gz
	@mkdir -p $(@D)
	tar xz -C $(DESTDIR)/usr/lib/$(NODE) --strip-components 1 -f $<
	@touch $@

$(DEP)/node/$(OS)/$(NODE_VERSION).tar.gz:
	http_proxy=$(PROXY) curl -q --create-dirs --fail --location https://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION)-linux-x64.tar.xz --output $@
	@touch $@
