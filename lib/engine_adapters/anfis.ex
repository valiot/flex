defmodule Flex.EngineAdapter.ANFIS do
  @moduledoc """
  An adaptive network-based fuzzy inference system (ANFIS) is a kind of artificial neural network that is based on Takagi–Sugeno fuzzy inference system,
  this implementation use backpropagation, only Gaussian Membership function are allowed.
  Reference:
  https://upcommons.upc.edu/bitstream/handle/2099.1/20296/Annex%201%20-%20Introduction%20to%20Adaptive%20Neuro-Fuzzy%20Inference%20Systems%20%28ANFIS%29.pdf
  Jang, J-SR. "ANFIS: adaptive-network-based fuzzy inference system." IEEE transactions on systems, man, and cybernetics 23.3 (1993): 665-685.
  """
  alias Flex.{Variable, MembershipFun, EngineAdapter, EngineAdapter.State}
  @behaviour EngineAdapter

  import Flex.Rule, only: [statement: 2, get_rule_parameters: 3]
  import MembershipFun, only: [derivative: 4]

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

  def backward_pass(
        dE_dy,
        %{
          antecedents: antecedents,
          sets_in_rules: sets_in_rules,
          learning_rate: learning_rate
        },
        %{
          fuzzy_antecedents: fuzzy_antecedents,
          fuzzy_consequent: fuzzy_consequent,
          input_vector: input_vector
        }
      ) do
    ant_list =
      antecedents
      |> Enum.map(fn(antecedent) -> antecedent.tag end)
      |> Enum.with_index()

    #IO.inspect fuzzy_antecedents
    #IO.inspect fuzzy_consequent

    #IO.puts("\n\n")

    # TODO: Force Rule Order
    w = fuzzy_consequent.mf_values |> Map.values() |> List.flatten() #|> IO.inspect()
    #n_w = Enum.map(w, fn w_i -> w_i / Enum.sum(w) end) #|> IO.inspect()

    # inputs loop
    for {ant_tag, i_index} <- ant_list, reduce: [] do
      acc ->
        # Sets loop
        dE_da =
          for fuzzy_set <- fuzzy_antecedents[ant_tag].fuzzy_sets, reduce: [] do
            acc ->
              #IO.inspect({ant_tag, fuzzy_set.tag})
              # Get dependent rules.
              sets = Enum.map(sets_in_rules, fn sets -> Enum.at(sets, i_index) end)
              w_d = for {w_i, set} <- Enum.zip(w, sets), fuzzy_set.tag == set, do: w_i

              muij = fuzzy_antecedents[ant_tag].mf_values[fuzzy_set.tag] #|> IO.inspect(label: "muij")

              # Premise parameters loop
              dE_dag =
                for {_aij, g_index} <- Enum.with_index(fuzzy_set.mf_params), reduce: [] do
                  acc ->
                    #IO.inspect(g_index, label: "aij")
                    dmuij_daij = derivative(fuzzy_set, Enum.at(input_vector, i_index), muij, g_index) #|> IO.inspect(label: "dmuij_daij")

                    dE_daij =
                      for w_i <- w_d, reduce: 0 do
                        acc ->
                          #IO.inspect(w_i, label: "w_i")
                          dwi_dmuij = w_i / muij # |> IO.inspect(label: "dwi_dmuij")
                          #IO.puts("sum from all rules") #sum from all rules
                          sum_dy_dwi =
                            for fi <- fuzzy_consequent.rule_output, reduce: 0 do
                              acc ->
                                dy_dnwi = fi #|> IO.inspect(label: "dy_dnwi")
                                #dnwi_dwi = (Enum.sum(w) - w_i) / :math.pow(Enum.sum(w), 2) #|> IO.inspect(label: "dnwi_dwi")
                                dnwi_dwi = Enum.reduce(w, 0, fn w_j, acc -> acc + (w_j - w_i) / :math.pow(Enum.sum(w), 2) end) #|> IO.inspect(label: "dnwi_dwi")
                                acc + dy_dnwi * dnwi_dwi
                            end #|> IO.inspect(label: "sum_dy_dwi")
                            #IO.puts("\n")
                          acc + dE_dy * sum_dy_dwi * dwi_dmuij * dmuij_daij
                      end #|> IO.inspect(label: "dE_daij")
                      #IO.puts("\n\n")
                    acc ++ [dE_daij]
                end #|> IO.inspect(label: "dE_dag")
              acc ++ [dE_dag]
          end #|> IO.inspect()
          #IO.puts("\n\n") #sum from all rules
        acc ++ [Variable.update(fuzzy_antecedents[ant_tag], dE_da, learning_rate)]
    end #|> IO.inspect()
  end

  # def backward_pass(
  #       dE_dy,
  #       %{
  #         antecedents: antecedents,
  #         sets_in_rules: sets_in_rules,
  #         learning_rate: learning_rate
  #       },
  #       %{
  #         fuzzy_antecedents: fuzzy_antecedents,
  #         fuzzy_consequent: fuzzy_consequent,
  #         input_vector: input_vector
  #       }
  #     ) do
  #   ant_list =
  #     antecedents
  #     |> Enum.map(fn(antecedent) -> antecedent.tag end)
  #     |> Enum.with_index()

  #   # TODO: Force Rule Order
  #   w = fuzzy_consequent.mf_values |> Map.values() |> List.flatten()

  #   # inputs loop
  #   for {ant_tag, i_index} <- ant_list, reduce: [] do
  #     acc ->
  #       # Sets loop
  #       dE_da =
  #         for {fuzzy_set, _j_index} <- Enum.with_index(fuzzy_antecedents[ant_tag].fuzzy_sets), reduce: [] do
  #           acc ->
  #             # Get dependent rules.
  #             sets = Enum.map(sets_in_rules, fn sets -> Enum.at(sets, i_index) end)
  #             w_d = for {w_i, set} <- Enum.zip(w, sets), fuzzy_set.tag == set, do: w_i

  #             muij = fuzzy_antecedents[ant_tag].mf_values[fuzzy_set.tag]

  #             # Premise parameters loop
  #             dE_dag =
  #               for {_aij, g_index} <- Enum.with_index(fuzzy_set.mf_params), reduce: [] do
  #                 acc ->

  #                   dmuij_daij = derivative(fuzzy_set, Enum.at(input_vector, i_index), muij, g_index)

  #                   dE_daij =
  #                     for w_i <- w_d, reduce: 0 do
  #                       acc ->
  #                         dwi_dmuij = w_i / muij
  #                         #sum from all rules
  #                         sum_dy_dwi =
  #                           for fi <- fuzzy_consequent.rule_output, reduce: 0 do
  #                             acc ->
  #                               dy_dnwi = fi
  #                               dnwi_dwi = Enum.reduce(w, 0, fn w_j, acc -> acc + (w_j - w_i) / :math.pow(Enum.sum(w), 2) end)
  #                               acc + dy_dnwi * dnwi_dwi
  #                           end
  #                         acc + dE_dy * sum_dy_dwi * dwi_dmuij * dmuij_daij
  #                     end
  #                   acc ++ [dE_daij]
  #               end
  #             acc ++ [dE_dag]
  #         end
  #       acc ++ [Variable.update(fuzzy_antecedents[ant_tag], dE_da, learning_rate)]
  #   end
  # end

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
