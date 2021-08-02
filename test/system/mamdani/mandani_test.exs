defmodule MamdaniTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule, System}
  doctest Flex

  test "Controller 1 test" do

    # Fuzzy Sets & Variables

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-0.15, -0.1, -0.22])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-0.125, -0.075, 0.025])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-0.05, 0, 0.05])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0.025, 0.075, 0.125])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [0.1, 0.15, 0.22])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    density_error =
      Variable.new(tag: "density_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-0.22, 0.22])

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-30, -20, -40])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-25, -15, -5])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-10, 0, 10])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [5, 15, 25])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [20, 30, 40])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    viscosity_error =
      Variable.new(tag: "viscosity_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -40..40)

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-1500, -1000, -2000])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-1250, -750, -250])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-500, 0, 500])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [250, 750, 1250])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [1000, 1500, 2000])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    water_flow_rate_delta =
      Variable.new(tag: "water_flow_rate_delta", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-2000, 2000])


    r1 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "mb") >>> con ~> "pb"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "ms") >>> con ~> "pb"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "ze") >>> con ~> "pb"
    end

    r4 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "ps") >>> con ~> "ps"
    end

    r5 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "pb") >>> con ~> "ps"
    end

    r6 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "mb") >>> con ~> "pb"
    end

    r7 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "ms") >>> con ~> "ps"
    end

    r8 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "ze") >>> con ~> "ze"
    end

    r9 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "ps") >>> con ~> "ze"
    end

    r10 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "pb") >>> con ~> "ps"
    end

    r11 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "mb") >>> con ~> "ps"
    end

    r12 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ms") >>> con ~> "ze"
    end

    r13 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ze") >>> con ~> "ze"
    end

    r14 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ps") >>> con ~> "ze"
    end

    r15 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "pb") >>> con ~> "ms"
    end

    r16 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "mb") >>> con ~> "ms"
    end

    r17 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ms") >>> con ~> "ze"
    end

    r18 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ze") >>> con ~> "ze"
    end

    r19 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ps") >>> con ~> "ms"
    end

    r20 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "pb") >>> con ~> "mb"
    end

    r21 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "mb") >>> con ~> "ms"
    end

    r22 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ms") >>> con ~> "ms"
    end

    r23 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ze") >>> con ~> "mb"
    end

    r24 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ps") >>> con ~> "mb"
    end

    r25 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "pb") >>> con ~> "mb"
    end

    rule1 = Rule.new(statement: r1, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule2 = Rule.new(statement: r2, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule3 = Rule.new(statement: r3, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule4 = Rule.new(statement: r4, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule5 = Rule.new(statement: r5, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule6 = Rule.new(statement: r6, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule7 = Rule.new(statement: r7, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule8 = Rule.new(statement: r8, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
    rule9 = Rule.new(statement: r9, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule10 =
      Rule.new(statement: r10, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule11 =
      Rule.new(statement: r11, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule12 =
      Rule.new(statement: r12, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule13 =
      Rule.new(statement: r13, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule14 =
      Rule.new(statement: r14, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule15 =
      Rule.new(statement: r15, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule16 =
      Rule.new(statement: r16, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule17 =
      Rule.new(statement: r17, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule18 =
      Rule.new(statement: r18, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule19 =
      Rule.new(statement: r19, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule20 =
      Rule.new(statement: r20, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule21 =
      Rule.new(statement: r21, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule22 =
      Rule.new(statement: r22, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule23 =
      Rule.new(statement: r23, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule24 =
      Rule.new(statement: r24, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

    rule25 =
      Rule.new(statement: r25, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

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
      System.start_link(antecedent: [density_error, viscosity_error], consequent: water_flow_rate_delta, rules: rules)

    density_error_mb = fn -> random_between(-0.22, -0.1) end
    density_error_ms = fn -> random_between(-0.125, -0.025) end
    density_error_ze = fn -> random_between(-0.05, 0.05) end
    density_error_ps = fn -> random_between(0.025, 0.125) end
    density_error_pb = fn -> random_between(0.1, 0.22) end

    viscosity_error_mb = fn -> random_between(-40, -20) end
    viscosity_error_ms = fn -> random_between(-25, -5) end
    viscosity_error_ze = fn -> random_between(-10, 10) end
    viscosity_error_ps = fn -> random_between(5, 25) end
    viscosity_error_pb = fn -> random_between(20, 40) end


    compute(s_pid, [density_error_mb.(), viscosity_error_mb.()])
    compute(s_pid, [density_error_mb.(), viscosity_error_ms.()])
    compute(s_pid, [density_error_mb.(), viscosity_error_ze.()])
    compute(s_pid, [density_error_mb.(), viscosity_error_ps.()])
    compute(s_pid, [density_error_mb.(), viscosity_error_pb.()])

    compute(s_pid, [density_error_ms.(), viscosity_error_mb.()])
    compute(s_pid, [density_error_ms.(), viscosity_error_ms.()])
    compute(s_pid, [density_error_ms.(), viscosity_error_ze.()])
    compute(s_pid, [density_error_ms.(), viscosity_error_ps.()])
    compute(s_pid, [density_error_ms.(), viscosity_error_pb.()])

    compute(s_pid, [density_error_ze.(), viscosity_error_mb.()])
    compute(s_pid, [density_error_ze.(), viscosity_error_ms.()])
    compute(s_pid, [density_error_ze.(), viscosity_error_ze.()])
    compute(s_pid, [density_error_ze.(), viscosity_error_ps.()])
    compute(s_pid, [density_error_ze.(), viscosity_error_pb.()])

    compute(s_pid, [density_error_ps.(), viscosity_error_mb.()])
    compute(s_pid, [density_error_ps.(), viscosity_error_ms.()])
    compute(s_pid, [density_error_ps.(), viscosity_error_ze.()])
    compute(s_pid, [density_error_ps.(), viscosity_error_ps.()])
    compute(s_pid, [density_error_ps.(), viscosity_error_pb.()])

    compute(s_pid, [density_error_pb.(), viscosity_error_mb.()])
    compute(s_pid, [density_error_pb.(), viscosity_error_ms.()])
    compute(s_pid, [density_error_pb.(), viscosity_error_ze.()])
    compute(s_pid, [density_error_pb.(), viscosity_error_ps.()])
    compute(s_pid, [density_error_pb.(), viscosity_error_pb.()])

  end

  defp random_between(min, max), do: (min + ((max - min) * :rand.uniform())) |> Float.round(3)

  defp compute(system_pid, antecedent_vector) do
    output = System.compute(system_pid, antecedent_vector)
    IO.puts("#{inspect(antecedent_vector)} => #{output}")
    output
  end
end
