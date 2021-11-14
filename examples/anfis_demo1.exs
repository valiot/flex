import Flex.Rule
require Logger

alias Flex.{EngineAdapter.ANFIS, Rule, Set, System, Variable}

inputs =
  "examples/training_data/anfis_demo1_data.csv"
  |> File.stream!()
  |> CSV.decode!()
  |> Enum.map(fn [x1, x2, _y] -> [String.to_integer(x1), String.to_integer(x2)] end)

outputs =
  "examples/training_data/anfis_demo1_data.csv"
  |> File.stream!()
  |> CSV.decode!()
  |> Enum.map(fn [_x1, _x2, y] -> String.to_float(y) end)

small = Set.new(tag: "small", mf_type: "gaussian", mf_params: [0, 1, 1])
mid = Set.new(tag: "mid", mf_type: "gaussian", mf_params: [-1, 2, 1])
large = Set.new(tag: "large", mf_type: "gaussian", mf_params: [-4, 10, 1])
extra_large = Set.new(tag: "extra_large", mf_type: "gaussian", mf_params: [-7, 7, 1])

fuzzy_sets = [small, mid, large, extra_large]
x1 = Variable.new(tag: "x1", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

small = Set.new(tag: "small", mf_type: "gaussian", mf_params: [1, 2, 1])
mid = Set.new(tag: "mid", mf_type: "gaussian", mf_params: [2, 3, 1])
large = Set.new(tag: "large", mf_type: "gaussian", mf_params: [-2, 10, 1])
extra_large = Set.new(tag: "extra_large", mf_type: "gaussian", mf_params: [-10.5, 5, 1])

fuzzy_sets = [small, mid, large, extra_large]
x2 = Variable.new(tag: "x2", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -1..6)

# Random Initialization
y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [0, 0, 0])
y2 = Set.new(tag: "y2", mf_type: "linear_combination", mf_params: [0, 0, 0])
y3 = Set.new(tag: "y3", mf_type: "linear_combination", mf_params: [0, 0, 0])
y4 = Set.new(tag: "y4", mf_type: "linear_combination", mf_params: [0, 0, 0])
y5 = Set.new(tag: "y5", mf_type: "linear_combination", mf_params: [0, 0, 0])
y6 = Set.new(tag: "y6", mf_type: "linear_combination", mf_params: [0, 0, 0])
y7 = Set.new(tag: "y7", mf_type: "linear_combination", mf_params: [0, 0, 0])
y8 = Set.new(tag: "y8", mf_type: "linear_combination", mf_params: [0, 0, 0])
y9 = Set.new(tag: "y9", mf_type: "linear_combination", mf_params: [0, 0, 0])
y10 = Set.new(tag: "y10", mf_type: "linear_combination", mf_params: [0, 0, 0])
y11 = Set.new(tag: "y11", mf_type: "linear_combination", mf_params: [0, 0, 0])
y12 = Set.new(tag: "y12", mf_type: "linear_combination", mf_params: [0, 0, 0])
y13 = Set.new(tag: "y13", mf_type: "linear_combination", mf_params: [0, 0, 0])
y14 = Set.new(tag: "y14", mf_type: "linear_combination", mf_params: [0, 0, 0])
y15 = Set.new(tag: "y15", mf_type: "linear_combination", mf_params: [0, 0, 0])
y16 = Set.new(tag: "y16", mf_type: "linear_combination", mf_params: [0, 0, 0])

fuzzy_sets = [y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11, y12, y13, y14, y15, y16]
y = Variable.new(tag: "y", fuzzy_sets: fuzzy_sets, type: :consequent, range: -10..10)

r1 = fn [at1, at2, con] ->
  tau(at1 ~> "small", at2 ~> "small") >>> con ~> "y1"
end

r2 = fn [at1, at2, con] ->
  tau(at1 ~> "small", at2 ~> "mid") >>> con ~> "y2"
end

r3 = fn [at1, at2, con] ->
  tau(at1 ~> "small", at2 ~> "large") >>> con ~> "y3"
end

r4 = fn [at1, at2, con] ->
  tau(at1 ~> "small", at2 ~> "extra_large") >>> con ~> "y4"
end

r5 = fn [at1, at2, con] ->
  tau(at1 ~> "mid", at2 ~> "small") >>> con ~> "y5"
end

r6 = fn [at1, at2, con] ->
  tau(at1 ~> "mid", at2 ~> "mid") >>> con ~> "y6"
end

r7 = fn [at1, at2, con] ->
  tau(at1 ~> "mid", at2 ~> "large") >>> con ~> "y7"
end

r8 = fn [at1, at2, con] ->
  tau(at1 ~> "mid", at2 ~> "extra_large") >>> con ~> "y8"
end

r9 = fn [at1, at2, con] ->
  tau(at1 ~> "large", at2 ~> "small") >>> con ~> "y9"
end

r10 = fn [at1, at2, con] ->
  tau(at1 ~> "large", at2 ~> "mid") >>> con ~> "y10"
end

r11 = fn [at1, at2, con] ->
  tau(at1 ~> "large", at2 ~> "large") >>> con ~> "y11"
end

r12 = fn [at1, at2, con] ->
  tau(at1 ~> "large", at2 ~> "extra_large") >>> con ~> "y12"
end

r13 = fn [at1, at2, con] ->
  tau(at1 ~> "extra_large", at2 ~> "small") >>> con ~> "y13"
end

r14 = fn [at1, at2, con] ->
  tau(at1 ~> "extra_large", at2 ~> "mid") >>> con ~> "y14"
end

r15 = fn [at1, at2, con] ->
  tau(at1 ~> "extra_large", at2 ~> "large") >>> con ~> "y15"
end

r16 = fn [at1, at2, con] ->
  tau(at1 ~> "extra_large", at2 ~> "extra_large") >>> con ~> "y16"
end

rule1 = Rule.new(statement: r1, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule2 = Rule.new(statement: r2, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule3 = Rule.new(statement: r3, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule4 = Rule.new(statement: r4, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule5 = Rule.new(statement: r5, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule6 = Rule.new(statement: r6, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule7 = Rule.new(statement: r7, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule8 = Rule.new(statement: r8, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule9 = Rule.new(statement: r9, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule10 = Rule.new(statement: r10, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule11 = Rule.new(statement: r11, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule12 = Rule.new(statement: r12, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule13 = Rule.new(statement: r13, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule14 = Rule.new(statement: r14, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule15 = Rule.new(statement: r15, consequent: y.tag, antecedents: [x1.tag, x2.tag])
rule16 = Rule.new(statement: r16, consequent: y.tag, antecedents: [x1.tag, x2.tag])

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
  rule16
]

sets_in_rules = [
  ["small", "small"],
  ["small", "mid"],
  ["small", "large"],
  ["small", "extra_large"],
  ["mid", "small"],
  ["mid", "mid"],
  ["mid", "large"],
  ["mid", "extra_large"],
  ["large", "small"],
  ["large", "mid"],
  ["large", "large"],
  ["large", "extra_large"],
  ["extra_large", "small"],
  ["extra_large", "mid"],
  ["extra_large", "large"],
  ["extra_large", "extra_large"]
]

{:ok, s_pid} =
  System.start_link(
    engine_type: ANFIS,
    antecedents: [x1, x2],
    consequent: y,
    rules: rules,
    sets_in_rules: sets_in_rules,
    learning_rate: 0.5
  )

System.hybrid_offline_learning(s_pid, inputs, outputs, 20)

predicted = Enum.map(inputs, fn(input) -> System.compute(s_pid, input) end)

predicted_dataset = for {index, predicted_data} <- Enum.zip(1..121, predicted), do: [index, predicted_data]
desired_dataset = for {index, desired_data} <- Enum.zip(1..121, outputs), do: [index, desired_data]

{:ok, _cmd} = Gnuplot.plot([
    [:set, :title, "Prediction vs Real"],
    [:set, :key, :left, :top],
    Gnuplot.plots([
        ["-", :title, "Real", :with, :line],
        ["-", :title, "Prediction1", :with, :line],
      ])
    ],
    [
      desired_dataset,
      predicted_dataset
    ])
