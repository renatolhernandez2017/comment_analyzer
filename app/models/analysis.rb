class Analysis < ApplicationRecord
  belongs_to :user

  def self.median(arr)
    return 0 if arr.empty? || (arr.first.nil? || arr.last.nil?)

    sorted = arr.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  def self.std_dev(arr)
    arr = arr.compact.map(&:to_f)

    return 0 if arr.empty? || (arr.first.nil? || arr.last.nil?)

    m = mean(arr)
    Math.sqrt(arr.map { |x| (x - m)**2 }.sum / arr.size)
  end

  def self.mean(arr)
    arr = arr.compact.map(&:to_f)

    return 0 if arr.empty? || (arr.first.nil? || arr.last.nil?) || arr.sum <= 0

    arr.sum / arr.size
  end
end
