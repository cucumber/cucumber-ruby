MONOREPO_PATH ?= ../../../cucumber

# https://stackoverflow.com/questions/2483182/recursive-wildcards-in-gnu-make
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CCK_FEATURES=$(call rwildcard,$(MONOREPO_PATH)/compatibility-kit/javascript/features,*.feature)
FEATURES=$(patsubst $(MONOREPO_PATH)/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))
SPEC=$(patsubst %.feature,%_spec.rb,$(FEATURES))
RUBY_FILES=$(call rwildcard,../lib ../../cucumber-ruby-core/lib/,*.rb)
JSONS=$(patsubst %.feature,%.json,$(FEATURES))
GOLDEN_JSONS=$(patsubst %.feature,%-golden.json,$(FEATURES))
SELF_TESTED = $(patsubst %.feature,%.json.tested,$(FEATURES))

default: tested self_tested json_reports html_reports

###############################################################################
#            Run features file and compare messages against CCK               #
###############################################################################

tested: $(SPEC) $(NDJSON)
	bundle exec rspec features/**/*_spec.rb
.PHONY: tested

%_spec.rb: %.ndjson templates/specs.rb
	cp templates/specs.rb $@

###############################################################################
#        Compare --format=json against --format=message | json-formatter      #
###############################################################################

self_tested: $(SELF_TESTED)

%.json.tested: %-golden.json %.json
	diff --unified $^

%.json: %.ndjson scripts/neutralize-json
	cat $< | "$(MONOREPO_PATH)/compatibility-kit/scripts/cucumber-json-formatter" | \
		jq --sort-keys "." | \
		scripts/neutralize-json > $@

%-golden.json: %.feature %_steps.rb Gemfile.lock $(RUBY_FILES) scripts/neutralize-json
	-bundle exec cucumber $< --require $(patsubst %-golden.json,%_steps.rb,$@) --format=json  | \
		jq --sort-keys "." | \
		scripts/neutralize-json > $@

###############################################################################
#                    Get features from CCK and run them                       #
###############################################################################

%.ndjson: %.feature %_steps.rb Gemfile.lock $(RUBY_FILES)
	-bundle exec cucumber $< --require $(patsubst %.ndjson,%_steps.rb,$@) --format=message > $@

Gemfile.lock: Gemfile
	bundle install

%.feature:
	mkdir -p $$(dirname $@)
	cp $(patsubst %,$(MONOREPO_PATH)/compatibility-kit/javascript/%,$@) $@

###############################################################################
#               Generate reports after execution against CCK                  #
###############################################################################

json_reports: $(NDJSON)
	mkdir -p output/json
	$(MONOREPO_PATH)/compatibility-kit/scripts/run-formatter \
                -e .json \
                -o output/json \
                -c "$(MONOREPO_PATH)/compatibility-kit/scripts/cucumber-json-formatter" \
                features/**/*.ndjson
.PHONY: json_reports

html_reports: $(NDJSON)
	mkdir -p output/html
	$(MONOREPO_PATH)/compatibility-kit/scripts/run-formatter \
                -e .html \
                -o output/html \
                -c "$(MONOREPO_PATH)/compatibility-kit/scripts/cucumber-html-formatter" \
                features/**/*.ndjson
.PHONY: html_reports


clean:
	-rm Gemfile.lock **/*.feature **/*.ndjson feature/**.json features/**/*_spec.rb output
.PHONY: clean