defmodule VariableTest do
  use ExUnit.Case
  alias Flex.{Variable, Set}
  doctest Flex

  test "fuzzification test" do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0, 4])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2, 4])

    fuzzy_sets = [t_h, j_r, t_c]
    error = Variable.new(tag: "error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: 1..2)
    n_error = Variable.fuzzification(error, -1)
    assert n_error.mf_values["just right"] == 0.5
    assert n_error.mf_values["too cold"] == 0
    assert n_error.mf_values["too hot"] == 0.5
  end

  test "fuzzification only for antecedent variable" do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0, 4])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2, 4])

    fuzzy_sets = [t_h, j_r, t_c]
    error = Variable.new(tag: "error", fuzzy_sets: fuzzy_sets, type: :consequent, range: 1..2)
    n_error = Variable.fuzzification(error, -1)
    assert n_error == :error
  end

  test "Update a variable (ANFIS)" do
    # Random Initialization
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [1, 1, 1])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [1, 1, 1])
    y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [1, 1, 1])
    y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [1, 1, 1])

    fuzzy_sets = [y1, y2, y3, y4]
    output = Variable.new(tag: "y", fuzzy_sets: fuzzy_sets, type: :consequent, range: -10..10)

    gradients = [
      [0.0, 0.0, 0.97],
      [0.0, 0.0, 0.01],
      [0.0, 0.0, 0.01],
      [0.0, 0.0, 0.01]
    ]

    desired_mf_params = [
      [1.0, 1.0, 0.9515],
      [1.0, 1.0, 0.9995],
      [1.0, 1.0, 0.9995],
      [1.0, 1.0, 0.9995]
    ]

    new_variable = Variable.update(output, gradients, 0.05)

    for {fuzzy_set, desired_mf_param} <- Enum.zip(new_variable.fuzzy_sets, desired_mf_params),
      do: assert fuzzy_set.mf_params == desired_mf_param
  end
end
