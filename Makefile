MONOREPO_PATH ?= ../../../cucumber

FEATURES = $(sort $(wildcard features/docs/**.feature))
GOLDEN_JSONS = $(patsubst features/docs/%.feature,acceptance/%-golden.json,$(FEATURES))
GENERATED_JSONS = $(patsubst features/docs/%.feature,acceptance/%-generated.json,$(FEATURES))
TESTED = $(patsubst features/docs/%.feature,acceptance/%.tested,$(FEATURES))

OS := $(shell [[ "$$(uname)" == "Darwin" ]] && echo "darwin" || echo "linux")
# Determine if we're on 386 or amd64 (ignoring other processors as we're not building on them)
ARCH := $(shell [[ "$$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "386")

default: $(GOLDEN_JSONS) $(GENERATED_JSONS) $(TESTED)
.PHONY: default

acceptance/%.tested: acceptance/%-golden.json acceptance/%-generated.json
	mkdir -p $$(dirname $@)
	diff --unified $^
.PHONY: acceptance/%.tested

acceptance/%-golden.json: features/docs/%.feature bin/neutralize-json
	mkdir -p $$(dirname $@)
	bundle exec cucumber --format=json $< | \
		jq --sort-keys "." | \
		bin/neutralize-json > $@

acceptance/%-generated.json: features/docs/%.feature bin/json-formatter bin/neutralize-json
	mkdir -p $$(dirname $@)
	bundle exec cucumber --format=message $< | \
		bin/json-formatter --format ndjson | \
		jq --sort-keys "." | \
		bin/neutralize-json > $@

bin/json-formatter:
	cp $(MONOREPO_PATH)/json-formatter/go/dist/cucumber-json-formatter-$(OS)-$(ARCH) $@
	chmod +x $@

bin/neutralize-json:
	cp $(MONOREPO_PATH)/json-formatter/ruby/neutralize-json $@
	chmod +x $@

clean:
	rm -rf acceptance bin/json-formatter bin/neutralize-json
.PHONY: clean