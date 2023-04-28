defmodule MfTest do
  use ExUnit.Case
  alias Flex.{MembershipFun, Set}
  import Float
  import :math, only: [log: 1]
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
    assert mf.(1.25) == 0.25
    assert mf.(1.5) == 0.5
    assert mf.(1.75) == 0.75
    assert mf.(2) == 1
    assert mf.(2.1) == 1
    assert mf.(40) == 1
  end

  test "Saturation mf" do
    {mf, _c} = MembershipFun.saturation([1, 2, 4])
    assert mf.(0.5) == 1
    assert mf.(1) == 1
    assert mf.(1.25) == 0.75
    assert mf.(1.5) == 0.5
    assert mf.(1.75) == 0.25
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

  test "Gaussian mdf" do
    m = 0
    s = 2
    f = 1

    small = Set.new(tag: "small", mf_type: "gaussian", mf_params: [m, s, f])

    x = 1
    mu = small.mf.(x)

    assert MembershipFun.derivative(small, x, mu, 0) == 0.22062422564614886
    assert MembershipFun.derivative(small, x, mu, 1) == 0.11031211282307443
    assert MembershipFun.derivative(small, x, mu, 2) == 0

    x = 2
    mu = small.mf.(x)

    assert MembershipFun.derivative(small, x, mu, 0) == 0.3032653298563167
    assert MembershipFun.derivative(small, x, mu, 1) == 0.3032653298563167
    assert MembershipFun.derivative(small, x, mu, 2) == 0
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

  test "Generalized Bell mdf" do
    c = 0
    s = 1
    b = 0.1

    small = Set.new(tag: "small", mf_type: "bell", mf_params: [c, s, b])

    x = 1
    a = b
    b = s
    mu = miu(x, a, b, c)

    assert dmui_dcij(x, a, b, c) |> Float.round(12) ==
             MembershipFun.derivative(small, x, mu, 0) |> Float.round(12)

    assert dmui_dbij(x, a, b, c) |> Float.round(12) ==
             MembershipFun.derivative(small, x, mu, 1) |> Float.round(12)

    assert dmui_daij(x, a, b, c) |> Float.round(12) ==
             MembershipFun.derivative(small, x, mu, 2) |> Float.round(12)

    x = 0
    a = b
    b = s
    mu = miu(x, a, b, c)
    assert dmui_dcij(x, a, b, c) == MembershipFun.derivative(small, x, mu, 0)
    assert dmui_dbij(x, a, b, c) == MembershipFun.derivative(small, x, mu, 1)
    assert dmui_daij(x, a, b, c) == MembershipFun.derivative(small, x, mu, 2)
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

  test "Linear combination mf (for Takagi-Sugeno Inference system)" do
    # With offset
    {mf, c} = MembershipFun.linear_combination([1, 2, 3, 100])
    assert c == nil
    assert mf.([1, 2, 3]) == 114

    # Without offset
    {mf, c} = MembershipFun.linear_combination([1, 2, 3, 0])
    assert c == nil
    assert mf.([1, 2, 3]) == 14

    # Offset only
    {mf, c} = MembershipFun.linear_combination([0, 0, 0, 100])
    assert c == nil
    assert mf.([1, 2, 3]) == 100
  end

  test "Linear combination mf exceptions" do
    {mf, c} = MembershipFun.linear_combination([1, 2, 2, 100])
    assert c == nil

    assert_raise ArgumentError, "Invalid input_vector data type: 30, it must be a list.", fn ->
      mf.(30)
    end

    desired_exceptions =
      "Invalid size between the coefficients: [1, 2, 2, 100] and the input_vector: [1, 2] (length(input_vector) + 1 == length(coefficients))"

    assert_raise ArgumentError, desired_exceptions, fn -> mf.([1, 2]) end
  end

  def dmui_daij(x, a, b, c), do: 2 * b * pow(fi(x, a, c), 2 * b) * pow(miu(x, a, b, c), 2) / a

  def dmui_dbij(x, _a, _b, c) when x == c, do: 0

  def dmui_dbij(x, a, b, c),
    do: -2 * pow(fi(x, a, c), 2 * b) * pow(miu(x, a, b, c), 2) * log(fi(x, a, c))

  def dmui_dcij(x, _a, _b, c) when x == c, do: 0

  def dmui_dcij(x, a, b, c),
    do: 2 * b * pow(fi(x, a, c), 2 * b) * pow(miu(x, a, b, c), 2) / (x - c)

  def fi(x, a, c), do: (x - c) / a
  def miu(x, a, b, c), do: 1 / (1 + pow(fi(x, a, c), 2 * b))
end
