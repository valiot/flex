defmodule MamdaniATest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule, System}
  doctest Flex

  test "2 Controllers test" do

    # Fuzzy Variables + Fuzzy Sets

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-5, -3, -7])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-4, -2.375, -0.75])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-1, 0, 1])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0.75, 2.375, 4])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [3, 5, 7])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    residual_error =
      Variable.new(tag: "residual_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-7, 7])

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-0.15, -0.1, -0.22])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-0.125, -0.075, -0.001])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-0.002, 0, 0.002])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0.001, 0.075, 0.125])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [0.1, 0.15, 0.22])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    density_error =
      Variable.new(tag: "density_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-0.22, 0.22])

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-30, -20, -40])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-25, -13, -1])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-2, 0, 2])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [1, 13, 25])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [20, 30, 40])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    viscosity_error =
      Variable.new(tag: "viscosity_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -40..40)

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-600, -200, -1000])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-250, -120, -20])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-30, 0, 30])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [20, 125, 250])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [200, 600, 1000])

    fuzzy_sets = [nb, ns, ze, ps, pb]

    raw_material_flow_rate_delta =
      Variable.new(tag: "raw_material_flow_rate_delta", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-1000, 1000])

    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-600, -150, -1000])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-250, -70, -10])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-15, 0, 15])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [10, 70, 250])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [150, 600, 1000])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    water_flow_rate_delta =
      Variable.new(tag: "water_flow_rate_delta", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-1000, 1000])

    # Water Flow Rate Delta Controller

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
      (at1 ~> "ms" &&& at2 ~> "ps") >>> con ~> "ms"
    end

    r10 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "pb") >>> con ~> "ps"
    end

    r11 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "mb") >>> con ~> "ps"
    end

    r12 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ms") >>> con ~> "ps"
    end

    r13 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ze") >>> con ~> "ze"
    end

    r14 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "ps") >>> con ~> "ms"
    end

    r15 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "pb") >>> con ~> "ms"
    end

    r16 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "mb") >>> con ~> "ms"
    end

    r17 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ms") >>> con ~> "ps"
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

    {:ok, sw_pid} =
      System.start_link(antecedent: [density_error, viscosity_error], consequent: water_flow_rate_delta, rules: rules)

    # Raw Material Flow Rate Delta Controller

    r1 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "mb") >>> con ~> "mb"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "ms") >>> con ~> "mb"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "ze") >>> con ~> "mb"
    end

    r4 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "ps") >>> con ~> "ms"
    end

    r5 = fn [at1, at2, con] ->
      (at1 ~> "mb" &&& at2 ~> "pb") >>> con ~> "ms"
    end

    r6 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "mb") >>> con ~> "mb"
    end

    r7 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "ms") >>> con ~> "ms"
    end

    r8 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "ze") >>> con ~> "ms"
    end

    r9 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "ps") >>> con ~> "ze"
    end

    r10 = fn [at1, at2, con] ->
      (at1 ~> "ms" &&& at2 ~> "pb") >>> con ~> "ms"
    end

    r11 = fn [at1, at2, con] ->
      (at1 ~> "ze" &&& at2 ~> "mb") >>> con ~> "ms"
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
      (at1 ~> "ze" &&& at2 ~> "pb") >>> con ~> "ps"
    end

    r16 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "mb") >>> con ~> "ps"
    end

    r17 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ms") >>> con ~> "ze"
    end

    r18 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ze") >>> con ~> "ps"
    end

    r19 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "ps") >>> con ~> "ps"
    end

    r20 = fn [at1, at2, con] ->
      (at1 ~> "ps" &&& at2 ~> "pb") >>> con ~> "pb"
    end

    r21 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "mb") >>> con ~> "ps"
    end

    r22 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ms") >>> con ~> "ps"
    end

    r23 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ze") >>> con ~> "pb"
    end

    r24 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "ps") >>> con ~> "pb"
    end

    r25 = fn [at1, at2, con] ->
      (at1 ~> "pb" &&& at2 ~> "pb") >>> con ~> "pb"
    end

    rule1 = Rule.new(statement: r1, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule2 = Rule.new(statement: r2, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule3 = Rule.new(statement: r3, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule4 = Rule.new(statement: r4, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule5 = Rule.new(statement: r5, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule6 = Rule.new(statement: r6, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule7 = Rule.new(statement: r7, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule8 = Rule.new(statement: r8, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
    rule9 = Rule.new(statement: r9, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule10 =
      Rule.new(statement: r10, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule11 =
      Rule.new(statement: r11, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule12 =
      Rule.new(statement: r12, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule13 =
      Rule.new(statement: r13, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule14 =
      Rule.new(statement: r14, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule15 =
      Rule.new(statement: r15, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule16 =
      Rule.new(statement: r16, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule17 =
      Rule.new(statement: r17, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule18 =
      Rule.new(statement: r18, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule19 =
      Rule.new(statement: r19, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule20 =
      Rule.new(statement: r20, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule21 =
      Rule.new(statement: r21, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule22 =
      Rule.new(statement: r22, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule23 =
      Rule.new(statement: r23, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule24 =
      Rule.new(statement: r24, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

    rule25 =
      Rule.new(statement: r25, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

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

    {:ok, srm_pid} =
      System.start_link(antecedent: [residual_error, viscosity_error], consequent: raw_material_flow_rate_delta, rules: rules)

    # Output test

    density_error_mb = fn -> random_between(-0.22, -0.1) end
    density_error_ms = fn -> random_between(-0.125, -0.001) end
    density_error_ze = fn -> random_between(-0.002, 0.002) end
    density_error_ps = fn -> random_between(0.001, 0.125) end
    density_error_pb = fn -> random_between(0.1, 0.22) end

    viscosity_error_mb = fn -> random_between(-40, -20) end
    viscosity_error_ms = fn -> random_between(-25, -1.5) end
    viscosity_error_ze = fn -> random_between(-2, 2) end
    viscosity_error_ps = fn -> random_between(1.5, 25) end
    viscosity_error_pb = fn -> random_between(20, 40) end

    residual_error_mb = fn -> random_between(-7, -3) end
    residual_error_ms = fn -> random_between(-4, -0.5) end
    residual_error_ze = fn -> random_between(-1, 1) end
    residual_error_ps = fn -> random_between(0.5, 4) end
    residual_error_pb = fn -> random_between(3, 7) end

    IO.puts("Interview 3:\n")

    compute({srm_pid, sw_pid}, [1.44, 0.11, 11.11], 19500, 9994)
    compute({srm_pid, sw_pid}, [2.14, 0.11, 11.42], 19500, 9994)
    compute({srm_pid, sw_pid}, [0.35, 0.02, 13.28], 19500, 9994)
    compute({srm_pid, sw_pid}, [-0.31, -0.04, 11.52], 19500, 9994)
    compute({srm_pid, sw_pid}, [-1.46, -0.03, 13.14], 19500, 9994)

    compute({srm_pid, sw_pid}, [2.58, 0.06, 11.88], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.06, 0.13, 12.54], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.98, 0.02, 12.1], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.07, -0.03, 11.44], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.91, -0.07, 11.51], 19500, 9994)

    compute({srm_pid, sw_pid}, [-2, 0.1, 11.49], 19500, 9994)
    compute({srm_pid, sw_pid}, [1.11, 0.1, 13.67], 19500, 9994)
    compute({srm_pid, sw_pid}, [1.2, 0.03, -20.43], 19500, 9994)
    compute({srm_pid, sw_pid}, [0.75, -0.05, -1.75], 19500, 9994)
    compute({srm_pid, sw_pid}, [1.1, -0.07, 7.19], 19500, 9994)

    compute({srm_pid, sw_pid}, [-0.6, 0.11, -23.05], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.83, 0.05, 2.67], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.95, 0.04, -19.92], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.29, -0.05, -9.14], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.73, -0.04, 7.73], 19500, 9994)

    compute({srm_pid, sw_pid}, [3.23, 0.13, -8.24], 19500, 9994)
    compute({srm_pid, sw_pid}, [3.77, 0.11, -1.58], 19500, 9994)
    compute({srm_pid, sw_pid}, [-1.44, 0.01, -14.64], 19500, 9994)
    compute({srm_pid, sw_pid}, [-1.39, -0.04, -17.49], 19500, 9994)
    compute({srm_pid, sw_pid}, [-0.29, -0.06, -18.53], 19500, 9994)

    compute({srm_pid, sw_pid}, [2.19, 0.06, 1.73], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.57, 0.09, 6.78], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.51, 0.05, -9.61], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.04, -0.04, -10.6], 19500, 9994)
    compute({srm_pid, sw_pid}, [-2.53, -0.04, -18.9], 19500, 9994)

    IO.puts("\nComplete output test:\n")

    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_mb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_mb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_mb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_mb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_mb.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ms.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ms.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ms.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ms.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ms.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ze.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ze.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ze.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ze.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ze.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ps.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ps.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ps.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ps.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_ps.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_pb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_pb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_pb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_pb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_mb.(), density_error_pb.(), viscosity_error_pb.()])

    IO.puts(" ")
    IO.puts(" ")
    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_mb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_mb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_mb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_mb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_mb.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ms.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ms.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ms.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ms.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ms.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ze.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ze.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ze.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ze.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ze.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ps.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ps.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ps.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ps.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_ps.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_pb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_pb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_pb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_pb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ms.(), density_error_pb.(), viscosity_error_pb.()])

    IO.puts(" ")
    IO.puts(" ")
    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_mb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_mb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_mb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_mb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_mb.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ms.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ms.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ms.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ms.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ms.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ze.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ze.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ze.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ze.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ze.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ps.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ps.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ps.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ps.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_ps.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_pb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_pb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_pb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_pb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ze.(), density_error_pb.(), viscosity_error_pb.()])

    IO.puts(" ")
    IO.puts(" ")
    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_mb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_mb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_mb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_mb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_mb.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ms.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ms.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ms.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ms.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ms.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ze.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ze.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ze.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ze.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ze.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ps.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ps.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ps.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ps.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_ps.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_pb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_pb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_pb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_pb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_ps.(), density_error_pb.(), viscosity_error_pb.()])

    IO.puts(" ")
    IO.puts(" ")
    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_mb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_mb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_mb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_mb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_mb.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ms.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ms.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ms.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ms.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ms.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ze.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ze.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ze.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ze.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ze.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ps.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ps.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ps.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ps.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_ps.(), viscosity_error_pb.()])

    IO.puts(" ")

    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_pb.(), viscosity_error_mb.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_pb.(), viscosity_error_ms.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_pb.(), viscosity_error_ze.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_pb.(), viscosity_error_ps.()])
    compute({srm_pid, sw_pid}, [residual_error_pb.(), density_error_pb.(), viscosity_error_pb.()])
  end

  defp random_between(min, max), do: (min + ((max - min) * :rand.uniform())) |> Float.round(3)

  defp compute({srm_pid, sw_pid}, [residual_error, density_error, viscosity_error], offset_rm \\ 0, offset_w \\ 0) do
    srm_output = System.compute(srm_pid, [residual_error, viscosity_error])
    sw_output = System.compute(sw_pid, [density_error, viscosity_error])

    #IO.puts("#{inspect({[residual_error, viscosity_error], [density_error, viscosity_error]})} => #{inspect({srm_output + offset_rm, sw_output + offset_w})}")
    IO.puts("#{inspect({round(srm_output + offset_rm), round(sw_output + offset_w)})}")
  end
end
