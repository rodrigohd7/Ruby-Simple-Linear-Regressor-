require 'csv'
require 'pry'

def cost_function(m, b, points)
  total_error = 0

  for i in 0..(points.length-1)
    total_error += (points[i][:y]-(m*points[i][:x])+b)**2
  end

  return total_error/points.length
end

def gradient_descent(points, init_m, init_b, learning_rate, iterations)
  m = init_m
  b = init_b
  error_history = []

  for i in 0..iterations
    m, b = step_gradient(m, b, points, learning_rate)
    error_history << cost_function(m, b, points)
  end

  return [m, b, error_history]
end

def step_gradient(m_current, b_current, points, learning_rate)
  m_gradient = 0
  b_gradient = 0
  n = points.length

  for i in 0..(n-1)
    b_gradient += -(2.0/n) * (points[i][:y] - (m_current * points[i][:x]) + b_current)
    m_gradient += -(2.0/n) * points[i][:x] * (points[i][:y] - (m_current * points[i][:x]) + b_current)
  end

  return [
    m_current - (learning_rate * m_gradient),
    b_current - (learning_rate * b_gradient)
   ]
end

def gnuplot(commands)
  IO.popen("gnuplot", "w") { |io| io.puts commands }
end

def plot_results(csv_path, m, b, errors)
  File.open("line.csv", "w") do |io|
    for i in 0..10
      io.write(i)
      io.write(",")
      io.write((m*i)+b)
      io.write("\r\n")
    end
  end

  File.open("error.csv", "w") do |io|
    for i in 0..errors.length
      io.write(i)
      io.write(",")
      io.write(errors[i])
      io.write("\r\n")
    end
  end

  commands = %Q(
    set datafile separator ','
    plot "#{csv_path}" using 1:2 with points title 'Experience', 'line.csv' using 1:2 with line title 'Regression'
    pause mouse '\r'
  )

  error_command = %Q(
    set datafile separator ','
    plot 'error.csv' using 1:2 with lines title 'Error'
    pause mouse '\r'
  )

  gnuplot(commands)
  gnuplot(error_command)

  File.delete("line.csv")
  File.delete("error.csv")
end

file = "salary_data.csv"

points = CSV.read(file)
points.shift(1)
points = points.collect{|point| {x: point[0].to_f, y: point[1].to_f}}

init_m = 0
init_b = 0

final_m, final_b, errors = gradient_descent(points, init_m, init_b, 0.0001, 1000)
plot_results(file, final_m, final_b, errors)