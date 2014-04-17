VERSION_HTML=lib/component/version
VERSION=$(shell git describe --always --dirty=+)
RESOURCE_DIR_PATH=web lib
RESOURCE_DIR = $(foreach dir,$(shell find $(RESOURCE_DIR_PATH) -type d),$(dir))
RESOURCE_DIR_FOR_BUILD = web web/view web/packages/timecard_client/component
RESOURCE_SUFFIX_FOR_BUILD = html css


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

YAML = $(shell find chrome-apps -type f -name "[^.]*.yaml")
JSON = $(YAML:.yaml=.json)
.SUFFIXES: .yaml .json
.yaml.json:
	cat $< |python -c "import json,yaml,sys; print(json.dumps(yaml.load(sys.stdin.read()), indent=2))" > $@

RESOURCE = $(HTML) $(CSS) $(MINCSS)
all: submodule/dart_timecard_dev_api_client $(RESOURCE) $(VERSION_HTML)

RESOURCE_FOR_BUILD = $(foreach suffix,$(RESOURCE_SUFFIX_FOR_BUILD),$(foreach dir,$(RESOURCE_DIR_FOR_BUILD),$(wildcard $(dir)/*.$(suffix))))
BUILD_RESOURCE = $(addprefix build/,$(RESOURCE_FOR_BUILD))
build/%: %
	@mkdir -p $(dir $@)
	cp $< $@

DART = $(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.dart))
DART_JS = build/web/main.dart.js
$(DART_JS): $(DART)
	pub build --mode=debug

submodule/dart_timecard_dev_api_client:
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i timecard-dev.discovery -o submodule

pubserve: all
	pub serve --port 8081 --no-dart2js --force-poll

build: submodule/dart_timecard_dev_api_client $(BUILD_RESOURCE) $(DART_JS)

buildserve: build
	cd build/web; python -m SimpleHTTPServer 8081

RELEASE_DIR=build/chrome-apps
$(RELEASE_DIR):
	mkdir -p $(RELEASE_DIR)

$(RELEASE_DIR)/manifest.json: chrome-apps/manifest.json
	cp $< $@
$(RELEASE_DIR)/js/browser_dart_csp_safe.js: chrome-apps/js/browser_dart_csp_safe.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/js/main.js: chrome-apps/js/main.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/index.html: build/web/timecard.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/shadow_dom/shadow_dom.min.js: build/web/packages/shadow_dom/shadow_dom.debug.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/main.dart: build/web/main.dart
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/browser/dart.js: build/web/packages/browser/dart.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/browser/interop.js: build/web/packages/browser/interop.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/chrome/bootstrap.js: build/web/packages/chrome/bootstrap.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/main.dart.js: build/web/main.dart.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/main.dart.precompiled.js: build/web/main.dart.precompiled.js
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/timecard_client/component/nav.html: build/web/packages/timecard_client/component/nav.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/timecard_client/component/footer.html: build/web/packages/timecard_client/component/footer.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/timecard_client/component/version: build/web/packages/timecard_client/component/version
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/view/top.html: build/web/view/top.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/timecard_client/component/feedback_link.html: build/web/packages/timecard_client/component/feedback_link.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/timecard_client/component/feedback_form.html: build/web/packages/timecard_client/component/feedback_form.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/packages/angular_ui/modal/window.html: build/web/packages/angular_ui/modal/window.html
	mkdir -p $(dir $@)
	cp $< $@
$(RELEASE_DIR)/bootstrap-3.1.1: build/web/bootstrap-3.1.1
	cp -r $< $@

RELEASE_RESOURCE = $(addprefix $(RELEASE_DIR)/,manifest.json js/browser_dart_csp_safe.js js/main.js index.html packages/shadow_dom/shadow_dom.min.js main.dart packages/browser/dart.js packages/browser/interop.js packages/chrome/bootstrap.js main.dart.js main.dart.precompiled.js packages/timecard_client/component/nav.html packages/timecard_client/component/footer.html packages/timecard_client/component/version view/top.html packages/timecard_client/component/feedback_link.html packages/timecard_client/component/feedback_form.html packages/angular_ui/modal/window.html bootstrap-3.1.1)

release_build:
	pub build

release: submodule/dart_timecard_dev_api_client $(RESOURCE) $(RELEASE_DIR) $(RELEASE_RESOURCE)

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
