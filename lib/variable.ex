defmodule Flex.Variable do
  alias Flex.Variable

  defstruct tag: nil,
            fuzzy_sets: nil,
            mf_values: %{},
            range: nil,
            tmp: nil,
            type: nil

  def new(params) do
    tag = Keyword.fetch!(params, :tag)
    range = Keyword.fetch!(params, :range)
    fuzzy_sets = Keyword.fetch!(params, :fuzzy_sets)
    type = Keyword.fetch!(params, :type)
    %Variable{range: range, fuzzy_sets: fuzzy_sets, type: type, tag: tag}
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

  @spec defuzzification(any(), any()) :: :error | Flex.Variable.t()
  def defuzzification(%Variable{type: type} = fuzzy_var) when type == :consequent do
    fuzzy_to_crisp(fuzzy_var.fuzzy_sets, fuzzy_var.tmp, 0, 0)
  end

  def defuzzification(_fuzzy_var, _input), do: :error

  defp fuzzy_to_crisp([], _input, nom, den), do: nom / den

  defp fuzzy_to_crisp([fs | f_tail], [input | i_tail], nom, den) do
    nom = nom + fs.mf_center * input
    den = den + input
    fuzzy_to_crisp(f_tail, i_tail, nom, den)
  end
end
