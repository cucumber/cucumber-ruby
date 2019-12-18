Then("all IDs in the message output should be UUIDs") do
  ids = find_all_ids_in_ndjson(all_stdout)
  not_uuids = {}

  ids.each do |key, value|
    next if value.match(/[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/)
    not_uuids[key] = value
  end

  expect(not_uuids).to be_empty, "All ids are not UUIDs, found:\n#{not_uuids.map{ |path, id| " - #{id} => #{path}" }.join("\n")}\n"
end

Then("all IDs in the message output should be incremental") do
  ids = find_all_ids_in_ndjson(all_stdout)
  expected_ids = Array(0..ids.length-1).map(&:to_s)

  expect(ids.values.sort).to eq(expected_ids), "All ids are not incremental, found:\n#{ids.map {|path, id| " - #{id} => #{path}" }.join("\n")}\n"
end

def find_all_ids_in_ndjson(ndjson)
  ids = {}
  ndjson.split("\n").each do |line|
    message = JSON.parse(line)
    ids.merge!(IdFinder.new.find_ids(message))
  end
  ids
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