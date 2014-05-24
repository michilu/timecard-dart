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


RELEASE_DIR=release
RELEASE_IOS=$(RELEASE_DIR)/ios
all: chrome-apps $(RELEASE_IOS)


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

resource: $(RESOURCE) $(VERSION_HTML)


pubserve: $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE)
	-patch -p1 --forward --reverse -i pubbuild.patch
	pub serve --port 8080 --no-dart2js

pubserve-force-poll: $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE)
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


RELEASE_RESOURCE=\
	index.html\
	js/browser_dart_csp_safe.js\
	js/main.js\
	js/app.js\
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
	templates/browse.html\
	templates/menu.html\
	templates/playlist.html\
	templates/playlists.html\
	templates/search.html\

RELEASE_CHROME_APPS=$(RELEASE_DIR)/chrome-apps
RELEASE_RESOURCE_DIR=ionic
RELEASE_CHROME_APPS_RESOURCE_DIR=$(addprefix $(RELEASE_CHROME_APPS)/,$(RELEASE_RESOURCE_DIR))
BUILD_DIR=build
RELEASE_RESOURCE_SRC_DIR=$(BUILD_DIR)/web
RELEASE_RESOURCE_SRC=$(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(RELEASE_RESOURCE))
RELEASE_CHROME_APPS_RESOURCE_DST=$(foreach path,$(RELEASE_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_CHROME_APPS),$(path)))
CHROME_APPS_DART_JS=chrome-apps-dart-js
chrome-apps: $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE) $(RELEASE_CHROME_APPS) $(CHROME_APPS_DART_JS) $(RELEASE_CHROME_APPS_RESOURCE_DST)
	make $(RELEASE_CHROME_APPS_RESOURCE_DIR)
	@if [ $(DART_JS) -nt $(RELEASE_CHROME_APPS)/main.dart.precompiled.js ]; then\
		echo "cp $(DART_JS) $(RELEASE_CHROME_APPS)/main.dart.precompiled.js";\
		cp $(DART_JS) $(RELEASE_CHROME_APPS)/main.dart.precompiled.js;\
	fi;

$(RELEASE_CHROME_APPS): $(RELEASE_DIR)
	mkdir -p $@

$(RELEASE_DIR):
	mkdir $@

DART_JS=$(BUILD_DIR)/web/main.dart.precompiled.js
$(CHROME_APPS_DART_JS):
	-patch -p1 --forward --reverse -i pubbuild.patch
	make $(DART_JS)

$(RELEASE_CHROME_APPS_RESOURCE_DST): $(RELEASE_RESOURCE_SRC) $(CHROME_APPS_DART_JS)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(RELEASE_CHROME_APPS),$(RELEASE_RESOURCE_SRC_DIR),$@) $@

$(RELEASE_DIR)/%: %
	@mkdir -p $(dir $@)
	@if [ -d $< ]; then\
		echo "cp -r $< $@";\
		cp -r $< $@;\
	else\
		if [ $< -nt $@ ]; then\
		  echo "cp $< $@";\
		  cp $< $@;\
		fi;\
	fi;

DART=$(foreach dir,$(RESOURCE_DIR),$(wildcard $(dir)/*.dart))
$(DART_JS): pubspec.yaml $(DART)
	pub build --mode=debug

$(RELEASE_CHROME_APPS_RESOURCE_DIR): $(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(RELEASE_RESOURCE_DIR))
	cp -r $< $@


ios: $(RELEASE_IOS)
	cd $<; cca run ios

ios-sim: $(RELEASE_IOS)
	cd $<; cca emulate ios


RESOURCE_SUFFIX_FOR_BUILD = html css json js
RESOURCE_DIR_FOR_BUILD = web web/js web/view web/packages/timecard_client/component web/packages/timecard_client/routing web/packages/timecard_client/service
RESOURCE_FOR_BUILD = $(foreach suffix,$(RESOURCE_SUFFIX_FOR_BUILD),$(foreach dir,$(RESOURCE_DIR_FOR_BUILD),$(wildcard $(dir)/*.$(suffix))))
BUILD_RESOURCE = $(addprefix build/,$(RESOURCE_FOR_BUILD))
RELEASE_CORDOVA=$(RELEASE_DIR)/cordova
RELEASE_CORDOVA_RESOURCE_DIR=$(addprefix $(RELEASE_CORDOVA)/,$(RELEASE_RESOURCE_DIR))
RELEASE_CORDOVA_RESOURCE_DST=$(foreach path,$(RELEASE_RESOURCE_SRC),$(subst $(RELEASE_RESOURCE_SRC_DIR),$(RELEASE_CORDOVA),$(path)))
CORDOVA_DART_JS=cordova-dart-js
IONIC_PLUGINS_KEYBOARD=submodule/ionic-plugins-keyboard
$(RELEASE_IOS): $(VERSION_HTML) $(ENDPOINTS_LIB) $(RESOURCE) $(BUILD_RESOURCE) $(RELEASE_CORDOVA) $(CORDOVA_DART_JS) $(RELEASE_CORDOVA_RESOURCE_DST)
	make $(RELEASE_CORDOVA_RESOURCE_DIR)
	@if [ $(DART_JS) -nt $(RELEASE_CORDOVA)/main.dart.precompiled.js ]; then\
		echo "cp $(DART_JS) $(RELEASE_CORDOVA)/main.dart.precompiled.js";\
		cp $(DART_JS) $(RELEASE_CORDOVA)/main.dart.precompiled.js;\
	fi;
	@if ! (cd $@ && cca prepare); then\
		echo "rm -rf $@";\
		rm -rf $@;\
		echo "cca create $@ --link-to=$(RELEASE_CORDOVA)/manifest.json";\
		cca create $@ --link-to=$(RELEASE_CORDOVA)/manifest.json;\
		echo "git checkout release/ios/config.xml";\
		git checkout release/ios/config.xml;\
		echo "cd $@; cca plugin add ../../$(IONIC_PLUGINS_KEYBOARD)";\
		cd $@; cca plugin add ../../$(IONIC_PLUGINS_KEYBOARD);\
	fi;

build/%: %
	@mkdir -p $(dir $@)
	cp $< $@

$(RELEASE_CORDOVA): $(RELEASE_DIR)
	mkdir -p $@

$(CORDOVA_DART_JS):
	-patch -p1 --forward -i pubbuild.patch
	make $(DART_JS)

$(RELEASE_CORDOVA_RESOURCE_DST): $(RELEASE_RESOURCE_SRC) $(CORDOVA_DART_JS)
	@if [ ! -d $(dir $@) ]; then\
		mkdir -p $(dir $@);\
	fi;
	cp $(subst $(RELEASE_CORDOVA),$(RELEASE_RESOURCE_SRC_DIR),$@) $@

$(RELEASE_CORDOVA_RESOURCE_DIR): $(addprefix $(RELEASE_RESOURCE_SRC_DIR)/,$(RELEASE_RESOURCE_DIR))
	cp -r $< $@


xcode: $(RELEASE_IOS)
	open $</platforms/ios/Timecard.xcodeproj


clean:
	rm -f $(VERSION_HTML) $(RESOURCE)
	rm -rf $(BUILD_DIR) $(RELEASE_DIR)
	git checkout release/ios/config.xml
	-patch -p1 --forward --reverse -i pubbuild.patch

clean-all: clean
	rm -f pubspec.lock
	rm -f pubspec.yaml.rej
	rm -rf $(ENDPOINTS_LIB) packages
	find . -name "*.sw?" -delete
	find . -name .DS_Store -delete
	find . -name packages -type l -delete
	find . -type d -name .sass-cache |xargs rm -rf

.PHONY: $(VERSION_HTML) $(RELEASE_IOS)
