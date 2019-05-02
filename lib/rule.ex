#funciones de ayuda "normalización, desnormalización"
defmodule Flex.Rule do
  alias Flex.Rule

  defstruct statement: nil,
            antecedent: nil,
            consequent: nil

  def a &&& b, do: min(a, b)

  def a ||| b, do: max(a, b)

  def  a >>> b do
    case b.type do
      :antecedent ->
        raise("only the consequent variable can use the THEN operation")
      :consequent ->
        %{b | tmp: a}
    end
  end

  def  a ~> b do
    case a.type do
      :antecedent ->
        a.mf_values[b]
      :consequent ->
        new_values = Map.get(a.mf_values, b, []) ++ [a.tmp]
        mf_values = Map.put(a.mf_values, b, new_values)
        %{a | mf_values: mf_values}
    end
  end

  def new(params) do
    rule = Keyword.fetch!(params, :statement)
    antecedent = Keyword.fetch!(params, :antecedent)
    consequent = Keyword.fetch!(params, :consequent)
    %Rule{statement: rule, antecedent: antecedent, consequent: consequent}
  end

  #ant debe ser mapa
  def inference_engine([], _antecedents, consequent), do: consequent
  def inference_engine([rule | tail], antecedents, consequent) do
    rule_params = get_spec_antecedents(rule.antecedent, antecedents, []) ++ [consequent]
    consequent = rule.statement.(rule_params)
    inference_engine(tail, antecedents, consequent)
  end

  def get_spec_antecedents([], _antecedents, lt_ant_vars), do: lt_ant_vars
  def get_spec_antecedents([tag | tail], antecedents, lt_ant_vars) do
    f_var = Map.get(antecedents, tag)
    lt_ant_vars = lt_ant_vars ++ [f_var]
    get_spec_antecedents(tail, antecedents, lt_ant_vars)
  end
end
