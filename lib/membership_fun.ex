defmodule Flex.MembershipFun do
  @moduledoc """
  Module for membership functions.
  #TODO: make mf with its own parameters
  """
  def shoulder([a, b]) do
    [a, b]
    fn(x) ->
      cond do
        #Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)
        #Right side
        x >= b ->
          1
        #Catch all
        true ->
          0
      end
    end
  end

  def saturation([a, b]) do
    fn(x) ->
      cond do
        #Left side
        x <= a ->
          1
        #Right side
        a != b and a < x and x < b ->
          (a - x) / (a - b)
        #Catch all
        true ->
          0
      end
    end
  end

  def triangle([a, b, c]) do
    fn(x) ->
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

  def trapezoidal([a, b, c, d]) do
    fn(x) ->
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
