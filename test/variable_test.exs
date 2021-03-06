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

  test "defuzzification test" do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-50, 0, -100])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-50, 0, 50])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 50, 100])

    fuzzy_sets = [t_h, j_r, t_c]

    error =
      Variable.new(tag: "error", fuzzy_sets: fuzzy_sets, type: :consequent, range: -100..100)

    error = %{error | tmp: [0.866, 0.5, 0]}
    output = Variable.defuzzification(error)
    assert Float.floor(output, 1) == -63.4
  end
end
