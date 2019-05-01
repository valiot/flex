defmodule VariableTest do
  use ExUnit.Case
  alias Flex.{Variable, Set}
  doctest Flex

  test "fuzzification test" do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2])

    fuzzy_sets = [t_h, j_r, t_c]
    {:ok, error} = Variable.start_link(fuzzy_sets: fuzzy_sets, type: :antecedent, range: 1..2)
    IO.inspect(Variable.state(error), label: "var: ")
  end

end
