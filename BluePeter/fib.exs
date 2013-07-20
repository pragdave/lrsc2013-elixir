defmodule Sequence do 

  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(n-1) + fib(n-2)

  # Regular map 
  def map([], _fun), do: []
  def map([ head | tail ], fun), do: [ fun.(head) | map(tail, fun)]

  # Parallel map
  def pmap(collection, fun) do
    collection |> spawn_children(fun) |> collect_results
    #        values    --->          pids    ---->        values
  end

  defp spawn_children(collection, fun), do: collection |> map(spawn_child(&1, fun))

  def spawn_child(item, fun),   do: spawn(__MODULE__, :child, [item, fun, self])

  def child(item, fun, parent), do: parent <- { self, fun.(item) }

  defp collect_results(pids),   do: pids |> map(collect_result_for_pid(&1))

  defp collect_result_for_pid(pid) do
     receive do
      { ^pid, value } -> value
    end
  end
end


#####################################################

ExUnit.start

defmodule MyTest do
  use ExUnit.Case

  import Sequence

  test "basic fib works" do
    assert fib(10) == 55
    assert fib(30) == 832040
  end

  test "sequential map works" do
    assert map([0, 1,2,3,4,5], fib(&1)) == [0, 1, 1, 2, 3, 5]
  end

  test "parallel map works" do
    assert pmap([0, 1,2,3,4,5], fib(&1)) == [0, 1, 1, 2, 3, 5]
  end

end
