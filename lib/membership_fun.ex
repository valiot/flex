defmodule Flex.MembershipFun do
  @moduledoc """
  Module for membership function.
  """
  def triangle do
    fn(x, a, b, c) ->
      cond do
        #Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)
        #Medium
        x == b ->
          1
        #Right side
        b != c and b < x and x < c ->
          (c - x) / (c - b)
        #Catch all
        true ->
          0
      end
    end
  end

  def trapezoidal do
    fn(x, a, b, c, d) ->
      cond do
        #Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)
        #Medium
        b != c and b <= x and x <= c ->
          1
        #Right side
        c != d and c < x and x < d ->
          (c - x) / (c - d)
        #Catch all
        true ->
          0
      end
    end
  end
end
