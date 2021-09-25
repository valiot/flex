defmodule Flex.EngineAdapter.Mamdani do
  @moduledoc """
  Mamdani fuzzy inference was first introduced as a method to create a control system by synthesizing a set of linguistic control rules obtained from experienced human operators.
  In a Mamdani system, the output of each rule is a fuzzy set. Since Mamdani systems have more intuitive and easier to understand rule bases,
  they are well-suited to expert system applications where the rules are created from human expert knowledge, such as medical diagnostics.
  """
  alias Flex.{Variable, EngineAdapter, EngineAdapter.State}
  @behaviour EngineAdapter

  import Flex.Rule, only: [statement: 2, get_rule_parameters: 3]

  @impl EngineAdapter
  def validation(engine_state, _antecedents, _rules, _consequent),
    do: engine_state

  @impl EngineAdapter
  def fuzzification(%State{input_vector: input_vector} = engine_state, antecedents) do
    fuzzy_antecedents = EngineAdapter.default_fuzzification(input_vector, antecedents, %{})
    %{engine_state | fuzzy_antecedents: fuzzy_antecedents}
  end

  @impl EngineAdapter
  def inference(%State{fuzzy_antecedents: fuzzy_antecedents} = engine_state, rules, consequent) do
    fuzzy_consequent =
      fuzzy_antecedents
      |> inference_engine(rules, consequent)
      |> output_combination()

    %{engine_state | fuzzy_consequent: fuzzy_consequent}
  end

  @impl EngineAdapter
  def defuzzification(%State{fuzzy_consequent: fuzzy_consequent} = engine_state) do
    %{engine_state | crisp_output: centroid_method(fuzzy_consequent)}
  end

  def inference_engine(_fuzzy_antecedents, [], consequent), do: consequent

  def inference_engine(fuzzy_antecedents, [rule | tail], consequent) do
    rule_parameters = get_rule_parameters(rule.antecedents, fuzzy_antecedents, []) ++ [consequent]

    consequent =
      if is_function(rule.statement) do
        rule.statement.(rule_parameters)
      else
        args = Map.merge(fuzzy_antecedents, %{consequent.tag => consequent})
        statement(rule.statement, args)
      end

    inference_engine(fuzzy_antecedents, tail, consequent)
  end

  defp output_combination(cons_var) do
    output = Enum.map(cons_var.fuzzy_sets, fn x -> root_sum_square(cons_var.mf_values[x.tag]) end)
    %{cons_var | rule_output: output}
  end

  defp root_sum_square(nil), do: 0.0

  defp root_sum_square(mf_value) do
    mf_value
    |> Enum.map(fn x -> x * x end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  @doc """
  Turns an consequent fuzzy variable (output) from a fuzzy value to a crisp value (centroid method).
  """
  @spec centroid_method(Flex.Variable.t()) :: float
  def centroid_method(%Variable{type: type} = fuzzy_var) when type == :consequent do
    fuzzy_to_crisp(fuzzy_var.fuzzy_sets, fuzzy_var.rule_output, 0, 0)
  end

  defp fuzzy_to_crisp([], _input, nom, den), do: nom / den

  defp fuzzy_to_crisp([fs | f_tail], [input | i_tail], nom, den) do
    nom = nom + fs.mf_center * input
    den = den + input
    fuzzy_to_crisp(f_tail, i_tail, nom, den)
  end
end
