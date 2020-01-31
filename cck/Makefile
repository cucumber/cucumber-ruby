MONOREPO_PATH ?= ../../../cucumber

# https://stackoverflow.com/questions/2483182/recursive-wildcards-in-gnu-make
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CCK_FEATURES=$(call rwildcard,$(MONOREPO_PATH)/compatibility-kit/javascript/features,*.feature)
FEATURES=$(patsubst $(MONOREPO_PATH)/compatibility-kit/javascript/%,%,$(CCK_FEATURES))
NDJSON=$(patsubst %.feature,%.ndjson,$(FEATURES))
SPEC=$(patsubst %.feature,%_spec.rb,$(FEATURES))
RUBY_FILES=$(call rwildcard,../lib,*.rb)

default: tested

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
	-rm Gemfile.lock **/*.feature **/*.ndjson **/*_spec.rb
