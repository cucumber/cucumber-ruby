class Pantry

  def initialize
    @items = {}
  end

  def add(food_name, count)
    @items[food_name] ||= 0
    @items[food_name] += count
  end

  def remove(food_name, count)
    @items[food_name] -= count
  end

  def count(food_name)
    @items[food_name]
  end

end
