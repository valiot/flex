defmodule Flex do
  @moduledoc """
  All structs definition.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Flex.hello()
      :world

  """
  defmodule FuzzySet do
    defstruct mf: nil
    def new(opt) do
      mf = Keyword.fetch!(opt, :mf)
      %FuzzySet{mf: mf}
    end
  end

  defmodule FuzzyRule do
    defstruct antecedent: nil,
              consequent: nil
  end
end
