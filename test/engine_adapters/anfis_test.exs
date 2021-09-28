defmodule AnfisTest do
  use ExUnit.Case
  import Flex.Rule

  alias Flex.{Set, Variable, Rule, System, EngineAdapter.ANFIS}

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

  test "ANFIS XOR forward pass (consequence backpropagation)" do
    # the membership functions have a valid initialization
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

    {:ok, s_pid} = System.start_link(antecedents: [x1, x2], consequent: output, rules: rules)
    :ok = System.set_engine_type(s_pid, ANFIS)

    refute System.compute(s_pid, [0, 0]) == 0
    {:ok, state} = System.get_state(s_pid)

    target = 0

    dE_do5 = -(target - state.engine_output.crisp_output)

    new_consequent = ANFIS.forward_pass(dE_do5, state.learning_rate, state.engine_output)

    refute state.consequent == new_consequent
  end

  test "ANFIS XOR backward pass (premise backpropagation)" do
    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0.2, 1, 0.8])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [2, 1, 0.9])

    fuzzy_sets = [small, large]
    x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    small = Set.new(tag: "small", mf_type: "bell", mf_params: [-2, 1, 0.9])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [2, 1, 0.8])

    fuzzy_sets = [small, large]
    x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -1..6)

    # This function shall prepare
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [0, 0, 0])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [0, 0, 1])
    y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [0, 0, 1])
    y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [0, 0, 0])

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

    sets_in_rules = [
      ["small", "small"],
      ["small", "large"],
      ["large", "small"],
      ["large", "large"]
    ]

    {:ok, s_pid} = System.start_link(antecedents: [x1, x2], consequent: output, rules: rules, sets_in_rules: sets_in_rules, learning_rate: 0.5)
    :ok = System.set_engine_type(s_pid, ANFIS)

    #System.compute(s_pid, [0, 0]) |> IO.inspect()
    #System.compute(s_pid, [0, 1]) |> IO.inspect()
    #System.compute(s_pid, [1, 0]) |> IO.inspect()
    #System.compute(s_pid, [1, 1]) |> IO.inspect()

    refute System.compute(s_pid, [0, 0]) == 0
    {:ok, state} = System.get_state(s_pid)

    target = 0

    dE_do5 = -(target - state.engine_output.crisp_output)

    new_antecedents = ANFIS.backward_pass(dE_do5, state, state.engine_output)

    refute state.antecedents == new_antecedents
  end

  test "ANFIS XOR forward pass online training only" do
    # the membership functions have a valid initialization
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

    {:ok, s_pid} = System.start_link(antecedents: [x1, x2], consequent: output, rules: rules)
    :ok = System.set_engine_type(s_pid, ANFIS)

    refute System.compute(s_pid, [0, 0]) |> round == 0
    refute System.compute(s_pid, [0, 1]) |> round == 1
    refute System.compute(s_pid, [1, 0]) |> round == 1
    refute System.compute(s_pid, [1, 1]) |> round == 0

    refute System.compute(s_pid, [0, 0]) == 0
    assert System.forward_pass(s_pid, 0) == {:ok, 1.0}

    refute System.compute(s_pid, [0, 0]) == 0
    assert System.forward_pass(s_pid, 0) != {:ok, 1.0}

    IO.puts("\nPre-Training\n")

    System.compute(s_pid, [0, 0]) |> IO.inspect()
    System.compute(s_pid, [0, 1]) |> IO.inspect()
    System.compute(s_pid, [1, 0]) |> IO.inspect()
    System.compute(s_pid, [1, 1]) |> IO.inspect()


    # train for 100 epochs
    for _  <- 0..100 do
      System.compute(s_pid, [0, 0])
      System.forward_pass(s_pid, 0)
      System.compute(s_pid, [0, 1])
      System.forward_pass(s_pid, 1)
      System.compute(s_pid, [1, 0])
      System.forward_pass(s_pid, 1)
      System.compute(s_pid, [1, 1])
      System.forward_pass(s_pid, 0)
    end

    IO.puts("\nPost-Training\n")

    System.compute(s_pid, [0, 0]) |> IO.inspect()
    System.compute(s_pid, [0, 1]) |> IO.inspect()
    System.compute(s_pid, [1, 0]) |> IO.inspect()
    System.compute(s_pid, [1, 1]) |> IO.inspect()

    #System.get_state(s_pid) |> IO.inspect()

    assert System.compute(s_pid, [0, 0]) |> round == 0
    assert System.compute(s_pid, [0, 1]) |> round == 1
    assert System.compute(s_pid, [1, 0]) |> round == 1
    assert System.compute(s_pid, [1, 1]) |> round == 0
  end

  test "ANFIS XOR back pass online training only" do
    # the membership functions have a valid initialization
    small = Set.new(tag: "small", mf_type: "bell", mf_params: [-1, 5, 0.9])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1.5, 1, 0.9])

    fuzzy_sets = [small, large]
    x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0.3, 1, 0.9])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1.5, 5, 0.9])

    fuzzy_sets = [small, large]
    x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -1..6)

    # Random Initialization
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [0, 0, 0])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [0, 0, 1])
    y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [0, 0, 1])
    y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [0, 0, 0])

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

    sets_in_rules = [
      ["small", "small"],
      ["small", "large"],
      ["large", "small"],
      ["large", "large"]
    ]

    {:ok, s_pid} = System.start_link(antecedents: [x1, x2], consequent: output, rules: rules, sets_in_rules: sets_in_rules, learning_rate: 0.05)
    :ok = System.set_engine_type(s_pid, ANFIS)

    IO.puts("\nPre-Training\n")

    System.compute(s_pid, [0, 0]) |> IO.inspect()
    System.compute(s_pid, [0, 1]) |> IO.inspect()
    System.compute(s_pid, [1, 0]) |> IO.inspect()
    System.compute(s_pid, [1, 1]) |> IO.inspect()

    # train for 100 epochs
    for _  <- 0..500 do
      System.compute(s_pid, [0, 0])
      System.hybrid_online_learning(s_pid, 0)
      System.compute(s_pid, [0, 1])
      System.hybrid_online_learning(s_pid, 1)
      System.compute(s_pid, [1, 0])
      System.hybrid_online_learning(s_pid, 1)
      System.compute(s_pid, [1, 1])
      System.hybrid_online_learning(s_pid, 0)
    end

    IO.puts("\nPost-Training\n")

    System.compute(s_pid, [0, 0]) |> IO.inspect()
    System.compute(s_pid, [0, 1]) |> IO.inspect()
    System.compute(s_pid, [1, 0]) |> IO.inspect()
    System.compute(s_pid, [1, 1]) |> IO.inspect()

    assert System.compute(s_pid, [0, 0]) |> round == 0
    assert System.compute(s_pid, [0, 1]) |> round == 1
    assert System.compute(s_pid, [1, 0]) |> round == 1
    assert System.compute(s_pid, [1, 1]) |> round == 0
  end

  test "ANFIS XOR hybrid online training" do
    # the membership functions have a random parameters
    small = Set.new(tag: "small", mf_type: "bell", mf_params: [-1, 5, 0.9])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1.5, 1, 0.9])

    fuzzy_sets = [small, large]
    x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

    small = Set.new(tag: "small", mf_type: "bell", mf_params: [0.3, 1, 0.9])
    large = Set.new(tag: "large", mf_type: "bell", mf_params: [1.5, 5, 0.9])

    fuzzy_sets = [small, large]
    x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -1..6)

    # Random Initialization
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [1, 1, 0])
    y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [1, 0.51, 0.49])
    y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [0.49, 1, 0.51])
    y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [-0.014, -0.014, -0.03])

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

    sets_in_rules = [
      ["small", "small"],
      ["small", "large"],
      ["large", "small"],
      ["large", "large"]
    ]

    {:ok, s_pid} = System.start_link(antecedents: [x1, x2], consequent: output, rules: rules, sets_in_rules: sets_in_rules, learning_rate: 0.5)
    :ok = System.set_engine_type(s_pid, ANFIS)

    IO.puts("\nPre-Training\n")

    System.compute(s_pid, [0, 0]) |> IO.inspect()
    System.compute(s_pid, [0, 1]) |> IO.inspect()
    System.compute(s_pid, [1, 0]) |> IO.inspect()
    System.compute(s_pid, [1, 1]) |> IO.inspect()

    # train for 550 epochs
    for _  <- 0..500 do
      System.compute(s_pid, [0, 0])
      System.hybrid_online_learning(s_pid, 0)
      System.compute(s_pid, [0, 1])
      System.hybrid_online_learning(s_pid, 1)
      System.compute(s_pid, [1, 0])
      System.hybrid_online_learning(s_pid, 1)
      System.compute(s_pid, [1, 1])
      System.hybrid_online_learning(s_pid, 0)
    end

    IO.puts("\nPost-Training\n")

    System.compute(s_pid, [0, 0]) |> IO.inspect()
    System.compute(s_pid, [0, 1]) |> IO.inspect()
    System.compute(s_pid, [1, 0]) |> IO.inspect()
    System.compute(s_pid, [1, 1]) |> IO.inspect()

    assert System.compute(s_pid, [0, 0]) |> round == 0
    assert System.compute(s_pid, [0, 1]) |> round == 1
    assert System.compute(s_pid, [1, 0]) |> round == 1
    assert System.compute(s_pid, [1, 1]) |> round == 0
  end
end
