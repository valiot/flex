defmodule MamdaniTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule, System}
  doctest Flex

  test "Mamdani System test" do
    nb = Set.new(tag: "nb", mf_type: "saturation", mf_params: [-5, -2.5, -5])
    ns = Set.new(tag: "ns", mf_type: "triangle", mf_params: [-5, -2.5, 0])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-2.5, 0, 2.5])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0, 2.5, 5])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [2.5, 5, 5])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    error = Variable.new(tag: "error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -5..5)

    nb = Set.new(tag: "nb", mf_type: "saturation", mf_params: [-0.5, -0.25, -0.5])
    ns = Set.new(tag: "ns", mf_type: "triangle", mf_params: [-0.5, -0.25, 0])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-0.25, 0, 0.25])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0, 0.25, 0.5])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [0.25, 0.5, 0.50])

    fuzzy_sets = [nb, ns, ze, ps, pb]

    dt_error =
      Variable.new(tag: "dt_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-0.5, 0.5])

    output =
      Variable.new(tag: "output", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-0.5, 0.5])

    r1 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ps") >>> con ~> "nb"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "pb") >>> con ~> "nb"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "pb") >>> con ~> "nb"
    end

    r4 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "pb") >>> con ~> "nb"
    end

    r5 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ns") >>> con ~> "ns"
    end

    r6 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ze") >>> con ~> "ns"
    end

    r7 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ze") >>> con ~> "ns"
    end

    r8 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ps") >>> con ~> "ns"
    end

    r9 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ps") >>> con ~> "ns"
    end

    r10 = fn [at1, at2, con] ->
      (at1 ~> "ns" &&& at2 ~> "pb") >>> con ~> "ns"
    end

    r11 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "nb") >>> con ~> "ze"
    end

    r12 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ns") >>> con ~> "ze"
    end

    r13 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ze") >>> con ~> "ze"
    end

    r14 = fn [at1, at2, con] ->
      (at1 ~> "ns" &&& at2 ~> "ps") >>> con ~> "ze"
    end

    r15 = fn [at1, at2, con] ->
      (at1 ~> "nb" &&& at2 ~> "pb") >>> con ~> "ze"
    end

    r16 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "nb") >>> con ~> "ps"
    end

    r17 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ns") >>> con ~> "ps"
    end

    r18 = fn [at1, at2, con] ->
      (at1 ~> "ns" &&& at2 ~> "ns") >>> con ~> "ps"
    end

    r19 = fn [at1, at2, con] ->
      (at1 ~> "ns" &&& at2 ~> "ze") >>> con ~> "ps"
    end

    r20 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "nb") >>> con ~> "pb"
    end

    r21 = fn [at1, at2, con] ->
      (at1 ~> "ns" &&& at2 ~> "nb") >>> con ~> "pb"
    end

    r22 = fn [at1, at2, con] ->
      (at1 ~> "nb" &&& at2 ~> "nb") >>> con ~> "pb"
    end

    r23 = fn [at1, at2, con] ->
      (at1 ~> "nb" &&& at2 ~> "ns") >>> con ~> "pb"
    end

    r24 = fn [at1, at2, con] ->
      (at1 ~> "nb" &&& at2 ~> "ze") >>> con ~> "pb"
    end

    r25 = fn [at1, at2, con] ->
      (at1 ~> "nb" &&& at2 ~> "ps") >>> con ~> "pb"
    end

    rule1 = Rule.new(statement: r1, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule2 = Rule.new(statement: r2, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule3 = Rule.new(statement: r3, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule4 = Rule.new(statement: r4, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule5 = Rule.new(statement: r5, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule6 = Rule.new(statement: r6, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule7 = Rule.new(statement: r7, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule8 = Rule.new(statement: r8, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
    rule9 = Rule.new(statement: r9, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule10 =
      Rule.new(statement: r10, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule11 =
      Rule.new(statement: r11, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule12 =
      Rule.new(statement: r12, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule13 =
      Rule.new(statement: r13, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule14 =
      Rule.new(statement: r14, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule15 =
      Rule.new(statement: r15, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule16 =
      Rule.new(statement: r16, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule17 =
      Rule.new(statement: r17, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule18 =
      Rule.new(statement: r18, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule19 =
      Rule.new(statement: r19, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule20 =
      Rule.new(statement: r20, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule21 =
      Rule.new(statement: r21, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule22 =
      Rule.new(statement: r22, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule23 =
      Rule.new(statement: r23, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule24 =
      Rule.new(statement: r24, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rule25 =
      Rule.new(statement: r25, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

    rules = [
      rule1,
      rule2,
      rule3,
      rule4,
      rule5,
      rule6,
      rule7,
      rule8,
      rule9,
      rule10,
      rule11,
      rule12,
      rule13,
      rule14,
      rule15,
      rule16,
      rule17,
      rule18,
      rule19,
      rule20,
      rule21,
      rule22,
      rule23,
      rule24,
      rule25
    ]

    {:ok, s_pid} =
      System.start_link(antecedent: [error, dt_error], consequent: output, rules: rules)

    assert System.compute(s_pid, [-15, -0.5]) == 0.5
    assert System.compute(s_pid, [-15, -0.25]) == 0.5
    assert System.compute(s_pid, [-15, 0]) == 0.5
    assert System.compute(s_pid, [-15, 0.25]) == 0.5
    assert System.compute(s_pid, [-15, 0.5]) == 0
    assert System.compute(s_pid, [-7.5, -0.5]) == 0.5
    assert System.compute(s_pid, [-7.5, -0.25]) == 0.5
    assert System.compute(s_pid, [-7.5, 0]) == 0.5
    assert System.compute(s_pid, [-7.5, 0.25]) == 0.5
    assert System.compute(s_pid, [-7.5, 0.5]) == 0
    assert System.compute(s_pid, [0, -0.5]) == 0.5
    assert System.compute(s_pid, [0, -0.25]) == 0.25
    assert System.compute(s_pid, [0, 0]) == 0
    assert System.compute(s_pid, [0, 0.25]) == -0.25
    assert System.compute(s_pid, [0, 0.5]) == -0.5
    assert System.compute(s_pid, [7.5, -0.5]) == 0
    assert System.compute(s_pid, [7.5, -0.25]) == -0.25
    assert System.compute(s_pid, [7.5, 0]) == -0.25
    assert System.compute(s_pid, [7.5, 0.25]) == -0.5
    assert System.compute(s_pid, [7.5, 0.5]) == -0.5
    assert System.compute(s_pid, [15, -0.5]) == 0
    assert System.compute(s_pid, [15, -0.25]) == -0.25
    assert System.compute(s_pid, [15, 0]) == -0.25
    assert System.compute(s_pid, [15, 0.25]) == -0.5
    assert System.compute(s_pid, [15, 0.5]) == -0.5
  end
end
