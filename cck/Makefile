MONOREPO_PATH ?= ../../../cucumber

# https://stackoverflow.com/questions/2483182/recursive-wildcards-in-gnu-make
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CCK_FEATURES=$(call rwildcard,$(MONOREPO_PATH)/compatibility-kit/javascript/features,*.feature)
FEATURES=$(patsubst $(MONOREPO_PATH)/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))
SPEC=$(patsubst %.feature,%_spec.rb,$(FEATURES))
RUBY_FILES=$(call rwildcard,../lib ../../cucumber-ruby-core/lib/,*.rb)


default: tested jsons htmls

jsons: $(NDJSON)
	mkdir -p output/json
	$(MONOREPO_PATH)/compatibility-kit/scripts/run-formatter \
                -e .json \
                -o output/json \
                -c "$(MONOREPO_PATH)/compatibility-kit/scripts/cucumber-json-formatter" \
                features/**/*.ndjson
.PHONY: jsons

htmls: $(NDJSON)
	mkdir -p output/html
	$(MONOREPO_PATH)/compatibility-kit/scripts/run-formatter \
                -e .html \
                -o output/html \
                -c "$(MONOREPO_PATH)/compatibility-kit/scripts/cucumber-html-formatter" \
                features/**/*.ndjson
.PHONY: htmls

tested: $(SPEC) $(NDJSON)
	bundle exec rspec features/**/*_spec.rb

%_spec.rb: %.ndjson templates/specs.rb
	cp templates/specs.rb $@

%.ndjson: %.feature %_steps.rb Gemfile.lock $(RUBY_FILES)
	-bundle exec cucumber $< --require $(patsubst %.ndjson,%_steps.rb,$@) --format=message > $@

Gemfile.lock: Gemfile
	bundle install

%.feature:
	mkdir -p $$(dirname $@)
	cp $(patsubst %,$(MONOREPO_PATH)/compatibility-kit/javascript/%,$@) $@

clean:
	-rm Gemfile.lock **/*.feature **/*.ndjson features/**/*_spec.rb output
.PHONY: clean