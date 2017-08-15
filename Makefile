OS             := $(shell uname)

BUILD_DIR      := $(PWD)/build
DESTDIR        := $(BUILD_DIR)/system/$(OS)
DESTBIN        := $(DESTDIR)/bin
NM_BIN         := $(PWD)/node_modules/.bin

DEP := vendor

NODE_VERSION := 6.11.1
NODE         := nodejs-$(NODE_VERSION)
NODE_BIN     := $(DESTBIN)/node
NPM_BIN      := $(DESTBIN)/npm

NPM_REGISTRY := http://npm.dev.s-cloud.net

export PATH := $(DESTBIN):$(NM_BIN):$(PATH)

.PHONY: build sc-vendor-libs test run publish dirs clean sc-vendor-libs

node_modules: $(NPM_BIN) package.json
	$(NPM_BIN) install
	@touch $@

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
	echo $(NODE_BIN)
	echo $(NPM_BIN)

clean:
	rm -rf $(NODE_MODULES) $(BUILD_DIR)/* sdk.js $(DEP)

vendor/audiomanager.js:
	$(NPM_BIN) install @sc/audiomanager --registry=$(NPM_REGISTRY)
	cp $(NODE_MODULES)/@sc/audiomanager/build/audiomanager.min.js vendor/audiomanager.js

vendor/scaudio.js:
	$(NPM_BIN) install @sc/scaudio --registry=$(NPM_REGISTRY)
	cp $(NODE_MODULES)/@sc/scaudio/scaudio.min.js vendor/scaudio.js

sc-vendor-libs: vendor/audiomanager.js vendor/scaudio.js

$(NPM_BIN): $(DESTDIR)/usr/lib/$(NODE)/bin/node
	@mkdir -p $(@D)
	ln -sf $(DESTDIR)/usr/lib/$(NODE)/bin/npm $@
	@touch $@

$(NODE_BIN): $(DESTDIR)/usr/lib/$(NODE)/bin/node
	@mkdir -p $(@D)
	ln -sf $< $@
	@touch $@

$(DESTDIR)/usr/lib/$(NODE)/bin/node: $(DEP)/node/$(OS)/$(NODE_VERSION).tar.gz
	@mkdir -p $(@D)
	tar xz -C $(DESTDIR)/usr/lib/$(NODE) --strip-components 1 -f $<
	@touch $@

$(DEP)/node/$(OS)/$(NODE_VERSION).tar.gz:
	http_proxy=$(PROXY) curl -q --create-dirs --fail --location https://nodejs.org/dist/v$(NODE_VERSION)/node-v$(NODE_VERSION)-linux-x64.tar.xz --output $@
	@touch $@
