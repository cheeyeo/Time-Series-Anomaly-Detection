class UtilArray
  def initialize(array)
    @array = array
    @length = @array.length
  end

  def sum
    @array.inject(0){|accum, i| accum + i }
  end

  def mean
    self.sum / @length.to_f
  end

  def sample_variance
    m = self.mean
    sum = @array.inject(0){|accum, i| accum +(i-m)**2 }
    (1/@length.to_f*sum)
  end

  def std
    return Math.sqrt(self.sample_variance)
  end
end

# ut = UtilArray.new([1,2,3])

# puts ut.mean
# puts ut.std
