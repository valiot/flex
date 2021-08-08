defmodule MamdaniCTest do
    use ExUnit.Case
    import Flex.Rule
    alias Flex.{Set, Variable, Rule, System}
    doctest Flex

    test "feedback controllers test" do
        # Fuzzy variables and fuzzy sets

        # Inputs
        # Residual Error
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-5, -3, -7])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-4, -2.375, -0.75])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-1, 0, 1])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0.75, 2.375, 4])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [3, 5, 7])

        fuzzy_sets = [nb, ns, ze, ps, pb]
        residual_error =
            Variable.new(tag: "residual_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-7, 7])

        # Density Error
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-0.15, -0.1, -0.22])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-0.125, -0.05, 0.03])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-0.05, 0, 0.05])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [0.03, 0.05, 0.125])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [0.1, 0.15, 0.22])

        fuzzy_sets = [nb, ns, ze, ps, pb]
        density_error =
            Variable.new(tag: "density_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-0.22, 0.22])

        # Viscosity Error
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-30, -20, -40])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-25, -14.25, -3.5])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-5, 0, 5])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [3.5, 14.25, 25])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [20, 30, 40])

        fuzzy_sets = [nb, ns, ze, ps, pb]
        viscosity_error =
            Variable.new(tag: "viscosity_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-40, 40])

        # Water Flow Rate
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-1111, -740, -1480])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-925, -555, -185])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-370, 0, 370])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [185, 555, 925])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [740, 1111, 1480])

        fuzzy_sets = [nb, ns, ze, ps, pb]
        water_flow_rate_delta_i =
            Variable.new(tag: "water_flow_rate_delta_i", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-2000, 2000])

        # Raw Material Flow Rate
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-1500, -1000, -2000])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-1250, -750, -250])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-375, 0, 375])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [250, 750, 1250])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [1000, 1500, 2000])

        fuzzy_sets = [nb, ns, ze, ps, pb]

        raw_material_flow_rate_delta_i =
            Variable.new(tag: "raw_material_flow_rate_delta_i", fuzzy_sets: fuzzy_sets, type: :antecedent, range: [-3000, 3000])


        # Outputs
        # Water Flow Rate
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-1111, -740, -1480])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-925, -555, -185])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-370, 0, 370])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [185, 555, 925])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [740, 1111, 1480])

        fuzzy_sets = [nb, ns, ze, ps, pb]
        water_flow_rate_delta =
            Variable.new(tag: "water_flow_rate_delta", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-2000, 2000])

        # Raw Material Flow Rate
        nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-1500, -1000, -2000])
        ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-1250, -750, -250])
        ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-375, 0, 375])
        ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [250, 750, 1250])
        pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [1000, 1500, 2000])

        fuzzy_sets = [nb, ns, ze, ps, pb]

        raw_material_flow_rate_delta =
        Variable.new(tag: "raw_material_flow_rate_delta", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-3000, 3000])


        # DUAL INPUT CONTROLLERS
        # Raw Material Flow Rate Delta Controller
        r1 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "mb") >>> con ~> "mb" end
        r2 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "ms") >>> con ~> "mb" end
        r3 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "ze") >>> con ~> "mb" end
        r4 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "ps") >>> con ~> "ms" end
        r5 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "pb") >>> con ~> "ms" end
        r6 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "mb") >>> con ~> "mb" end
        r7 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "ms") >>> con ~> "ms" end
        r8 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "ze") >>> con ~> "ms" end
        r9 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "ps") >>> con ~> "ze" end
        r10 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "pb") >>> con ~> "ms" end
        r11 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "mb") >>> con ~> "ms" end
        r12 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "ms") >>> con ~> "ze" end
        r13 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "ze") >>> con ~> "ze" end
        r14 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "ps") >>> con ~> "ze" end
        r15 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "pb") >>> con ~> "ps" end
        r16 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "mb") >>> con ~> "ps" end
        r17 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "ms") >>> con ~> "ze" end
        r18 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "ze") >>> con ~> "ps" end
        r19 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "ps") >>> con ~> "ps" end
        r20 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "pb") >>> con ~> "pb" end
        r21 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "mb") >>> con ~> "ps" end
        r22 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "ms") >>> con ~> "ps" end
        r23 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "ze") >>> con ~> "pb" end
        r24 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "ps") >>> con ~> "pb" end
        r25 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "pb") >>> con ~> "pb" end

        # Normal PID
        rule1 = Rule.new(statement: r1, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule2 = Rule.new(statement: r2, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule3 = Rule.new(statement: r3, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule4 = Rule.new(statement: r4, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule5 = Rule.new(statement: r5, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule6 = Rule.new(statement: r6, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule7 = Rule.new(statement: r7, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule8 = Rule.new(statement: r8, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule9 = Rule.new(statement: r9, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule10 = Rule.new(statement: r10, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule11 = Rule.new(statement: r11, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule12 = Rule.new(statement: r12, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule13 = Rule.new(statement: r13, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule14 = Rule.new(statement: r14, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule15 = Rule.new(statement: r15, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule16 = Rule.new(statement: r16, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule17 = Rule.new(statement: r17, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule18 = Rule.new(statement: r18, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule19 = Rule.new(statement: r19, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule20 = Rule.new(statement: r20, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule21 = Rule.new(statement: r21, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule22 = Rule.new(statement: r22, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule23 = Rule.new(statement: r23, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule24 = Rule.new(statement: r24, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])
        rule25 = Rule.new(statement: r25, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, viscosity_error.tag])

        rules = [rule1,rule2,rule3,rule4,rule5,
                rule6,rule7,rule8,rule9,rule10,
            rule11,rule12,rule13,rule14,rule15,
            rule16,rule17,rule18,rule19,rule20,
            rule21,rule22,rule23,rule24,rule25]

        {:ok, srm_pid} =
            System.start_link(antecedent: [residual_error, viscosity_error], consequent: raw_material_flow_rate_delta, rules: rules)


        # Extended PID
        rule1 = Rule.new(statement: r1, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule2 = Rule.new(statement: r2, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule3 = Rule.new(statement: r3, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule4 = Rule.new(statement: r4, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule5 = Rule.new(statement: r5, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule6 = Rule.new(statement: r6, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule7 = Rule.new(statement: r7, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule8 = Rule.new(statement: r8, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule9 = Rule.new(statement: r9, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule10 = Rule.new(statement: r10, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule11 = Rule.new(statement: r11, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule12 = Rule.new(statement: r12, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule13 = Rule.new(statement: r13, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule14 = Rule.new(statement: r14, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule15 = Rule.new(statement: r15, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule16 = Rule.new(statement: r16, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule17 = Rule.new(statement: r17, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule18 = Rule.new(statement: r18, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule19 = Rule.new(statement: r19, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule20 = Rule.new(statement: r20, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule21 = Rule.new(statement: r21, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule22 = Rule.new(statement: r22, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule23 = Rule.new(statement: r23, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule24 = Rule.new(statement: r24, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])
        rule25 = Rule.new(statement: r25, consequent: raw_material_flow_rate_delta.tag, antecedent: [residual_error.tag, water_flow_rate_delta_i.tag])

        rules = [rule1,rule2,rule3,rule4,rule5,
                rule6,rule7,rule8,rule9,rule10,
            rule11,rule12,rule13,rule14,rule15,
            rule16,rule17,rule18,rule19,rule20,
            rule21,rule22,rule23,rule24,rule25]

        {:ok, srm_wd_res_pid} =
            System.start_link(antecedent: [residual_error, water_flow_rate_delta_i], consequent: raw_material_flow_rate_delta, rules: rules)


        rule1 = Rule.new(statement: r1, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule2 = Rule.new(statement: r2, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule3 = Rule.new(statement: r3, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule4 = Rule.new(statement: r4, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule5 = Rule.new(statement: r5, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule6 = Rule.new(statement: r6, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule7 = Rule.new(statement: r7, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule8 = Rule.new(statement: r8, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule9 = Rule.new(statement: r9, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule10 = Rule.new(statement: r10, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule11 = Rule.new(statement: r11, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule12 = Rule.new(statement: r12, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule13 = Rule.new(statement: r13, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule14 = Rule.new(statement: r14, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule15 = Rule.new(statement: r15, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule16 = Rule.new(statement: r16, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule17 = Rule.new(statement: r17, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule18 = Rule.new(statement: r18, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule19 = Rule.new(statement: r19, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule20 = Rule.new(statement: r20, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule21 = Rule.new(statement: r21, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule22 = Rule.new(statement: r22, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule23 = Rule.new(statement: r23, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule24 = Rule.new(statement: r24, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])
        rule25 = Rule.new(statement: r25, consequent: raw_material_flow_rate_delta.tag, antecedent: [water_flow_rate_delta_i.tag, viscosity_error.tag])

        rules = [rule1,rule2,rule3,rule4,rule5,
                rule6,rule7,rule8,rule9,rule10,
            rule11,rule12,rule13,rule14,rule15,
            rule16,rule17,rule18,rule19,rule20,
            rule21,rule22,rule23,rule24,rule25]

        {:ok, srm_wd_vis_pid} =
            System.start_link(antecedent: [water_flow_rate_delta_i, viscosity_error], consequent: raw_material_flow_rate_delta, rules: rules)

        # Water Flow Rate Delta Controller
        r1 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "mb") >>> con ~> "pb" end
        r2 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "ms") >>> con ~> "pb" end
        r3 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "ze") >>> con ~> "pb" end
        r4 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "ps") >>> con ~> "ps" end
        r5 = fn [at1, at2, con] -> (at1 ~> "mb" &&& at2 ~> "pb") >>> con ~> "ps" end
        r6 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "mb") >>> con ~> "pb" end
        r7 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "ms") >>> con ~> "ps" end
        r8 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "ze") >>> con ~> "ze" end
        r9 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "ps") >>> con ~> "ms" end
        r10 = fn [at1, at2, con] -> (at1 ~> "ms" &&& at2 ~> "pb") >>> con ~> "ps" end
        r11 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "mb") >>> con ~> "ps" end
        r12 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "ms") >>> con ~> "ps" end
        r13 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "ze") >>> con ~> "ze" end
        r14 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "ps") >>> con ~> "ms" end
        r15 = fn [at1, at2, con] -> (at1 ~> "ze" &&& at2 ~> "pb") >>> con ~> "ms" end
        r16 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "mb") >>> con ~> "ms" end
        r17 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "ms") >>> con ~> "ps" end
        r18 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "ze") >>> con ~> "ze" end
        r19 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "ps") >>> con ~> "ms" end
        r20 = fn [at1, at2, con] -> (at1 ~> "ps" &&& at2 ~> "pb") >>> con ~> "mb" end
        r21 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "mb") >>> con ~> "ms" end
        r22 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "ms") >>> con ~> "ms" end
        r23 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "ze") >>> con ~> "mb" end
        r24 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "ps") >>> con ~> "mb" end
        r25 = fn [at1, at2, con] -> (at1 ~> "pb" &&& at2 ~> "pb") >>> con ~> "mb" end

        rule1 = Rule.new(statement: r1, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule2 = Rule.new(statement: r2, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule3 = Rule.new(statement: r3, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule4 = Rule.new(statement: r4, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule5 = Rule.new(statement: r5, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule6 = Rule.new(statement: r6, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule7 = Rule.new(statement: r7, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule8 = Rule.new(statement: r8, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule9 = Rule.new(statement: r9, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule10 = Rule.new(statement: r10, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule11 = Rule.new(statement: r11, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule12 = Rule.new(statement: r12, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule13 = Rule.new(statement: r13, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule14 = Rule.new(statement: r14, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule15 = Rule.new(statement: r15, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule16 = Rule.new(statement: r16, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule17 = Rule.new(statement: r17, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule18 = Rule.new(statement: r18, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule19 = Rule.new(statement: r19, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule20 = Rule.new(statement: r20, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule21 = Rule.new(statement: r21, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule22 = Rule.new(statement: r22, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule23 = Rule.new(statement: r23, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule24 = Rule.new(statement: r24, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])
        rule25 = Rule.new(statement: r25, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, viscosity_error.tag])

        rules = [rule1,rule2,rule3,rule4,rule5,
                rule6,rule7,rule8,rule9,rule10,
            rule11,rule12,rule13,rule14,rule15,
            rule16,rule17,rule18,rule19,rule20,
            rule21,rule22,rule23,rule24,rule25]

        {:ok, sw_pid} =
            System.start_link(antecedent: [density_error, viscosity_error], consequent: water_flow_rate_delta, rules: rules)

        # Extended PID
        rule1 = Rule.new(statement: r1, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule2 = Rule.new(statement: r2, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule3 = Rule.new(statement: r3, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule4 = Rule.new(statement: r4, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule5 = Rule.new(statement: r5, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule6 = Rule.new(statement: r6, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule7 = Rule.new(statement: r7, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule8 = Rule.new(statement: r8, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule9 = Rule.new(statement: r9, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule10 = Rule.new(statement: r10, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule11 = Rule.new(statement: r11, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule12 = Rule.new(statement: r12, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule13 = Rule.new(statement: r13, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule14 = Rule.new(statement: r14, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule15 = Rule.new(statement: r15, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule16 = Rule.new(statement: r16, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule17 = Rule.new(statement: r17, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule18 = Rule.new(statement: r18, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule19 = Rule.new(statement: r19, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule20 = Rule.new(statement: r20, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule21 = Rule.new(statement: r21, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule22 = Rule.new(statement: r22, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule23 = Rule.new(statement: r23, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule24 = Rule.new(statement: r24, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])
        rule25 = Rule.new(statement: r25, consequent: water_flow_rate_delta.tag, antecedent: [density_error.tag, raw_material_flow_rate_delta_i.tag])

        rules = [rule1,rule2,rule3,rule4,rule5,
                rule6,rule7,rule8,rule9,rule10,
            rule11,rule12,rule13,rule14,rule15,
            rule16,rule17,rule18,rule19,rule20,
            rule21,rule22,rule23,rule24,rule25]

        {:ok, sw_rmd_dens_pid} =
            System.start_link(antecedent: [density_error, raw_material_flow_rate_delta_i], consequent: water_flow_rate_delta, rules: rules)


        rule1 = Rule.new(statement: r1, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule2 = Rule.new(statement: r2, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule3 = Rule.new(statement: r3, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule4 = Rule.new(statement: r4, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule5 = Rule.new(statement: r5, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule6 = Rule.new(statement: r6, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule7 = Rule.new(statement: r7, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule8 = Rule.new(statement: r8, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule9 = Rule.new(statement: r9, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule10 = Rule.new(statement: r10, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule11 = Rule.new(statement: r11, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule12 = Rule.new(statement: r12, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule13 = Rule.new(statement: r13, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule14 = Rule.new(statement: r14, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule15 = Rule.new(statement: r15, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule16 = Rule.new(statement: r16, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule17 = Rule.new(statement: r17, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule18 = Rule.new(statement: r18, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule19 = Rule.new(statement: r19, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule20 = Rule.new(statement: r20, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule21 = Rule.new(statement: r21, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule22 = Rule.new(statement: r22, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule23 = Rule.new(statement: r23, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule24 = Rule.new(statement: r24, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])
        rule25 = Rule.new(statement: r25, consequent: water_flow_rate_delta.tag, antecedent: [raw_material_flow_rate_delta_i.tag, viscosity_error.tag])

        rules = [rule1,rule2,rule3,rule4,rule5,
                rule6,rule7,rule8,rule9,rule10,
            rule11,rule12,rule13,rule14,rule15,
            rule16,rule17,rule18,rule19,rule20,
            rule21,rule22,rule23,rule24,rule25]

        {:ok, sw_rmd_vis_pid} =
            System.start_link(antecedent: [raw_material_flow_rate_delta_i, viscosity_error], consequent: water_flow_rate_delta, rules: rules)
        
        # OUTPUT TEST

        # Test compute data
        compute({srm_pid, sw_pid, srm_wd_res_pid, srm_wd_vis_pid, sw_rmd_dens_pid, sw_rmd_vis_pid}, [3.23, 0.13, -8.24])
    end

    defp compute({srm_pid, sw_pid, srm_wd_res_pid, srm_wd_vis_pid, sw_rmd_dens_pid, sw_rmd_vis_pid},[residual_error, density_error, viscosity_error]) do
        srm_output = System.compute(srm_pid, [residual_error, viscosity_error])
        sw_output = System.compute(sw_pid, [density_error, viscosity_error])

        srm_wd_res_out = System.compute(srm_wd_res_pid, [residual_error, sw_output])
        srm_wd_vis_out = System.compute(srm_wd_vis_pid, [sw_output, viscosity_error])
        sw_rmd_dens_out = System.compute(sw_rmd_dens_pid, [density_error, srm_output])
        sw_rmd_vis_out = System.compute(sw_rmd_vis_pid, [srm_output, viscosity_error])

        IO.puts("#{inspect({[residual_error, viscosity_error], [density_error, viscosity_error]})} => #{inspect({srm_output, sw_output, srm_wd_res_out, srm_wd_vis_out, sw_rmd_dens_out, sw_rmd_vis_out})}")
    end

end
