defmodule MfTest do
  use ExUnit.Case
  alias Flex.MembershipFun
  import Float
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

  test "Saturation mf" do
    {mf, _c} = MembershipFun.saturation([1, 2, 4])
    assert mf.(0.5) == 1
    assert mf.(1) == 1
    assert mf.(1.5) == 0.5
    assert mf.(2) == 0
    assert mf.(2.1) == 0
    assert mf.(40) == 0
  end

  test "Gaussian mf" do
    {mf, c} = MembershipFun.gaussian([10, 4, 1])
    assert c == 10
    assert mf.(-5) |> round(3) == 0.001
    assert mf.(0) |> round(3) == 0.044
    assert mf.(5) |> round(3) == 0.458
    assert mf.(10) |> round(3) == 1
    assert mf.(15) |> round(3) == 0.458
    assert mf.(20) |> round(3) == 0.044
    assert mf.(25) |> round(3) == 0.001
  end

  test "Generalized Bell mf" do
    {mf, c} = MembershipFun.gbell([50, 4, 8])
    assert c == 50
    assert mf.(20) |> round(3) == 0.000
    assert mf.(30) |> round(3) == 0.001
    assert mf.(40) |> round(3) == 0.144
    assert mf.(50) |> round(3) == 1
    assert mf.(60) |> round(3) == 0.144
    assert mf.(70) |> round(3) == 0.001
    assert mf.(80) |> round(3) == 0.000
  end

  test "Sigmoidal mf" do
    {mf, c} = MembershipFun.sigmoid([50, 2, nil])
    assert c == 50
    assert mf.(20) |> round(3) == 0.000
    assert mf.(30) |> round(3) == 0.000
    assert mf.(40) |> round(3) == 0.000
    assert mf.(50) |> round(3) == 0.500
    assert mf.(60) |> round(3) == 1
    assert mf.(70) |> round(3) == 1
    assert mf.(80) |> round(3) == 1
    assert mf.(90) |> round(3) == 1
  end

  test "Z-shaped mf" do
    {mf, c} = MembershipFun.z_shaped([30, 70, nil])
    assert c == 50
    assert mf.(20) == 1
    assert mf.(30) == 1
    assert mf.(40) == 0.875
    assert mf.(50) == 0.500
    assert mf.(60) == 0.125
    assert mf.(70) == 0
    assert mf.(80) == 0
    assert mf.(90) == 0
  end

  test "S-shaped mf" do
    {mf, c} = MembershipFun.s_shaped([30, 70, nil])
    assert c == 50
    assert mf.(20) == 0
    assert mf.(30) == 0
    assert mf.(40) == 0.125
    assert mf.(50) == 0.500
    assert mf.(60) == 0.875
    assert mf.(70) == 1
    assert mf.(80) == 1
    assert mf.(90) == 1
  end

  test "Pi-shaped mf" do
    {mf, c} = MembershipFun.pi_shaped([30, 60, 70, 100])
    assert c == 65
    assert mf.(30) == 0
    assert mf.(40) == 0.2222222222222222
    assert mf.(50) == 0.7777777777777778
    assert mf.(60) == 1
    assert mf.(70) == 1
    assert mf.(80) == 0.7777777777777778
    assert mf.(90) == 0.2222222222222222
    assert mf.(99) == 0.0022222222222222222
  end
end
