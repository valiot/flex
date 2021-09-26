defmodule Flex.EngineAdapter.ANFIS do
  @moduledoc """
  An adaptive network-based fuzzy inference system (ANFIS) is a kind of artificial neural network that is based on Takagi–Sugeno fuzzy inference system,
  this implementation use backpropagation, only Gaussian Membership function are allowed.
  Reference:
  https://upcommons.upc.edu/bitstream/handle/2099.1/20296/Annex%201%20-%20Introduction%20to%20Adaptive%20Neuro-Fuzzy%20Inference%20Systems%20%28ANFIS%29.pdf

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
  def inference(
        %State{fuzzy_antecedents: fuzzy_antecedents, input_vector: input_vector} = engine_state,
        rules,
        consequent
      ) do
    fuzzy_consequent =
      fuzzy_antecedents
      |> inference_engine(rules, consequent)
      |> compute_output_level(input_vector)

    %{engine_state | fuzzy_consequent: fuzzy_consequent}
  end

  @impl EngineAdapter
  def defuzzification(%State{fuzzy_consequent: fuzzy_consequent} = engine_state) do
    %{engine_state | crisp_output: weighted_average_method(fuzzy_consequent)}
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

  def forward_pass(dE_do5, learning_rate, %{
        fuzzy_consequent: fuzzy_consequent,
        input_vector: input_vector
      }) do
    w = fuzzy_consequent.mf_values |> Map.values() |> List.flatten()
    n_w = Enum.map(w, fn w_i -> w_i / Enum.sum(w) end)

    do5_dBc =
      Enum.map(n_w, fn n_w_i -> Enum.map(input_vector ++ [1], fn input -> input * n_w_i end) end)

    dE_dBc =
      Enum.map(do5_dBc, fn do5_dBc_f ->
        Enum.map(do5_dBc_f, fn do5_dBc_fi -> dE_do5 * do5_dBc_fi end)
      end)

    Variable.update(fuzzy_consequent, dE_dBc, learning_rate)
  end

  def backward_pass(dE_do5, learning_rate, %{
        fuzzy_antecedents: fuzzy_antecedents,
        fuzzy_consequent: fuzzy_consequent,
        input_vector: input_vector
      }) do
    w = fuzzy_consequent.mf_values |> Map.values() |> List.flatten()
    n_w = Enum.map(w, fn w_i -> w_i / Enum.sum(w) end)

    do4_dBc =
      Enum.map(n_w, fn n_w_i -> Enum.map(input_vector ++ [1], fn input -> input * n_w_i end) end)

    dE_dBc =
      Enum.map(do4_dBc, fn do4_dBc_f ->
        Enum.map(do4_dBc_f, fn do4_dBc_fi -> dE_do5 * do4_dBc_fi end)
      end)

    Variable.update(fuzzy_consequent, dE_dBc, learning_rate)
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
