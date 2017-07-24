ParameterType(
  name: 'list',
  regexp: /.*/,
  type: Array,
  transformer: ->(s) { s.split(/,\s+/)},
  use_for_snippets: false,
  prefer_for_regexp_match: false
)
