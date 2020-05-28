ParameterType(
  name: 'list',
  regexp: /.*/,
  transformer: ->(s) { s.split(/,\s+/) },
  use_for_snippets: false
)

class ExecutionStatus
  def initialize(name)
    @passed = name == 'pass'
  end

  def validates?(exit_code)
    @passed ? exit_code.zero? : exit_code.positive?
  end
end

ParameterType(
  name: 'status',
  regexp: /pass|fail/,
  transformer: ->(s) { ExecutionStatus.new(s) }
)
