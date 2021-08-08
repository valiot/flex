defmodule MandaniBTest do
  use ExUnit.Case
  import Flex.Rule
  alias Flex.{Set, Variable, Rule, System}
  doctest Flex

  test "4 controllers test" do
    # Fuzzy Variables + Fuzzy Sets

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


    # Outputs
    # Raw Material Flow Rate: Residual Error
    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-750, -500, -1000])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-625, -375, -125])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-187.5, 0, 187.5])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [125, 375, 625])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [500, 750, 1000])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    raw_material_flow_rate_delta_res =
      Variable.new(tag: "raw_material_flow_rate_delta_res", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-3000, 3000])

    # Raw Material Flow Rate: Viscosity Error
    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-750, -500, -1000])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-625, -375, -125])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-187.5, 0, 187.5])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [125, 375, 625])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [500, 750, 1000])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    raw_material_flow_rate_delta_vis =
      Variable.new(tag: "raw_material_flow_rate_delta_vis", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-3000, 3000])

    # Water Flow Rate: Density Error
    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-555.5, -370, -740])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-462.5, -277.5, -92.5])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-185, 0, 185])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [92.5, 277.5, 462.5])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [370, 555.5, 740])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    water_flow_rate_delta_dens =
      Variable.new(tag: "water_flow_rate_delta_dens", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-2000, 2000])

    # Water Flow Rate: Viscosity Error
    nb = Set.new(tag: "mb", mf_type: "saturation", mf_params: [-555.5, -370, -740])
    ns = Set.new(tag: "ms", mf_type: "triangle", mf_params: [-462.5, -277.5, -92.5])
    ze = Set.new(tag: "ze", mf_type: "triangle", mf_params: [-185, 0, 185])
    ps = Set.new(tag: "ps", mf_type: "triangle", mf_params: [92.5, 277.5, 462.5])
    pb = Set.new(tag: "pb", mf_type: "shoulder", mf_params: [370, 555.5, 740])

    fuzzy_sets = [nb, ns, ze, ps, pb]
    water_flow_rate_delta_vis =
      Variable.new(tag: "water_flow_rate_delta_vis", fuzzy_sets: fuzzy_sets, type: :consequent, range: [-2000, 2000])

    # Raw Material Flow Rate Delta Controller
    r1 = fn [at1, con] -> (at1 ~> "mb") >>> con ~> "mb"
    end
    r2 = fn [at1, con] -> (at1 ~> "ms") >>> con ~> "ms"
    end
    r3 = fn [at1, con] -> (at1 ~> "ze") >>> con ~> "ze"
    end
    r4 = fn [at1, con] -> (at1 ~> "ps") >>> con ~> "ps"
    end
    r5 = fn [at1, con] -> (at1 ~> "pb") >>> con ~> "pb"
    end

    # Raw Material Residual Error PID
    rule1 = Rule.new(statement: r1, consequent: raw_material_flow_rate_delta_res.tag, antecedent: [residual_error.tag])
    rule2 = Rule.new(statement: r2, consequent: raw_material_flow_rate_delta_res.tag, antecedent: [residual_error.tag])
    rule3 = Rule.new(statement: r3, consequent: raw_material_flow_rate_delta_res.tag, antecedent: [residual_error.tag])
    rule4 = Rule.new(statement: r4, consequent: raw_material_flow_rate_delta_res.tag, antecedent: [residual_error.tag])
    rule5 = Rule.new(statement: r5, consequent: raw_material_flow_rate_delta_res.tag, antecedent: [residual_error.tag])

    rules = [rule1,rule2,rule3,rule4,rule5]

    {:ok, srm_res_pid} =
      System.start_link(antecedent: [residual_error], consequent: raw_material_flow_rate_delta_res, rules: rules)


    # Raw Material Viscosity Error PID
    rule1 = Rule.new(statement: r1, consequent: raw_material_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule2 = Rule.new(statement: r2, consequent: raw_material_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule3 = Rule.new(statement: r3, consequent: raw_material_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule4 = Rule.new(statement: r4, consequent: raw_material_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule5 = Rule.new(statement: r5, consequent: raw_material_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])

    rules = [rule1,rule2,rule3,rule4,rule5]

    {:ok, srm_vis_pid} =
      System.start_link(antecedent: [viscosity_error], consequent: raw_material_flow_rate_delta_vis, rules: rules)


    # Water Flow Rate Delta Controller
    r1 = fn [at1, con] -> (at1 ~> "mb") >>> con ~> "pb"
    end
    r2 = fn [at1, con] -> (at1 ~> "ms") >>> con ~> "ps"
    end
    r3 = fn [at1, con] -> (at1 ~> "ze") >>> con ~> "ze"
    end
    r4 = fn [at1, con] -> (at1 ~> "ps") >>> con ~> "ms"
    end
    r5 = fn [at1, con] -> (at1 ~> "pb") >>> con ~> "mb"
    end

    # Flow Rate Density Error PID
    rule1 = Rule.new(statement: r1, consequent: water_flow_rate_delta_dens.tag, antecedent: [density_error.tag])
    rule2 = Rule.new(statement: r2, consequent: water_flow_rate_delta_dens.tag, antecedent: [density_error.tag])
    rule3 = Rule.new(statement: r3, consequent: water_flow_rate_delta_dens.tag, antecedent: [density_error.tag])
    rule4 = Rule.new(statement: r4, consequent: water_flow_rate_delta_dens.tag, antecedent: [density_error.tag])
    rule5 = Rule.new(statement: r5, consequent: water_flow_rate_delta_dens.tag, antecedent: [density_error.tag])

    rules = [rule1,rule2,rule3,rule4,rule5]

    {:ok, sw_dens_pid} =
      System.start_link(antecedent: [density_error], consequent: water_flow_rate_delta_dens, rules: rules)

    # Flow Rate Viscosity Error PID
    rule1 = Rule.new(statement: r1, consequent: water_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule2 = Rule.new(statement: r2, consequent: water_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule3 = Rule.new(statement: r3, consequent: water_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule4 = Rule.new(statement: r4, consequent: water_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])
    rule5 = Rule.new(statement: r5, consequent: water_flow_rate_delta_vis.tag, antecedent: [viscosity_error.tag])

    rules = [rule1,rule2,rule3,rule4,rule5]

    {:ok, sw_vis_pid} =
      System.start_link(antecedent: [viscosity_error], consequent: water_flow_rate_delta_vis, rules: rules)

      
    # Output Tests

    # Generate Random Numbers
    # density_error_mb = fn -> random_between(-0.22, -0.1) end
    # density_error_ms = fn -> random_between(-0.125, -0.03) end
    # density_error_ze = fn -> random_between(-0.05, 0.05) end
    # density_error_ps = fn -> random_between(0.03, 0.125) end
    # density_error_pb = fn -> random_between(0.1, 0.22) end
    #
    # viscosity_error_mb = fn -> random_between(-40, -20) end
    # viscosity_error_ms = fn -> random_between(-25, -3.5) end
    # viscosity_error_ze = fn -> random_between(-5, 5) end
    # viscosity_error_ps = fn -> random_between(3.5, 25) end
    # viscosity_error_pb = fn -> random_between(20, 40) end
    #
    # residual_error_mb = fn -> random_between(-7, -3) end
    # residual_error_ms = fn -> random_between(-4, -0.5) end
    # residual_error_ze = fn -> random_between(-1, 1) end
    # residual_error_ps = fn -> random_between(0.5, 4) end
    # residual_error_pb = fn -> random_between(3, 7) end

    # Compute with interview 3 data
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [2.14, 0.11, 11.42])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [2.14, 0.11, 11.42])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [0.35, 0.02, 13.28])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-0.31, -0.04, 11.52])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-1.46, -0.03, 13.14])

    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [2.58, 0.06, 11.88])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.06, 0.13, 12.54])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.98, 0.02, 12.1])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.07, -0.03, 11.44])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.91, -0.07, 11.51])

    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2, 0.1, 11.49])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [1.11, 0.1, 13.67])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [1.2, 0.03, -20.43])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [0.75, -0.05, -1.75])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [1.1, -0.07, 7.19])

    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-0.6, 0.11, -23.05])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.83, 0.05, 2.67])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.95, 0.04, -19.92])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.29, -0.05, -9.14])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.73, -0.04, 7.73])

    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [3.23, 0.13, -8.24])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [3.77, 0.11, -1.58])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-1.44, 0.01, -14.64])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-1.39, -0.04, -17.49])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-0.29, -0.06, -18.53])

    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [2.19, 0.06, 1.73])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.57, 0.09, 6.78])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.51, 0.05, -9.61])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.04, -0.04, -10.6])
    compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid}, [-2.53, -0.04, -18.9])
  end

  # Function for random number generator
  # defp random_between(min, max), do: (min + ((max - min) * :rand.uniform())) |> Float.round(3)

  # Function for computing fuzzy logic controller output
  defp compute({srm_res_pid, srm_vis_pid, sw_dens_pid, sw_vis_pid},[residual_error, density_error, viscosity_error]) do
    # TEST: System.compute(srm_res_pid, [residual_error])
    srm_res_output = System.compute(srm_res_pid, [residual_error])
    srm_vis_output = System.compute(srm_vis_pid, [viscosity_error])
    sw_dens_output = System.compute(sw_dens_pid, [density_error])
    sw_vis_output = System.compute(sw_vis_pid, [viscosity_error])

    # TEST: #IO.puts({inspect({[residual_error]})} => #{inspect({srm_res_output})})
    IO.puts("#{inspect({[residual_error, viscosity_error, density_error]})} => #{inspect({srm_res_output, srm_vis_output, sw_dens_output, sw_vis_output})}")
  end
end
