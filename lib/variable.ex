defmodule Flex.Variable do
  alias Flex.Variable

  defstruct fuzzy_sets: nil,
            mf_values: nil,
            range: nil,
            type: nil

  def new(params) do
    range = Keyword.fetch!(params, :range)
    fuzzy_sets = Keyword.fetch!(params, :fuzzy_sets)
    type = Keyword.fetch!(params, :type)
    %Variable{range: range, fuzzy_sets: fuzzy_sets, type: type}
  end

  def fuzzification(%Variable{type: type} = fuzzy_var, input) when type == :antecedent do
    res = map_all_mf(fuzzy_var.fuzzy_sets, input, %{})
    %{fuzzy_var | mf_values: res}
  end

  def fuzzification(_fuzzy_var, _input), do: :error

  defp map_all_mf([], _input, acc), do: acc
  defp map_all_mf([fs | tail], input, acc) do
    mu = fs.mf.(input)
    key = fs.tag
    acc = Map.put(acc, key, mu)
    map_all_mf(tail, input, acc)
  end

  def defuzzification(%Variable{type: type} = fuzzy_var, input) when type == :consequent do
    res = fuzzy_to_crisp(fuzzy_var.fuzzy_sets, input, 0, 0)
    %{fuzzy_var | mf_values: res}
  end

  def defuzzification(_fuzzy_var, _input), do: :error

  defp fuzzy_to_crisp([], _input, nom, den), do: nom/den
  defp fuzzy_to_crisp([fs | f_tail], [input | i_tail], nom, den) do
    nom = nom + (fs.mf_center * input)
    den = den + input
    fuzzy_to_crisp(f_tail, i_tail, nom, den)
  end
end
