require 'byebug'

class Itemizer
  def initialize(collection)
    @collection = collection
  end

  def distribute(amount)
    sorted = @collection.sort { |item| item[:quantity] }.reverse

    distribute_amount_to(sorted, amount)
  end

  def total_quantity
    @collection.reduce(0) { |total, item| total + item[:quantity] }
  end

  private

  def distribute_amount_to(collection, amount)
    if one_to_each?(collection, amount)
      return distribute_remaining_to(collection, amount)
    end

    distributed = collection.map do |item|
      item.tap { |it| it[:total] += proportion_of_amount(item, amount) }
    end

    remaining = collection.reduce(amount) do |rem, item|
      rem - proportion_of_amount(item, amount)
    end

    distribute_amount_to(distributed, remaining)
  end

  def distribute_remaining_to(collection, remaining)
    collection.map do |item|
      next item if remaining.zero?

      remaining -= 1
      item.tap { |it| it[:total] += 1 }
    end
  end

  def one_to_each?(collection, amount)
    collection.all? do |item|
      proportion_of_amount(item, amount).zero?
    end
  end

  def proportion_of_amount(item, amount)
    (item[:quantity].to_f / total_quantity * amount).floor
  end
end
