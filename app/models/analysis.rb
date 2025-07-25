class Analysis < ApplicationRecord
  belongs_to :user

  def self.median(arr)
    arr = Array(arr).compact
    return 0 if arr.empty?

    sorted = arr.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end

  def self.std_dev(arr)
    arr = Array(arr).compact.map(&:to_f)
    return 0 if arr.empty?

    m = mean(arr)
    Math.sqrt(arr.map { |x| (x - m)**2 }.sum / arr.size)
  end

  def self.mean(arr)
    arr = Array(arr).compact.map(&:to_f)

    return 0 if arr.empty? || arr.sum <= 0

    arr.sum / arr.size
  end
end
