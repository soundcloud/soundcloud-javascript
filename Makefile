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

export PATH := $(DESTBIN):$(NM_BIN):$(PATH)

.PHONY: build

build: $(NODE_BIN)
	$(NPM_BIN) install
	$(NPM_BIN) run build

test: build
	$(NPM_BIN) run test

run: build
	$(NPM_BIN) run serve

publish: test
	IS_NPM=1 $(NPM_BIN) run build
	$(NPM_BIN) publish

dirs:
	echo $(DESTDIR)
	echo $(DESTBIN)
	echo $(NPM_BIN)

clean:
	rm -rf $(NODE_MODULES) $(BUILD_DIR)/* $(TMP) sdk.js

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


