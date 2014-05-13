.SUFFIXES: .haml .html
.haml.html:
	haml -f html5 -t ugly $< $@

.SUFFIXES: .sass .css
.sass.css:
	compass compile $< -c $(CSS_DIR)/config.rb

.SUFFIXES: .sass .min.css
.sass.min.css:
	compass compile --environment production $< -c $(CSS_DIR)/config.rb
	mv $*.css $@

.SUFFIXES: .yaml .json
.yaml.json:
	cat $< |python -c "import json,yaml,sys; print(json.dumps(yaml.load(sys.stdin.read()), indent=2))" > $@


CORDOVA_DIR=cordova
CORDOVA_IOS=$(CORDOVA_DIR)/ios
all: chrome-apps $(CORDOVA_IOS)


ENDPOINTS_LIB=submodule/dart_timecard_dev_api_client
RESOURCE_DIR_PATH=web lib
RESOURCE_DIR=$(foreach dir,$(shell find $(RESOURCE_DIR_PATH) -type d),$(dir))
HAML=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.haml))
HTML=$(HAML:.haml=.html)
SASS=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.sass))
CSS=$(SASS:.sass=.css)
MINCSS=$(SASS:.sass=.min.css)
YAML=$(shell find web -type f -name "[^.]*.yaml")
JSON=$(YAML:.yaml=.json)
RESOURCE=$(HTML) $(CSS) $(MINCSS) $(JSON)
VERSION_HTML=lib/component/version
pubserve: $(ENDPOINTS_LIB) $(RESOURCE) $(VERSION_HTML)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js --force-poll

$(ENDPOINTS_LIB):
	cd submodule/discovery_api_dart_client_generator; pub install
	submodule/discovery_api_dart_client_generator/bin/generate.dart --no-prefix -i timecard-dev.discovery -o submodule

VERSION=$(shell git describe --always --dirty=+)
$(VERSION_HTML):
	@if [ "$(VERSION)" != "$(strip $(shell [ -f $@ ] && cat $@))" ] ; then\
		echo 'echo $(VERSION) > $@' ;\
		echo $(VERSION) > $@ ;\
	fi;


chrome-apps: $(VERSION_HTML) $(DART_JS) $(CHROME_APPS_DIR) $(RELEASE_RESOURCE_DST)

BUILD_DIR=build
DART_JS=$(BUILD_DIR)/web/main.dart.precompiled.js
DART=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.dart))
$(DART_JS): $(DART)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub build --mode=debug

CHROME_APPS_DIR=$(BUILD_DIR)/chrome-apps
$(CHROME_APPS_DIR):
	mkdir -p $@

RELEASE_RESOURCE_DST=$(foreach path,$(RELEASE_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(CHROME_APPS_DIR),$(path)))
RELEASE_RESOURCE_SRC=$(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(RELEASE_RESOURCE))
RELEASE_RESOURCE_SRC_DIR = $(BUILD_DIR)/web
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

$(RELEASE_RESOURCE_DST): $(RELEASE_RESOURCE_SRC)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(CHROME_APPS_DIR),$(RELEASE_RESOURCE_SRC_DIR),$@) $@


ios-sim: $(CORDOVA_IOS)
	cd $<; cca emulate $@

BUILD_RESOURCE=$(addprefix $(BUILD_DIR)/,$(RESOURCE_FOR_BUILD))
RESOURCE_FOR_BUILD=$(foreach suffix,$(RESOURCE_SUFFIX_FOR_BUILD),$(foreach dir,$(RESOURCE_DIR_FOR_BUILD),$(wildcard $(dir)/*.$(suffix))))
RESOURCE_SUFFIX_FOR_BUILD=html css json js
RESOURCE_DIR_FOR_BUILD=web web/js web/view web/packages/timecard_client/component web/packages/timecard_client/routing web/packages/timecard_client/service
$(CORDOVA_IOS): $(ENDPOINTS_LIB) $(RESOURCE) $(VERSION_HTML) $(YAML) $(DART_JS) $(BUILD_RESOURCE) $(RELEASE_RESOURCE_DST) $(CHROME_APPS_DIR) $(RELEASE_RESOURCE_DIR) $(CORDOVA_DIR)
	if [ -d $@ ]; then\
		cd $@; cca prepare;\
	else\
		cca create $@ --link-to=$(CHROME_APPS_DIR)/manifest.json;\
	fi;

$(CORDOVA_DIR):
	mkdir $@

$(BUILD_DIR)/%: %
	@mkdir -p $(dir $@)
	cp $< $@

RELEASE_RESOURCE_DIR=$(addprefix $(CHROME_APPS_DIR)/,bootstrap-3.1.1)
$(RELEASE_RESOURCE_DIR): $(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,bootstrap-3.1.1)
	cp -r $< $@


xcode: $(CORDOVA_IOS)
	open $</platforms/ios/Timecard.xcodeproj


clean:
	find . -type d -name .sass-cache |xargs rm -rf
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	rm -f $(RESOURCE) $(VERSION_HTML)
	rm -rf $(BUILD_DIR) $(CORDOVA_DIR)
	-patch -p1 --forward --reverse -i pubbuild.patch
	rm -f pubspec.yaml.rej

clean-all: clean
	rm -f pubspec.lock
	rm -rf $(ENDPOINTS_LIB) packages
	find . -name packages -type l -delete

.PHONY: $(VERSION_HTML) $(CORDOVA_IOS)
