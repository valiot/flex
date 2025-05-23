defmodule Flex.EngineAdapter.ANFIS do
  @moduledoc """
  An adaptive network-based fuzzy inference system (ANFIS) is a kind of artificial neural network that is based on Takagi–Sugeno fuzzy inference system,
  this implementation use backpropagation, only Gaussian Membership function are allowed.
  Reference:
  https://upcommons.upc.edu/bitstream/handle/2099.1/20296/Annex%201%20-%20Introduction%20to%20Adaptive%20Neuro-Fuzzy%20Inference%20Systems%20%28ANFIS%29.pdf
  Jang, J-SR. "ANFIS: adaptive-network-based fuzzy inference system." IEEE transactions on systems, man, and cybernetics 23.3 (1993): 665-685.
  """
  alias Flex.{EngineAdapter, EngineAdapter.State, MembershipFun, Variable}
  @behaviour EngineAdapter

  import Flex.Rule, only: [statement: 2, get_rule_parameters: 3]
  import MembershipFun, only: [derivative: 4]

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

  def forward_pass(de_dy, learning_rate, %{
        fuzzy_consequent: fuzzy_consequent,
        input_vector: input_vector
      }) do
    w = get_w(fuzzy_consequent) |> List.flatten()
    n_w = Enum.map(w, fn w_i -> w_i / Enum.sum(w) end)

    dy_dbc =
      Enum.map(n_w, fn n_w_i -> Enum.map(input_vector ++ [1], fn input -> input * n_w_i end) end)

    de_dbc =
      Enum.map(dy_dbc, fn dy_dbc_f ->
        Enum.map(dy_dbc_f, fn dy_dbc_fi -> de_dy * dy_dbc_fi end)
      end)

    Variable.update(fuzzy_consequent, de_dbc, learning_rate)
  end

  defp get_w(fuzzy_consequent) do
    Enum.reduce(fuzzy_consequent.fuzzy_sets, [], fn output_fuzzy_set, acc ->
      acc ++ [fuzzy_consequent.mf_values[output_fuzzy_set.tag]]
    end)
  end

  def backward_pass(
        de_dy,
        %{
          antecedent: antecedent,
          sets_in_rules: sets_in_rules,
          learning_rate: learning_rate
        },
        %{
          fuzzy_antecedent: fuzzy_antecedent,
          fuzzy_consequent: fuzzy_consequent,
          input_vector: input_vector
        }
      ) do
    ant_list =
      antecedent
      |> Enum.map(fn antecedent -> antecedent.tag end)
      |> Enum.with_index()

    w = get_w(fuzzy_consequent) |> List.flatten()
    n_w = Enum.map(w, fn w_i -> w_i / Enum.sum(w) end)

    # inputs loop
    for {ant_tag, i_index} <- ant_list, reduce: [] do
      acc ->
        # Sets loop
        de_da =
          for fuzzy_set <- fuzzy_antecedent[ant_tag].fuzzy_sets, reduce: [] do
            acc ->
              # Get dependent rules.
              sets = Enum.map(sets_in_rules, fn sets -> Enum.at(sets, i_index) end)

              w_d =
                for {{w_i, set}, w_index} <- Enum.zip(w, sets) |> Enum.with_index(),
                    fuzzy_set.tag == set,
                    do: {w_i, w_index}

              muij = fuzzy_antecedent[ant_tag].mf_values[fuzzy_set.tag]

              # Premise parameters loop
              de_dag =
                for {_aij, g_index} <- Enum.with_index(fuzzy_set.mf_params), reduce: [] do
                  acc ->
                    dmuij_daij =
                      derivative(fuzzy_set, Enum.at(input_vector, i_index), muij, g_index)

                    de_daij =
                      for {w_i, w_index} <- w_d, reduce: 0 do
                        acc ->
                          dwi_dmuij = dwi_dmuij(w_i, muij)

                          sum_dy_dwi =
                            for {fi, k_index} <- Enum.with_index(fuzzy_consequent.rule_output),
                                reduce: 0 do
                              acc ->
                                dy_dnwi = fi
                                dnwi_dwi = dnwi_dwi(n_w, w, w_index, k_index)
                                acc + dy_dnwi * dnwi_dwi
                            end

                          acc + de_dy * sum_dy_dwi * dwi_dmuij * dmuij_daij
                      end

                    acc ++ [de_daij]
                end

              acc ++ [de_dag]
          end

        acc ++ [Variable.update(fuzzy_antecedent[ant_tag], de_da, learning_rate)]
    end
  end

  defp dnwi_dwi(n_w, w, w_index, k_index) when w_index == k_index do
    with n_w_k <- Enum.at(n_w, k_index),
         w_k <- Enum.at(w, k_index),
         true <- w_k != 0 do
      n_w_k * (1 - n_w_k) / w_k
    else
      _ ->
        0
    end
  end

  defp dnwi_dwi(n_w, w, _w_index, k_index) do
    with n_w_k <- Enum.at(n_w, k_index),
         w_k <- Enum.at(w, k_index),
         true <- w_k != 0 do
      -:math.pow(n_w_k, 2) / w_k
    else
      _ ->
        0
    end
  end

  defp dwi_dmuij(+0.0, +0.0), do: 1
  defp dwi_dmuij(w_i, +0.0), do: w_i / 1.0e-10
  defp dwi_dmuij(w_i, muij), do: w_i / muij

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

  def least_square_estimate(a_matrix, b_matrix, initial_gamma, state) do
    consequent_args_size = a_matrix |> Enum.at(0) |> Enum.count()
    s_matrix = Nx.eye(consequent_args_size) |> Nx.multiply(initial_gamma)
    x_vector = List.duplicate([0], consequent_args_size) |> Nx.tensor()

    {_s_matrix, x_vector} =
      for {at, bt} <- Enum.zip(a_matrix, b_matrix), reduce: {s_matrix, x_vector} do
        {s_matrix, x_vector} ->
          at = Nx.tensor([at])
          a = Nx.transpose(at)

          at_s = multiply(at, s_matrix)

          s_a_at_s =
            s_matrix
            |> multiply(a)
            |> multiply(at_s)

          at_s_a_p1 =
            at_s
            |> multiply(a)
            |> Nx.add(1)

          s_matrix = Nx.subtract(s_matrix, Nx.divide(s_a_at_s, at_s_a_p1))

          at_x = multiply(at, x_vector)

          x_vector =
            s_matrix
            |> multiply(a)
            |> multiply(Nx.subtract(bt, at_x))
            |> Nx.add(x_vector)

          {s_matrix, x_vector}
      end

    x_vector_lt = x_vector |> Nx.to_flat_list()
    Variable.update(state.consequent, x_vector_lt)
  end

  defp multiply(a, b), do: Nx.dot(a, [1], b, [0])
end
