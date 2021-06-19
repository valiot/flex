defmodule Flex.MembershipFun do
  @moduledoc """
  An interface to create Membership Functions reference.
  """
  import :math

  @doc """
  Shoulder membership function.
  """
  @spec shoulder([...]) :: {fun(), any}
  def shoulder([a, b, c]) do
    mu = fn x ->
      cond do
        # Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)

        # Right side
        x >= b ->
          1

        # Catch all
        true ->
          0
      end
    end

    {mu, c}
  end

  @doc """
  Saturation membership function.
  """
  @spec saturation([...]) :: {fun(), any}
  def saturation([a, b, c]) do
    mu = fn x ->
      cond do
        # Left side
        x <= a ->
          1

        # Right side
        a != b and a < x and x < b ->
          (a - x) / (a - b)

        # Catch all
        true ->
          0
      end
    end

    {mu, c}
  end

  @doc """
  Triangle membership function.
  """
  @spec triangle([...]) :: {fun(), any}
  def triangle([a, b, c]) do
    mu = fn x ->
      cond do
        # Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)

        # Medium
        x == b ->
          1

        # Right side
        b != c and b < x and x < c ->
          (c - x) / (c - b)

        # Catch all
        true ->
          0
      end
    end

    {mu, b}
  end

  @doc """
  Trapezoidal membership function.
  """
  @spec trapezoidal([...]) :: {fun(), any}
  def trapezoidal([a, b, c, d]) do
    ctr = (c - b) / 2

    mu = fn x ->
      cond do
        # Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)

        # Medium
        b != c and b <= x and x <= c ->
          1

        # Right side
        c != d and c < x and x < d ->
          (c - x) / (c - d)

        # Catch all
        true ->
          0
      end
    end

    {mu, ctr}
  end

  @doc """
  Gaussian membership function.
    * `m` - (number) Mean,
    * `s` - (number) Standard deviation, it must not be equal to 0.
    * `f` - (number) Fuzzification Factor,
  """
  @spec gaussian([...]) :: {fun(), any}
  def gaussian([m, s, f]) when s != 0 do
    mu = fn x ->
      (pow(x - m, 2) / pow(s, 2))
      |> abs()
      |> pow(f)
      |> Kernel.*(-0.5)
      |> exp()
    end

    {mu, m}
  end

  def gaussian([_c, s, _m]), do: raise(ArgumentError, "Bad standard deviation: #{s}")

  @doc """
  Generalized Bell membership function.
    * `c` - (number) Center.
    * `s` - (number) Slope.
    * `b` - (number) The width of the curve, it must not be equal to 0.

  Definition of Generalized Bell function is:
        y(x) = 1 / (1 + |((x - c) / b)|^(2 * s))
  """
  @spec gbell([...]) :: {fun(), any}
  def gbell([c, s, b]) when b != 0 do
    mu = fn x ->
      ((x - c) / b)
      |> abs()
      |> pow(2 * s)
      |> Kernel.+(1)
      |> pow(-1)
    end

    {mu, c}
  end

  def gbell([_c, _s, b]), do: raise(ArgumentError, "Bad width of the curve: #{b}")

  @doc """
  Sigmoidal membership function.
    * `c` - (number) Crossover point.
    * `s` - (number) Slope.

  Definition of Generalized Bell function is:
        y(x) = 1 / (1 + e^(-s(x-c)))
  """
  @spec sigmoid([...]) :: {fun(), any}
  def sigmoid([c, s, _]) do
    mu = fn x ->
      (-s * (x - c))
      |> exp()
      |> Kernel.+(1)
      |> pow(-1)
    end

    {mu, c}
  end
end
