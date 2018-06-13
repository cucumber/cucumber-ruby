ParameterType(
  name: 'list',
  regexp: /.*/,
  transformer: ->(s) { s.split(/,\s+/) },
  use_for_snippets: false
)
