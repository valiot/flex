defmodule Flex.Rule do
  alias Flex.Rule

  @moduledoc """
  An interface to create Linguistic Rules.
  """

  defstruct statement: nil,
            antecedent: nil,
            consequent: nil

  @typedoc """
  Linguistic Rule struct.
  - `:statement` - Rules behavior.
  - `:antecedent` - (list) Input variables.
  - `:consequent` - Output variable.
  """
  @type t :: %__MODULE__{
          statement: fun() | tuple(),
          antecedent: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t()
        }

  @doc """
  Creates a Linguistic Rule.

  The following options are require:
    - `:statement` - Defines the rule behavior.
    - `:antecedent` - (list) Defines the input variables.
    - `:consequent` - Defines the output variable.
  """
  def new(params) do
    rule = Keyword.fetch!(params, :statement)
    antecedent = Keyword.fetch!(params, :antecedent)
    consequent = Keyword.fetch!(params, :consequent)
    %Rule{statement: rule, antecedent: antecedent, consequent: consequent}
  end

  @doc """
  Fuzzy AND operator.
  """
  def a &&& b, do: min(a, b)

  @doc """
  Fuzzy OR operator.
  """
  def a ||| b, do: max(a, b)

  @doc """
  Fuzzy THEN operator.
  """
  def a >>> b do
    case b.type do
      :antecedent ->
        raise("only the consequent variable can use the THEN operation")

      :consequent ->
        %{b | tmp: a}
    end
  end

  @doc """
  Fuzzy IS operator.
  """
  def a ~> b do
    case a.type do
      :antecedent ->
        a.mf_values[b]

      :consequent ->
        new_values = Map.get(a.mf_values, b, []) ++ [a.tmp]
        mf_values = Map.put(a.mf_values, b, new_values)
        %{a | mf_values: mf_values}
    end
  end
end
