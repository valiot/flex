defmodule SetTest do
  use ExUnit.Case
  alias Flex.Set
  doctest Flex

  test "new Set" do
    fs = Set.new(tag: "nb", mf_type: "trapezoidal")

    assert fs == %Set{tag: "nb", mf_type: "trapezoidal"}
    assert fs != %Set{tag: "nb", mf_type: "trapezoidl"}
  end

  test "configure a membership funtion to a Set" do
    fs = Set.new(tag: "nb", mf_type: "trapezoidal")
    fs = %{fs | mf_params: [1,2,3,4]}
    n_fs = Set.set_mf(fs)
    assert fs != n_fs
    assert n_fs.mf.(2.5) == 1
  end

end
