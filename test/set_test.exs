defmodule SetTest do
  use ExUnit.Case
  alias Flex.Set
  doctest Flex

  test "new Set" do
    fs = Set.new(tag: "nb", mf_type: "trapezoidal", mf_params: [1, 2, 3, 4])

    assert fs.tag == "nb"
    assert fs.mf_type != "trapezoidl"
  end

  test "configure a membership funtion to a Set" do
    fs = Set.new(tag: "nb", mf_type: "trapezoidal", mf_params: [1, 2, 3, 4])
    assert fs.mf.(2.5) == 1
  end

  test "example" do
    t_h = Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0, 4])
    j_r = Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
    t_c = Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2, 4])

    assert t_h.mf.(-1) == 0.5
    assert j_r.mf.(-1) == 0.5
    assert t_c.mf.(-1) == 0

    assert t_h.mf.(5) == 0
    assert j_r.mf.(5) == 0
    assert t_c.mf.(5) == 1
  end

  test "update a Set with gradients (ANFIS)" do
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [1, 1, 1])

    new_y1 = Set.update(y1, [0.0, 0.0, 0.97], 0.05)

    assert new_y1.mf_params == [1.0, 1.0, 0.9515]
  end

  test "update a Set (ANFIS)" do
    y1 = Set.new(tag: "y1", mf_type: "linear_combination", mf_params: [1, 1, 1])

    new_y1 = Set.update(y1, [0.0, 0.0, 0.97])

    assert new_y1.mf_params == [0.0, 0.0, 0.97]
  end
end
