ParameterType(
  name: 'list',
  regexp: /.*/,
  transformer: ->(s) { s.split(/,\s+/)}
)
