#funciones de ayuda "normalización, desnormalización"
defmodule Flex.Rule do

  def a &&& b, do: min(a, b)
  def a ||| b, do: max(a, b)
  def a ~> b, do: a.mf_values[b]

  def inference_engine([], _fuzzy_var, acc), do: acc
  def inference_engine([rule | tail], fuzzy_var, acc) do
    nil
  end
end
