defmodule Flex.Variable do
  alias Flex.{Variable}

  use Agent, restart: :permanent

  defstruct fuzzy_sets: nil,
            mf_values: nil,
            range: nil,
            type: nil

  def start_link(params, opts \\ []) do
    Agent.start_link(fn -> init(params) end, opts)
  end

  def stop(pid) do
    Agent.stop(pid)
  end

  def state(pid) do
    Agent.get(pid, fn state -> state end)
  end

  def fuzzification(input, pid) do
    Agent.update(pid, fn state ->
      res = _fuzzification(input, state.fuzzy_sets, %{})
      %{state | mf_values: res}
    end)
  end

  defp init(params) do
    range = Keyword.fetch!(params, :range)
    fuzzy_sets = Keyword.fetch!(params, :fuzzy_sets)
    type = Keyword.fetch!(params, :type)
    %Variable{range: range, fuzzy_sets: fuzzy_sets, type: type}
  end

  def _fuzzification(_input, [], acc), do: acc
  def _fuzzification(input, [fs | tail], acc) do
    mu = fs.mf.(input)
    key = fs.tag
    acc = Map.put(acc, key, mu)
    _fuzzification(input, tail, acc)
  end
end
