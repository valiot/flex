defmodule Flex.MembershipFun do
  @moduledoc """
  An interface to create Membership Functions reference.
  """

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
end
