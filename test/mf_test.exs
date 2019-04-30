defmodule MfTest do
  use ExUnit.Case
  alias Flex.MembershipFun
  doctest Flex

  test "Triangle mf" do
    mf = MembershipFun.triangle
    assert mf.(1, 1, 2, 3) == 0
    assert mf.(1.5, 1, 2, 3) == 0.5
    assert mf.(2, 1, 2, 3) == 1
    assert mf.(2.5, 1, 2, 3) == 0.5
    assert mf.(3, 1, 2, 3) == 0
    assert mf.(40, 1, 2, 3) == 0
  end

  test "Trapezoidal mf" do
    mf = MembershipFun.trapezoidal()
    assert mf.(1, 1, 2, 3, 4) == 0
    assert mf.(1.5, 1, 2, 3, 4) == 0.5
    assert mf.(2, 1, 2, 3, 4) == 1
    assert mf.(2.5, 1, 2, 3, 4) == 1
    assert mf.(3, 1, 2, 3, 4) == 1
    assert mf.(3.5, 1, 2, 3, 4) == 0.5
    assert mf.(4, 1, 2, 3, 4) == 0
    assert mf.(40, 1, 2, 3, 4) == 0
  end
end
