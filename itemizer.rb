require 'byebug'

class Itemizer
  def initialize(collection)
    @collection = collection
  end

  def distribute(amount)
    sorted = @collection.sort { |item| item[:quantity] }.reverse

    distribute_amount_to(@collection.dup, amount)
  end

  private

  def total_quantity
    @collection.reduce(0) { |total, item| total + item[:quantity] }
  end

  def distribute_amount_to(collection, amount)
    distributed = collection.map do |item|
      item.tap { |it| it[:total] += proportion_of_amount(item, amount) }
    end

    difference = collection.reduce(amount) do |diff, item|
      diff - proportion_of_amount(item, amount)
    end

    adjust_by(distributed, difference)
  end

  def adjust_by(collection, amount)
    if amount.negative?
      decrease_by(collection, amount)
    else
      increase_by(collection, amount)
    end
  end

  def decrease_by(collection, amount)
    collection.sort_by { |item| item[:quantity] }.map do |item|
      next item if amount.zero?

      amount += 1
      item.tap { |it| it[:total] -= 1 }
    end
  end

  def increase_by(collection, amount)
    collection.sort_by { |item| item[:quantity] }.reverse.map do |item|
      next item if amount.zero?

      amount -= 1
      item.tap { |it| it[:total] += 1 }
    end
  end

  def proportion_of_amount(item, amount)
    (item[:quantity].to_f / total_quantity * amount).round
  end
end
