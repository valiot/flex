defmodule Flex.MembershipFun do
  @moduledoc """
  Module for membership functions.
  #TODO: make mf with its own parameters
  """
  def shoulder([a, b, c]) do
    mu =
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
    #membershipfunction
    {mu, c}
  end

  def saturation([a, b, c]) do
    mu =
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
    {mu, c}
  end

  def triangle([a, b, c]) do
    mu =
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
    {mu, b}
  end

  def trapezoidal([a, b, c, d]) do
    ctr = (c-b)/2
    mu =
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
    {mu, ctr}
  end
end
