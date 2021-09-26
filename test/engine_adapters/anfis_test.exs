defmodule AnfisTest do
  use ExUnit.Case
  import Flex.Rule
  import :math
  alias Flex.{Set, Variable, Rule, System, EngineAdapter.ANFIS}

  # test "Read Train Data System test" do
  #   # data = read_test_data("anfis_data1.txt")
  #   x = 4
  #   a = 5
  #   b = 2
  #   c = 3
  #   IO.inspect {miu(x, a, b, c), fi(x, a, c) }
  #   IO.inspect { dmui_daij(x, a, b, c), do1_daij(x, a, b, c)}
  #   IO.inspect { dmui_dbij(x, a, b, c), do1_dbij(x, a, b, c)}
  #   IO.inspect { dmui_dcij(x, a, b, c), do1_dcij(x, a, b, c)}
  # end

  def read_test_data(file) when is_binary(file) do
    data_path = Path.join(["test", "test_data", file])

    File.cwd!()
    |> Path.join(data_path)
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn data_in_rows ->
      data_in_rows
      |> String.split(" ")
      |> Enum.map(&String.to_float/1)
    end)
  end

  def dmui_daij(x, a, b, c), do: 2 * b * pow(fi(x, a, c), 2 * b) * pow(miu(x, a, b, c), 2) / a
  def do1_daij(x, a, b, c), do: 2 * b * miu(x, a, b, c) * (1 - miu(x, a, b, c)) / a

  def dmui_dbij(x, a, b, c),
    do: -2 * pow(fi(x, a, c), 2 * b) * pow(miu(x, a, b, c), 2) * log(fi(x, a, c))

  def do1_dbij(x, a, b, c), do: -2 * log(fi(x, a, c)) * miu(x, a, b, c) * (1 - miu(x, a, b, c))

  def dmui_dcij(x, a, b, c),
    do: 2 * b * pow(fi(x, a, c), 2 * b) * pow(miu(x, a, b, c), 2) / (x - c)

  def do1_dcij(x, a, b, c), do: 2 * b * miu(x, a, b, c) * (1 - miu(x, a, b, c)) / (x - c)

  def fi(x, a, c), do: (x - c) / a
  def miu(x, a, b, c), do: 1 / (1 + pow(fi(x, a, c), 2 * b))

  setup do
    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0, 1, 0.1])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1, 1, 0.1])

    fuzzy_sets = [small, large]
    x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0, 1, 0.1])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1, 1, 0.1])

    fuzzy_sets = [small, large]
    x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -1..6)

    # Random Initialization
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [1, 1, 1])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [1, 1, 1])
    y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [1, 1, 1])
    y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [1, 1, 1])

    fuzzy_sets = [y1, y2, y3, y4]
    output = Variable.new(tag: "y", fuzzy_sets: fuzzy_sets, type: :consequent, range: -10..10)

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

    rule1 = Rule.new(statement: r1, consequent: output.tag, antecedents: [x1.tag, x2.tag])
    rule2 = Rule.new(statement: r2, consequent: output.tag, antecedents: [x1.tag, x2.tag])
    rule3 = Rule.new(statement: r3, consequent: output.tag, antecedents: [x1.tag, x2.tag])
    rule4 = Rule.new(statement: r4, consequent: output.tag, antecedents: [x1.tag, x2.tag])

    rules = [rule1, rule2, rule3, rule4]

    %{ant: [x1, x2], cons: output, rules: rules}
  end

  test "ANFIS XOR forward pass (consequence backpropagation)", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
    :ok = System.set_engine_type(s_pid, ANFIS)

    refute System.compute(s_pid, [0, 0]) == 0
    {:ok, state} = System.get_state(s_pid)

    target = 0

    dE_do5 = -(target - state.engine_output.crisp_output)

    new_consequent = ANFIS.forward_pass(dE_do5, state.learning_rate, state.engine_output)

    refute state.consequent == new_consequent
  end

  # test "ANFIS XOR backward pass (premise backpropagation)", %{ant: ant, cons: output, rules: rules} do
  #   {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
  #   :ok = System.set_engine_type(s_pid, ANFIS)

  #   refute System.compute(s_pid, [0, 0]) == 0
  #   {:ok, state} = System.get_state(s_pid)

  #   target = 0

  #   dE_do5 = -(target - state.engine_output.crisp_output)

  #   new_antecedents = ANFIS.backward_pass(dE_do5, state.learning_rate, state.engine_output)

  #   assert state.antecedents == new_antecedents
  # end

  test "ANFIS XOR training function", %{ant: ant, cons: output, rules: rules} do
    {:ok, s_pid} = System.start_link(antecedents: ant, consequent: output, rules: rules)
    :ok = System.set_engine_type(s_pid, ANFIS)

    refute System.compute(s_pid, [0, 0]) == 0
    assert System.adapt(s_pid, 0) == {:ok, 1.0}

    refute System.compute(s_pid, [0, 0]) == 0
    assert System.adapt(s_pid, 0) == {:ok, 0.9528291420118343}

    # train for 100 epochs
    for _  <- 0..100 do
      System.compute(s_pid, [0, 0])
      System.adapt(s_pid, 0)
      System.compute(s_pid, [0, 1])
      System.adapt(s_pid, 1)
      System.compute(s_pid, [1, 0])
      System.adapt(s_pid, 1)
      System.compute(s_pid, [1, 1])
      System.adapt(s_pid, 0)
    end

    assert System.compute(s_pid, [0, 0]) |> round == 0
    assert System.compute(s_pid, [0, 1]) |> round == 1
    assert System.compute(s_pid, [1, 0]) |> round == 1
    assert System.compute(s_pid, [1, 1]) |> round == 0
  end

  test "ANFIS XOR forward propagation" do
    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0, 1, 0.1])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1, 1, 0.1])

    fuzzy_sets = [small, large]
    x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0, 1, 0.1])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1, 1, 0.1])

    fuzzy_sets = [small, large]
    x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -1..6)

    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [0, 0, 0])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [0, 0, 1])

    fuzzy_sets = [y1, y2]
    output = Variable.new(tag: "y", fuzzy_sets: fuzzy_sets, type: :consequent, range: -10..10)

    r1 = fn [at1, at2, con] ->
      (at1 ~> "small" &&& at2 ~> "small") >>> con ~> "y1"
    end

    r2 = fn [at1, at2, con] ->
      (at1 ~> "small" &&& at2 ~> "large") >>> con ~> "y2"
    end

    r3 = fn [at1, at2, con] ->
      (at1 ~> "large" &&& at2 ~> "small") >>> con ~> "y2"
    end

    r4 = fn [at1, at2, con] ->
      (at1 ~> "large" &&& at2 ~> "large") >>> con ~> "y1"
    end

    rule1 = Rule.new(statement: r1, consequent: output.tag, antecedents: [x1.tag, x2.tag])
    rule2 = Rule.new(statement: r2, consequent: output.tag, antecedents: [x1.tag, x2.tag])
    rule3 = Rule.new(statement: r3, consequent: output.tag, antecedents: [x1.tag, x2.tag])
    rule4 = Rule.new(statement: r4, consequent: output.tag, antecedents: [x1.tag, x2.tag])

    rules = [rule1, rule2, rule3, rule4]

    {:ok, s_pid} =
      System.start_link(antecedents: [x1, x2], consequent: output, rules: rules, engine_type: ANFIS)

    assert System.compute(s_pid, [0, 0]) |> round() == 0
    assert System.compute(s_pid, [0, 1]) |> round() == 1
    assert System.compute(s_pid, [1, 0]) |> round() == 1
    assert System.compute(s_pid, [1, 1]) |> round() == 0
  end
end
