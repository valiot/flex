defmodule Flex.Variable do
  alias Flex.Variable

  use Agent, restart: :permanent

  defstruct fuzzy_sets: nil,
            mf_value: nil,
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

  defp init(params) do
    range = begin..final = Keyword.fetch!(params, :range)
    fuzzy_sets = Keyword.fetch!(params, :fuzzy_sets)
    n_sets = Enum.count(fuzzy_sets)
    spacing = (final-begin)/n_sets
    #n_fuzzy_sets = generate_mf(fuzzy_sets, begin, final, spacing, [])
    #procesar fuzzy sets.
    %Variable{range: range, fuzzy_sets: fuzzy_sets}
  end

  # def automf([fs | tail], begin, spacing, acc) do
  #   nil
  # end
end
