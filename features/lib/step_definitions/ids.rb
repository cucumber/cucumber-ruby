Then("all IDs in the message output should be UUIDs") do
  all_stdout.split("\n").each do |line|
    message = JSON.parse(line)
    IdFinder.new.find_ids(message).each do |key, id|
      expect(id).to match(/[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/), "Id for #{key} is not a UID, got #{id}"
    end
  end
end

Then("all IDs in the message output should be incremental") do
  ids = {}
  all_stdout.split("\n").each do |line|
    message = JSON.parse(line)
    ids.merge!(IdFinder.new.find_ids(message))
  end

  expect(ids.values.map(&:to_i).sort).to eq(Array(0..ids.length-1))
end

class IdFinder
  def initialize
    @path = []
    @ids = {}
  end

  def find_ids(data)
    walk_hash(data)
    @ids
  end

  private

  def walk_hash(h)
    h.each do |key, value|
      @path << key
      walk_item(key, value)
      @path.pop
    end
  end

  def walk_array(a)
    a.each_with_index do |item, index|
      @path << index.to_s
      walk_item(nil, item)
      @path.pop
    end
  end

  def walk_item(key, value)
    if value.is_a? String
      @ids[@path.join('/')] = value if key =='id'
    elsif value.is_a? Array
      walk_array(value)
    elsif value.is_a? Hash
      walk_hash(value)
    end
  end
end