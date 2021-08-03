defmodule Flex.EngineAdapter.Mamdani do
  @moduledoc """
  Mamdani fuzzy inference was first introduced as a method to create a control system by synthesizing a set of linguistic control rules obtained from experienced human operators.
  In a Mamdani system, the output of each rule is a fuzzy set. Since Mamdani systems have more intuitive and easier to understand rule bases,
  they are well-suited to expert system applications where the rules are created from human expert knowledge, such as medical diagnostics.
  """
  alias Flex.{Variable, EngineAdapter}
  @behaviour EngineAdapter

  import Flex.Rule

  @impl EngineAdapter
  def validation(input_vector, _antecedent_list, _rules, _consequent),
    do: input_vector

  @impl EngineAdapter
  def fuzzification(input_vector, antecedent_name_list, antecedent_map),
    do: EngineAdapter.default_fuzzification(input_vector, antecedent_name_list, antecedent_map)

  @impl EngineAdapter
  def inference(fuzzy_antecedents, rules, consequent) do
    fuzzy_antecedents
    |> inference_engine(rules, consequent)
    |> output_combination()
  end

  @impl EngineAdapter
  def defuzzification(fuzzy_output), do: Variable.defuzzification(fuzzy_output)

  def inference_engine(_antecedents, [], consequent), do: consequent

  def inference_engine(antecedents, [rule | tail], consequent) do
    rule_params = get_spec_antecedents(rule.antecedent, antecedents, []) ++ [consequent]

    consequent =
      if is_function(rule.statement) do
        rule.statement.(rule_params)
      else
        args = Map.merge(antecedents, %{consequent.tag => consequent})
        statement(rule.statement, args)
      end

    inference_engine(antecedents, tail, consequent)
  end

  defp get_spec_antecedents([], _antecedents, lt_ant_vars), do: lt_ant_vars

  defp get_spec_antecedents([tag | tail], antecedents, lt_ant_vars) do
    f_var = Map.get(antecedents, tag)
    lt_ant_vars = lt_ant_vars ++ [f_var]
    get_spec_antecedents(tail, antecedents, lt_ant_vars)
  end

  defp output_combination(cons_var) do
    output = Enum.map(cons_var.fuzzy_sets, fn x -> root_sum_square(cons_var.mf_values[x.tag]) end)
    %{cons_var | tmp: output}
  end

  defp root_sum_square(mf_value) do
    mf_value
    |> Enum.map(fn x -> x * x end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  defp statement({arg1, arg2, "&&&"}, args), do: statement(arg1, args) &&& statement(arg2, args)
  defp statement({arg1, arg2, "|||"}, args), do: statement(arg1, args) ||| statement(arg2, args)

  defp statement({var_tag, set_tag, "~>"}, args) when is_binary(var_tag) do
    fuzzy_var = Map.get(args, var_tag, :error)
    fuzzy_var ~> set_tag
  end

  defp statement({consequent, set_tag, "~>"}, args), do: statement(consequent, args) ~> set_tag

  defp statement({arg1, con_tag, ">>>"}, args) do
    val = statement(arg1, args)
    consequent = Map.get(args, con_tag)
    val >>> consequent
  end

  defp statement(arg, _args), do: arg
end
