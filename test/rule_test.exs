defmodule RuleTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule}
  doctest Flex

  setup do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0, -4])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2, 4])

    fuzzy_sets = [t_h, j_r, t_c]
    error = Variable.new(tag: "error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    t_h = Set.new(tag: "getting hotter", mf_type: "saturation", mf_params: [-5, 0, -10])
    j_r = Set.new(tag: "no change", mf_type: "triangle", mf_params: [-5, 0, 5])
    t_c = Set.new(tag: "getting colder", mf_type: "shoulder", mf_params: [0, 5, 10])

    fuzzy_sets = [t_h, j_r, t_c]

    dt_error =
      Variable.new(tag: "dt_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -10..10)

    t_h = Set.new(tag: "cool", mf_type: "saturation", mf_params: [-50, 0, -100])
    j_r = Set.new(tag: "do nothing", mf_type: "triangle", mf_params: [-50, 0, 50])
    t_c = Set.new(tag: "heat", mf_type: "shoulder", mf_params: [0, 50, 100])

    fuzzy_sets = [t_h, j_r, t_c]

    output =
      Variable.new(tag: "output", fuzzy_sets: fuzzy_sets, type: :consequent, range: -100..100)

    %{ant: [error, dt_error], cons: output}
  end

  test "&&& 'fuzzy and' operator", %{ant: [error, _dt_error], cons: _output} do
    n_error = Variable.fuzzification(error, -1)
    assert n_error ~> "just right" &&& 0.3 == 0.3
  end

  test "||| 'fuzzy or' operator", %{ant: [error, _dt_error], cons: _output} do
    n_error = Variable.fuzzification(error, -1)
    assert (n_error ~> "just right" ||| 0.3) == 0.5
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
    assert 0.75 >>> output == d_output
  end

  test "fuzzy operators with lambdas", %{ant: [error, dt_error], cons: output} do
    n_error = Variable.fuzzification(error, -1)
    n_dt_error = Variable.fuzzification(dt_error, -2.5)

    r1 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "getting colder") >>> con ~> "cool"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "no change") >>> con ~> "cool"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "no change") >>> con ~> "heat"
    end

    output = r1.([n_error, n_dt_error, output])
    assert output.mf_values["cool"] == [0]
    output = r2.([n_error, n_dt_error, output])
    assert output.mf_values["cool"] == [0, 0.5]
    output = r3.([n_error, n_dt_error, output])
    assert output.mf_values["heat"] == [0.5]
  end

  test "new Rule", %{ant: [error, dt_error], cons: output} do
    n_error = Variable.fuzzification(error, -1)
    n_dt_error = Variable.fuzzification(dt_error, -2.5)

    r1 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "getting colder") >>> con ~> "cool"
    end

    rule1 =
      Rule.new(statement: r1, consequent: output.tag, antecedent: [n_error.tag, n_dt_error.tag])

    assert rule1.antecedent == ["error", "dt_error"]
    assert rule1.consequent == "output"

    output = rule1.statement.([n_error, n_dt_error, output])
    assert output.mf_values["cool"] == [0]
  end

  test "Inference engine", %{ant: [error, dt_error], cons: output} do
    n_error = Variable.fuzzification(error, -1)
    n_dt_error = Variable.fuzzification(dt_error, -2.5)

    r1 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "getting colder") >>> con ~> "cool"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "no change") >>> con ~> "heat"
    end

    rule1 =
      Rule.new(statement: r1, consequent: output.tag, antecedent: [n_error.tag, n_dt_error.tag])

    rule2 =
      Rule.new(statement: r2, consequent: output.tag, antecedent: [n_error.tag, n_dt_error.tag])

    antecedents = %{
      n_error.tag => n_error,
      n_dt_error.tag => n_dt_error
    }

    output = Flex.EngineAdapter.Mamdani.inference_engine(antecedents, [rule1, rule2], output)
    assert output.mf_values["cool"] == [0]
    assert output.mf_values["heat"] == [0.5]
  end
end
