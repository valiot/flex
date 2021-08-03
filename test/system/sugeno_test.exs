defmodule TakagiSugenoTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule, System, EngineAdapter.TakagiSugeno}
  doctest Flex

  # https://www.youtube.com/watch?v=GnuseFrYctI&list=PLhdVEDm7SZ-Ph7E3bYW89UbjD6zkW-vbf&index=20

  setup do
    small = Set.new(tag: "small", mf_type: "z_shaped", mf_params: [-2.5, 2.75, nil])
    large = Set.new(tag: "large", mf_type: "s_shaped", mf_params: [-3, 2, nil])

    fuzzy_sets = [small, large]
    x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    small = Set.new(tag: "small", mf_type: "z_shaped", mf_params: [-2.2, 4, nil])
    large = Set.new(tag: "large", mf_type: "s_shaped", mf_params: [-3, 4, nil])

    fuzzy_sets = [small, large]
    x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -10..10)

    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [-1, 1, 1])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [0, -1, 3])
    y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [-1, 0, 3])
    y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [-1, 1, 2])

    fuzzy_sets = [y1, y2, y3, y4]
    output = Variable.new(tag: "y", fuzzy_sets: fuzzy_sets, type: :consequent, range: -100..100)

    r1 = fn [at1, at2, con] ->
      (at1 ~> "small" &&& at2 ~> "small") >>> con ~> "y1"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "small" &&& at2 ~> "large") >>> con ~> "y2"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "large" &&& at2 ~> "small") >>> con ~> "y3"
    end

    r4 = fn [at1, at2, con] ->
      (at1 ~> "large" &&& at2 ~> "large") >>> con ~> "y4"
    end

    rule1 = Rule.new(statement: r1, consequent: output.tag, antecedent: [x1.tag, x2.tag])
    rule2 = Rule.new(statement: r2, consequent: output.tag, antecedent: [x1.tag, x2.tag])
    rule3 = Rule.new(statement: r3, consequent: output.tag, antecedent: [x1.tag, x2.tag])
    rule4 = Rule.new(statement: r4, consequent: output.tag, antecedent: [x1.tag, x2.tag])

    rules = [rule1, rule2, rule3, rule4]

    %{ant: [x1, x2], cons: output, rules: rules}
  end

  test "Setup for the fuzzy logic system", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedent: ant, consequent: output, rules: rules)
    state = :sys.get_state(s_pid)
    assert is_map(state.antecedent)
    assert is_map(state.consequent)
    assert is_list(state.rules)
  end

  test "Compute an output with an input vector", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedent: ant, consequent: output, rules: rules)
    :ok = System.set_engine_type(s_pid, TakagiSugeno)
    output = System.compute(s_pid, [1.5, 2.5])
    assert Float.floor(output, 1) == 3.26
  end

end
