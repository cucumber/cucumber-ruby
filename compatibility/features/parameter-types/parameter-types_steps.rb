# frozen_string_literal: true

class Flight
  attr_reader :from, :to

  def initialize(from, to)
    @from = from
    @to = to
  end
end

ParameterType(
  name: 'flight',
  regexp: /([A-Z]{3})-([A-Z]{3})/,
  transformer: ->(from, to) { Flight.new(from, to) }
)

Given('{flight} has been delayed') do |flight|
  expect(flight.from).to eq('LHR')
  expect(flight.to).to eq('CDG')
end
