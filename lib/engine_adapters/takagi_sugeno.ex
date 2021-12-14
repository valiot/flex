defmodule Flex.EngineAdapter.TakagiSugeno do
  @moduledoc """
  Takagi-Sugeno-Kang fuzzy inference uses singleton output membership functions that are either constant or a linear function of the input values.
  The defuzzification process for a Sugeno system is more computationally efficient compared to that of a Mamdani system,
  since it uses a weighted average or weighted sum of a few data points rather than compute a centroid of a two-dimensional area.
  """
  alias Flex.{EngineAdapter, EngineAdapter.State, Variable}
  @behaviour EngineAdapter

  import Flex.Rule, only: [statement: 2, get_rule_parameters: 3]

  @impl EngineAdapter
  def validation(engine_state, _antecedent, _rules, _consequent),
    do: engine_state

  @impl EngineAdapter
  def fuzzification(%State{input_vector: input_vector} = engine_state, antecedent) do
    fuzzy_antecedent = EngineAdapter.default_fuzzification(input_vector, antecedent, %{})
    %{engine_state | fuzzy_antecedent: fuzzy_antecedent}
  end

  @impl EngineAdapter
  def inference(
        %State{fuzzy_antecedent: fuzzy_antecedent, input_vector: input_vector} = engine_state,
        rules,
        consequent
      ) do
    fuzzy_consequent =
      fuzzy_antecedent
      |> inference_engine(rules, consequent)
      |> compute_output_level(input_vector)

    %{engine_state | fuzzy_consequent: fuzzy_consequent}
  end

  @impl EngineAdapter
  def defuzzification(%State{fuzzy_consequent: fuzzy_consequent} = engine_state) do
    %{engine_state | crisp_output: weighted_average_method(fuzzy_consequent)}
  end

  def inference_engine(_fuzzy_antecedent, [], consequent), do: consequent

  def inference_engine(fuzzy_antecedent, [rule | tail], consequent) do
    rule_parameters = get_rule_parameters(rule.antecedent, fuzzy_antecedent, []) ++ [consequent]

    consequent =
      if is_function(rule.statement) do
        rule.statement.(rule_parameters)
      else
        args = Map.merge(fuzzy_antecedent, %{consequent.tag => consequent})
        statement(rule.statement, args)
      end

    inference_engine(fuzzy_antecedent, tail, consequent)
  end

  defp compute_output_level(cons_var, input_vector) do
    rules_output =
      Enum.reduce(cons_var.fuzzy_sets, [], fn output_fuzzy_set, acc ->
        output_value =
          for _ <- cons_var.mf_values[output_fuzzy_set.tag], into: [] do
            output_fuzzy_set.mf.(input_vector)
          end

        acc ++ output_value
      end)

    %{cons_var | rule_output: rules_output}
  end

  @doc """
  Turns an consequent fuzzy variable (output) from a fuzzy value to a crisp value (weighted average method).
  """
  @spec weighted_average_method(Flex.Variable.t()) :: float
  def weighted_average_method(%Variable{type: type} = fuzzy_var) when type == :consequent do
    fuzzy_var
    |> build_fuzzy_sets_strength_list()
    |> fuzzy_to_crisp(fuzzy_var.rule_output, 0, 0)
  end

  defp build_fuzzy_sets_strength_list(%Variable{fuzzy_sets: fuzzy_sets, mf_values: mf_values}) do
    Enum.reduce(fuzzy_sets, [], fn fuzzy_set, acc -> acc ++ mf_values[fuzzy_set.tag] end)
  end

  defp fuzzy_to_crisp([], _input, nom, den), do: nom / den

  defp fuzzy_to_crisp([fs_strength | f_tail], [input | i_tail], nom, den) do
    nom = nom + fs_strength * input
    den = den + fs_strength
    fuzzy_to_crisp(f_tail, i_tail, nom, den)
  end
end
