defmodule Flex.Rule do
  alias Flex.Rule

  @moduledoc """
  An interface to create Linguistic Rules.
  """

  defstruct statement: nil,
            antecedents: nil,
            consequent: nil

  @typedoc """
  Linguistic Rule struct.
  - `:statement` - Rules behavior.
  - `:antecedent` - (list) Input variables.
  - `:consequent` - Output variable.
  """
  @type t :: %__MODULE__{
          statement: fun() | tuple(),
          antecedents: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t()
        }

  @doc """
  Creates a Linguistic Rule.

  The following options are require:
    - `:statement` - Defines the rule behavior.
    - `:antecedents` - (list) Defines the input variables.
    - `:consequent` - Defines the output variable.
  """
  def new(params) do
    rule = Keyword.fetch!(params, :statement)
    antecedents = Keyword.fetch!(params, :antecedents)
    consequent = Keyword.fetch!(params, :consequent)
    %Rule{statement: rule, antecedents: antecedents, consequent: consequent}
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
        %{b | rule_output: a}
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
        new_values = Map.get(a.mf_values, b, []) ++ [a.rule_output]
        mf_values = Map.put(a.mf_values, b, new_values)
        %{a | mf_values: mf_values}
    end
  end

  @doc """
  Fuzzy Rules AST (Tuple).
  """
  def statement({arg1, arg2, "&&&"}, args), do: statement(arg1, args) &&& statement(arg2, args)
  def statement({arg1, arg2, "|||"}, args), do: statement(arg1, args) ||| statement(arg2, args)

  def statement({var_tag, set_tag, "~>"}, args) when is_binary(var_tag) do
    fuzzy_var = Map.get(args, var_tag, :error)
    fuzzy_var ~> set_tag
  end

  def statement({consequent, set_tag, "~>"}, args), do: statement(consequent, args) ~> set_tag

  def statement({arg1, con_tag, ">>>"}, args) do
    val = statement(arg1, args)
    consequent = Map.get(args, con_tag)
    val >>> consequent
  end

  def statement(arg, _args), do: arg

  @doc """
  .Gets the arguments of the Fuzzy Rule
  """
  def get_rule_parameters([], _antecedents, lt_ant_vars), do: lt_ant_vars

  def get_rule_parameters([tag | tail], antecedents, lt_ant_vars) do
    f_var = Map.get(antecedents, tag)
    lt_ant_vars = lt_ant_vars ++ [f_var]
    get_rule_parameters(tail, antecedents, lt_ant_vars)
  end
end
