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

release: submodule/dart_timecard_dev_api_client $(RESOURCE)
	pub build

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

.PHONY: all clean test build $(VERSION_HTML)
