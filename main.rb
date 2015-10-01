require './util_array'

class RealTimeAnomaly
  attr_accessor :time_series, :factor, :strict_mode, :data,
                :current_trending

  def initialize(factor: 0.1, strict: true, data:)
    @data = data
    @factor = factor
    @strict_mode = strict
    @time_series = data
    @min_size = 50
    @current_trending = nil
  end

  def analyze(datapoint)
    puts "DATAPOINT: #{datapoint}"
    history = query(datapoint)

    # multi returns the prob whether datapoint is anomaly
    multi = div3sigma(history[1])
    puts "MULTI: #{multi.inspect}"

    @current_trending = trend(history[0], multi)
    puts "TREND: #{@current_trending.round(4)}"
    puts

    if multi.abs > 1
      puts "Anomaly detected!: #{multi.abs}"
      puts
    end
  end

  # get history of datapoint
  # current - history < abs(offset * periodicity)
  def query(datapoint)
    time, data = datapoint

    offset = 0.01
    period = 86400
    expire = 432000
    span = offset * period
    now = time

    reqs = []
    while((now-time) < expire)
      start = time - span
      stop = time + span
      @time_series.each do |t|
        reqs.push(t) if t[0] >= start && t[0] <= stop
      end
      time -= period
    end

    trend = @current_trending

    series = reqs.reverse.each_with_object([]){|obj, arr|
      arr << obj[1]
    }

    series.push(data)

    return [trend, series]
  end

  def div3sigma(series)
    return 0 if series.size < @min_size

    if @strict_mode
      tail = series.last
    else
      tail = UtilArray.new(series.slice(-3..-1)).mean
    end

    arr = UtilArray.new(series)
    mean = arr.mean
    std = arr.std

    if (std == 0)
      (tail-mean) == 0 ? 0 : 1
    end

    (tail-mean) / (3*std)
  end

  # uses weighted moving average wma
  # https://en.wikipedia.org/wiki/Moving_average
  def trend(last, data)
    return data if (last.nil? || last.to_f.nan?)
    last * (1-@factor) + (factor * data)
  end
end

# we are hardcoding this for now but will be stored externally such as
# redis or ssdb or from a log file
historic_data = [72, 75, 75, 73, 74, 71, 69, 69, 71, 69, 70, 70, 70, 72, 72, 73, 70, 72, 72, 70, 68, 68, 68, 70, 72, 72, 73, 75, 72, 73, 71, 72, 70, 70, 71, 72, 74, 72, 72, 72, 72, 74, 71, 71, 73, 72, 73, 70, 70, 70]

data = (1..historic_data.size).each_with_object([]){|t,arr|
  arr << [Time.now.to_i + t, historic_data[t-1]]
}

rt = RealTimeAnomaly.new(data: data)
rt.analyze([Time.now.to_i+historic_data.size+1, 75])

historic_data2=[71,70,71,71,71,72,70,73,73,72,72,74,71,72,71,71,72,73,74,73,74,73,73,74,74,73,73,74,74,72,74,73,74,73,74,74,72,72,70,69,69,70,70,70,72,73,73,74,71,70,71,73,73,74,72,72,70,70,70,71,70,70,72,72,73,74,74,74,73,76,75,74,74,75]


data = (1..historic_data2.size).each_with_object([]){|t,arr|
  arr << [Time.now.to_i + t, historic_data2[t-1]]
}

rt.data = data

rt.analyze([Time.now.to_i+historic_data2.size+1, 76])

historic_data3=[74,75,73,73,72,71,69,71,71,70,71,71,71,72,73,73,74,74,74,72,72,72,71,71,72,72,72,71,74,74,73,74,73,75,74,74,75,74,75,76,71,71,71,72,72,68,68,70,70,73,74,74,74,73,73,72,72,71,72,71,71,73,77,77,73,71,71,70,71,72,71,72,70,71,74,72,74,75,75,73,72,72,71,71,66,67,66,69,70,69,69,70,73,70,70,70,72,70,71,73,73,71]

data = (1..historic_data3.size).each_with_object([]){|t,arr|
  arr << [Time.now.to_i + t, historic_data3[t-1]]
}

rt.data = data

rt.analyze([Time.now.to_i+historic_data3.size+1, 660])
