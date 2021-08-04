defmodule SystemTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule, System, EngineAdapter.TakagiSugeno}
  alias Flex.EngineAdapter.{TakagiSugeno, Mamdani}
  doctest Flex

  # http://robotics.ee.uwa.edu.au/courses/faulttolerant/notes/FT5.pdf

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

    r1 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "getting colder") >>> con ~> "cool"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "just right" &&& at2 ~> "getting colder") >>> con ~> "heat"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "too cold" &&& at2 ~> "getting colder") >>> con ~> "heat"
    end

    r4 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "no change") >>> con ~> "cool"
    end

    r5 = fn [at1, at2, con] ->
      (at1 ~> "just right" &&& at2 ~> "no change") >>> con ~> "do nothing"
    end

    r6 = fn [at1, at2, con] ->
      (at1 ~> "too cold" &&& at2 ~> "no change") >>> con ~> "heat"
    end

    r7 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "getting hotter") >>> con ~> "cool"
    end

    r8 = fn [at1, at2, con] ->
      (at1 ~> "just right" &&& at2 ~> "getting hotter") >>> con ~> "cool"
    end

    r9 = fn [at1, at2, con] ->
      (at1 ~> "too cold" &&& at2 ~> "getting hotter") >>> con ~> "heat"
    end

    rule1 = Rule.new(statement: r1, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule2 = Rule.new(statement: r2, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule3 = Rule.new(statement: r3, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule4 = Rule.new(statement: r4, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule5 = Rule.new(statement: r5, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule6 = Rule.new(statement: r6, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule7 = Rule.new(statement: r7, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule8 = Rule.new(statement: r8, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule9 = Rule.new(statement: r9, consequent: output.tag, antecedents: [error.tag, dt_error.tag])

    rules = [rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8, rule9]

    %{ant: [error, dt_error], cons: output, rules: rules, error: error, dt_error: dt_error}
  end

  test "Setup for the fuzzy logic system", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
    state = :sys.get_state(s_pid)
    assert is_list(state.antecedents)
    assert is_map(state.consequent)
    assert is_list(state.rules)
  end

  test "Compute an output with an input vector", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
    output = System.compute(s_pid, [-1, -2.5])
    assert Float.floor(output, 1) == -63.4
  end

  test "Change Engine Inference", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
    assert System.set_engine_type(s_pid, TakagiSugeno) == :ok
    assert System.set_engine_type(s_pid, Mamdani) == :ok
    assert System.set_engine_type(s_pid, Another) == {:error, :einval}
  end

  test "Setup with AST", %{ant: ant, cons: output, error: error, dt_error: dt_error} do
    r1 =
      {{{{"error", "too hot", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
        ">>>"}, "cool", "~>"}

    r2 =
      {{{{"error", "just right", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
        ">>>"}, "heat", "~>"}

    r3 =
      {{{{"error", "too cold", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
        ">>>"}, "heat", "~>"}

    r4 =
      {{{{"error", "too hot", "~>"}, {"dt_error", "no change", "~>"}, "&&&"}, "output", ">>>"},
       "cool", "~>"}

    r5 =
      {{{{"error", "just right", "~>"}, {"dt_error", "no change", "~>"}, "&&&"}, "output", ">>>"},
       "do nothing", "~>"}

    r6 =
      {{{{"error", "too cold", "~>"}, {"dt_error", "no change", "~>"}, "&&&"}, "output", ">>>"},
       "heat", "~>"}

    r7 =
      {{{{"error", "too hot", "~>"}, {"dt_error", "getting hotter", "~>"}, "&&&"}, "output",
        ">>>"}, "cool", "~>"}

    r8 =
      {{{{"error", "just right", "~>"}, {"dt_error", "getting hotter", "~>"}, "&&&"}, "output",
        ">>>"}, "cool", "~>"}

    r9 =
      {{{{"error", "too cold", "~>"}, {"dt_error", "getting hotter", "~>"}, "&&&"}, "output",
        ">>>"}, "cool", "~>"}

    rule1 = Rule.new(statement: r1, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule2 = Rule.new(statement: r2, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule3 = Rule.new(statement: r3, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule4 = Rule.new(statement: r4, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule5 = Rule.new(statement: r5, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule6 = Rule.new(statement: r6, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule7 = Rule.new(statement: r7, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule8 = Rule.new(statement: r8, consequent: output.tag, antecedents: [error.tag, dt_error.tag])
    rule9 = Rule.new(statement: r9, consequent: output.tag, antecedents: [error.tag, dt_error.tag])

    rules = [rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8, rule9]

    {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
    output = System.compute(s_pid, [-1, -2.5])
    assert Float.floor(output, 1) == -63.4
  end
end
