defmodule Future do
	def create(fun) do
		fun |> wrap |> spawn
	end

  def value(future) do
    future <- { :get_value, self }
    receive do
      { :future_value, result} -> result
    end
  end

	defp wrap(fun) do
		fn ->
      result = fun.()
      receive do
        { :get_value, pid } ->
          pid <- { :future_value, result }
      end
    end
  end
end

IO.puts "creating f1"
f1 = Future.create(fn -> IO.puts "in F1";  123 end)
IO.puts "creating f2"
f2 = Future.create(fn -> IO.puts "in F2";  321 end)
IO.puts "getting answer"
IO.puts Future.value(f1) + Future.value(f2)


defmodule Promise do

  def create do
    spawn(__MODULE__, :promise_keeper, [:nil, false])
  end

  def value(promise) do
    promise <- { :get_value, self }
    receive do
      { :future_value, result } -> result
    end
  end

  def deliver(promise, value) do
    promise <- { :set_value, value }  
    value
  end

  def promise_keeper(value, delivered) do

    receive do
      { :get_value, pid } when delivered ->
        pid <- { :future_value, value }
        promise_keeper(value, delivered)

      { :set_value, value } ->
        promise_keeper(value, true)

    end
  end

end


p1 = Promise.create
p2 = Promise.create

spawn(fn -> IO.puts "p1 value = #{Promise.value(p1)}" end)
spawn(fn -> IO.puts "p2 value = #{Promise.value(p2)}" end)

Promise.deliver(p2, "wombat")
Promise.deliver(p1, "12345")

:timer.sleep(100)

 
futures = Stream.iterate(function(Future.create/1))

Promise.deliver(Enum.at(promises, 0), 1)
Promise.deliver(Enum.at(promises, 1), 1)

def fib(promises, n) do


