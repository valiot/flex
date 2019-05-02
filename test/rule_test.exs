defmodule RuleTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable}
  doctest Flex

  setup  do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0, -4])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2, 4])

    fuzzy_sets = [t_h, j_r, t_c]
    error = Variable.new(fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    t_h = Set.new(tag: "getting hotter", mf_type: "saturation", mf_params: [-5, 0, -10])
    j_r = Set.new(tag: "no change", mf_type: "triangle", mf_params: [-5, 0, 5])
    t_c = Set.new(tag: "getting colder", mf_type: "shoulder", mf_params: [0, 5, 10])

    fuzzy_sets = [t_h, j_r, t_c]
    dt_error = Variable.new(fuzzy_sets: fuzzy_sets, type: :antecedent, range: -10..10)


    t_h = Set.new(tag: "cool", mf_type: "saturation", mf_params: [-50, 0, -100])
    j_r = Set.new(tag: "do nothing", mf_type: "triangle", mf_params: [-50, 0, 50])
    t_c = Set.new(tag: "heat", mf_type: "shoulder", mf_params: [0, 50, 100])

    fuzzy_sets = [t_h, j_r, t_c]
    output = Variable.new(fuzzy_sets: fuzzy_sets, type: :consequent, range: -100..100)
    %{ant: [error, dt_error], cons: output}
  end

  test "&&& 'fuzzy and' operator", %{ant: [error, _dt_error], cons: _output} do
    n_error = Variable.fuzzification(error, -1)
    assert (n_error ~> "just right") &&& 0.3 == 0.3
  end

  test "||| 'fuzzy or' operator", %{ant: [error, _dt_error], cons: _output} do
    n_error = Variable.fuzzification(error, -1)
    assert ((n_error ~> "just right") ||| 0.3) == 0.5
  end

  test " ~> 'is' operator for antecedent var", %{ant: [error, _dt_error], cons: _output} do
    n_error = Variable.fuzzification(error, -1)
    assert n_error ~> "just right" == 0.5
  end

  test " ~> 'is' operator for consequent vars", %{ant: [_error, _dt_error], cons: output} do
    output = %{output | tmp: 0.75}
    n_output = output ~> "just right"
    assert n_output.mf_values["just right"] == [0.75]
    n_output = n_output ~> "just right"
    assert n_output.mf_values["just right"] == [0.75, 0.75]
  end

  test " >>> 'then' operator for antecedent vars", %{ant: [error, _dt_error], cons: _output} do
    assert_raise RuntimeError, ~r/^only the consequent variable can use the THEN operation/, fn ->
      1 >>> error
    end
  end

  test " >>> 'then' operator for consequent vars", %{ant: [_error, _dt_error], cons: output} do
    d_output = %{output | tmp: 0.75}
    assert (0.75 >>> output) == d_output
  end

  test "new Rule", %{ant: [error, dt_error], cons: output} do
    fn() ->
      ((error ~> "too hot") &&& (dt_error ~> "too hot") >>> output) ~>  "too hot"
    end
    #rl.()
  end
end
