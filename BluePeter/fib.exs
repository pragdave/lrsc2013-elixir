defmodule Sequence do 

  def fib(0), do: 1
  def fib(1), do: 1
  def fib(n), do: fib(n-1) + fib(n-2)

end

defmodule Parallel do
  def map(collection, fun) do
    me = self

    collection
    |> Enum.map(fn (elem) ->
         spawn_link fn -> (me <- { self, fun.(elem) }) end
       end)
    |> Enum.map(fn (pid) ->
         receive do { ^pid, result } -> result end
       end)
  end
end


IO.puts Sequence.fib(10)
IO.puts Sequence.fib(20)

40..30 |> Parallel.map(function(Sequence.fib/1)) |> IO.inspect