VERSION_HTML=lib/component/version
VERSION=$(shell git describe --always --dirty=+)
RESOURCE_DIR_PATH=web lib
RESOURCE_DIR = $(foreach dir,$(shell find $(RESOURCE_DIR_PATH) -type d),$(dir))
RESOURCE_DIR_FOR_BUILD = web web/js web/view web/packages/timecard_client/component web/packages/timecard_client/routing web/packages/timecard_client/service
RESOURCE_SUFFIX_FOR_BUILD = html css json js


.SUFFIXES: .haml .html
.haml.html:
	haml -f html5 -t ugly $< $@
HAML = $(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.haml))
HTML = $(HAML:.haml=.html)

.SUFFIXES: .sass .css
.sass.css:
	compass compile $< -c $(CSS_DIR)/config.rb
.SUFFIXES: .sass .min.css
.sass.min.css:
	compass compile --environment production $< -c $(CSS_DIR)/config.rb
	mv $*.css $@
SASS = $(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.sass))
CSS = $(SASS:.sass=.css)
MINCSS = $(SASS:.sass=.min.css)

YAML = $(shell find web -type f -name "[^.]*.yaml")
JSON = $(YAML:.yaml=.json)
.SUFFIXES: .yaml .json
.yaml.json:
	cat $< |python -c "import json,yaml,sys; print(json.dumps(yaml.load(sys.stdin.read()), indent=2))" > $@

RESOURCE = $(HTML) $(CSS) $(MINCSS) $(JSON)
all: submodule/dart_timecard_dev_api_client $(RESOURCE) $(VERSION_HTML)

RESOURCE_FOR_BUILD = $(foreach suffix,$(RESOURCE_SUFFIX_FOR_BUILD),$(foreach dir,$(RESOURCE_DIR_FOR_BUILD),$(wildcard $(dir)/*.$(suffix))))
BUILD_RESOURCE = $(addprefix build/,$(RESOURCE_FOR_BUILD))
build/%: %
	@mkdir -p $(dir $@)
	cp $< $@

DART = $(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.dart))
DART_JS = build/web/main.dart.precompiled.js
$(DART_JS): $(DART)
	pub build --mode=debug

submodule/dart_timecard_dev_api_client:
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i timecard-dev.discovery -o submodule

pubserve: all
	pub serve --port 8080 --no-dart2js --force-poll

build: submodule/dart_timecard_dev_api_client $(BUILD_RESOURCE) $(DART_JS)

buildserve: build
	cd build/web; python -m SimpleHTTPServer 8080

RELEASE_DIR=build/chrome-apps
$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

RELEASE_RESOURCE_SRC_DIR = build/web
RELEASE_RESOURCE = index.html main.dart.precompiled.js packages/shadow_dom/shadow_dom.min.js main.dart packages/browser/dart.js packages/browser/interop.js packages/chrome/bootstrap.js packages/timecard_client/component/version packages/angular_ui/modal/window.html
RELEASE_RESOURCE_WILDCARD = manifest*.json js/*.js view/*.html packages/timecard_client/component/*.html
RELEASE_RESOURCE_SRC_WILDCARD = $(foreach path,$(RELEASE_RESOURCE_WILDCARD),$(wildcard $(RELEASE_RESOURCE_SRC_DIR)/$(path)))
RELEASE_RESOURCE_SRC = $(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(RELEASE_RESOURCE)) $(RELEASE_RESOURCE_SRC_WILDCARD)
RELEASE_RESOURCE_DST = $(foreach path,$(RELEASE_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_DIR),$(path)))
$(RELEASE_RESOURCE_DST): $(RELEASE_RESOURCE_SRC)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(RELEASE_DIR),$(RELEASE_RESOURCE_SRC_DIR),$@) $@
RELEASE_RESOURCE_DIR = $(addprefix $(RELEASE_DIR)/,bootstrap-3.1.1)
$(RELEASE_RESOURCE_DIR): $(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,bootstrap-3.1.1)
	cp -r $< $@

release_build:
	pub build

cordova:
	mkdir cordova

cordova/ios: cordova build/chrome-apps/manifest.json
	cca create $@ --link-to=build/chrome-apps/manifest.json

release: $(RESOURCE) $(RELEASE_RESOURCE_DST) build $(RELEASE_DIR) $(RELEASE_RESOURCE_DIR) cordova/ios

ios: cordova/ios
	cd $<; cca emulate $@

xcode: cordova/ios
	open $</platforms/ios/Timecard.xcodeproj

clean:
	find . -type d -name .sass-cache |xargs rm -rf
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	rm -f $(CSS)
	rm -f $(HTML)
	rm -f $(MINCSS)

$(VERSION_HTML):
	@if [ "$(VERSION)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION) > $@' ;\
		echo $(VERSION) > $@ ;\
	fi;

.PHONY: all clean test build release_build $(VERSION_HTML)
