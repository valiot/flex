defmodule FlexTest do
  use ExUnit.Case
  doctest Flex

  test "greets the world" do
    assert Flex.hello() == :world
  end
end
