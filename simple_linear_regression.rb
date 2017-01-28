require 'csv'
require 'pry'

def cost_function(m, b, points)
  error = 0

  for i in 0..(points.length-1)
    x = points[i][0].to_f
    y = points[i][1].to_f
    error += (y-(m*x)+b)**2
  end

  return error/points.length
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

  for i in 0..(points.length-1)
    x = points[i][0].to_f
    y = points[i][1].to_f

    m_gradient += -(2.0/points.length) * x * (y-hypothesis(m_current,b_current,x))
    b_gradient += -(2.0/points.length) * (y-hypothesis(m_current,b_current,x))
  end

  return [
    m_current - (learning_rate * m_gradient),
    b_current - (learning_rate * b_gradient)
   ]
end

def hypothesis(m, b, x)
  (m*x)+b
end

def gnuplot(commands)
  IO.popen("gnuplot", "w") { |io| io.puts commands }
end

def plot_results(csv_path, m, b, errors)
  File.open("line.csv", "w") do |io|
    for i in 0..10
      io.write(i)
      io.write(",")
      io.write(hypothesis(m, b, i))
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
end

points = CSV.read("salary_data.csv")
points.shift(1)

init_m = 0
init_b = 0

final_m, final_b, errors = gradient_descent(points, init_m, init_b, 0.0001, 1000)
plot_results("salary_data.csv", final_m, final_b, errors)