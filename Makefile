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
	-patch -p1 --forward -i pubbuild.patch
	pub build --mode=debug

submodule/dart_timecard_dev_api_client:
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i timecard-dev.discovery -o submodule

pubserve: all
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js --force-poll

build: submodule/dart_timecard_dev_api_client $(YAML) $(BUILD_RESOURCE) $(DART_JS)

buildserve: build
	cd build/web; python -m SimpleHTTPServer 8080

RELEASE_DIR=build/chrome-apps
$(RELEASE_DIR):
	mkdir -p $@

RELEASE_RESOURCE_SRC_DIR = build/web
RELEASE_RESOURCE =\
	index.html\
	js/browser_dart_csp_safe.js\
	js/main.js\
	main.dart.precompiled.js\
	main.dart\
	manifest.json\
	manifest.mobile.json\
	packages/angular_ui/modal/window.html\
	packages/browser/dart.js\
	packages/chrome/bootstrap.js\
	packages/shadow_dom/shadow_dom.min.js\
	packages/timecard_client/component/edit_user.html\
	packages/timecard_client/component/feedback_form.html\
	packages/timecard_client/component/feedback_link.html\
	packages/timecard_client/component/footer.html\
	packages/timecard_client/component/nav.html\
	packages/timecard_client/component/remember_me.html\
	packages/timecard_client/component/version\
	view/leave.html\
	view/logout.html\
	view/settings.html\
	view/signup.html\
	view/top.html\

RELEASE_RESOURCE_SRC = $(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(RELEASE_RESOURCE))
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
	-patch -p1 --forward -i pubbuild.patch
	pub build

cordova:
	mkdir cordova

cordova/ios: $(RESOURCE) $(RELEASE_RESOURCE_DST) build $(RELEASE_DIR) $(RELEASE_RESOURCE_DIR) cordova
	if [ -d $@ ]; then\
		cd $@; cca prepare;\
	else\
		cca create $@ --link-to=build/chrome-apps/manifest.json;\
	fi;

release: cordova/ios

ios: cordova/ios
	cd $<; cca emulate $@

xcode: cordova/ios
	open $</platforms/ios/Timecard.xcodeproj

clean:
	find . -type d -name .sass-cache |xargs rm -rf
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	rm -f $(RESOURCE)
	rm -rf build cordova
	-patch -p1 --forward --reverse -i pubbuild.patch
	rm -f pubspec.yaml.rej

$(VERSION_HTML):
	@if [ "$(VERSION)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION) > $@' ;\
		echo $(VERSION) > $@ ;\
	fi;

.PHONY: all clean test build release_build $(VERSION_HTML) cordova/ios
