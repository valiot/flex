defmodule Flex.Variable do
  alias Flex.Variable

  @moduledoc """
  An interface to create Fuzzy Variables.
  """
  defstruct tag: nil,
            fuzzy_sets: nil,
            mf_values: %{},
            range: nil,
            tmp: nil,
            type: nil

  @typedoc """
  Fuzzy Variable struct.
  - `:tag` - (string) Defines the linguistic name of the fuzzy variable (e.g., "error").
  - `:fuzzy_sets` - (list) Defines which all the fuzzy sets related to the variable.
  - `:mf_values` - (map) The current values of each of the membership functions of the fuzzy sets.
  - `:range` - (range) The range in which the variable exists.
  - `:type` - (atom) :antecedent if the variable is an input or consequent for outputs.
  """
  @type t :: %__MODULE__{
          tag: String.t(),
          fuzzy_sets: [Flex.Set.t(), ...],
          mf_values: %{},
          range: any(),
          type: :antecedent | :consequent
        }

  @doc """
  Creates a Fuzzy Variable.

  The following options are require:
    * `:tag` - (string) Defines the linguistic name of the fuzzy variable (e.g., "error"),
    * `:fuzzy_sets` - (list) Defines which type of membership function use the set (e.g., "triangle").
    * `:type` - (atom) Defines the type of variable (e.g., :antecedent or :consequent),
    * `:range` - (range) The range in which the variable exists.
  """
  @spec new(keyword) :: Flex.Variable.t()
  def new(params) do
    tag = Keyword.fetch!(params, :tag)
    range = Keyword.fetch!(params, :range)
    fuzzy_sets = Keyword.fetch!(params, :fuzzy_sets)
    type = Keyword.fetch!(params, :type)
    %Variable{range: range, fuzzy_sets: fuzzy_sets, type: type, tag: tag}
  end

  @doc """
  Turns an antecedent fuzzy variable (input) from a crisp value to a fuzzy value.
  """
  @spec fuzzification(Flex.Variable.t(), any()) :: :error | Flex.Variable.t()
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
end
