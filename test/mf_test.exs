defmodule MfTest do
  use ExUnit.Case
  alias Flex.MembershipFun
  doctest Flex

  test "Triangle mf" do
    {mf, _c} = MembershipFun.triangle([1, 2, 3])
    assert mf.(1) == 0
    assert mf.(1.5) == 0.5
    assert mf.(2) == 1
    assert mf.(2.5) == 0.5
    assert mf.(3) == 0
    assert mf.(40) == 0
  end

  test "Trapezoidal mf" do
    {mf, _c} = MembershipFun.trapezoidal([1, 2, 3, 4])
    assert mf.(1) == 0
    assert mf.(1.5) == 0.5
    assert mf.(2) == 1
    assert mf.(2.5) == 1
    assert mf.(3) == 1
    assert mf.(3.5) == 0.5
    assert mf.(4) == 0
    assert mf.(40) == 0
  end

  test "Shoulder mf" do
    {mf, _c} = MembershipFun.shoulder([1, 2, 4])
    assert mf.(0.5) == 0
    assert mf.(1) == 0
    assert mf.(1.5) == 0.5
    assert mf.(2) == 1
    assert mf.(2.1) == 1
    assert mf.(40) == 1
  end

  test "saturation mf" do
    {mf, _c} = MembershipFun.saturation([1, 2, 4])
    assert mf.(0.5) == 1
    assert mf.(1) == 1
    assert mf.(1.5) == 0.5
    assert mf.(2) == 0
    assert mf.(2.1) == 0
    assert mf.(40) == 0
  end
end
