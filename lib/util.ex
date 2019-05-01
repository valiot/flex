#funciones de ayuda "normalización, desnormalización"
defmodule Flex.Util do
  @doc guard: true
  def _a ~> b, do: b #compute membership fn max(a, b)
  def a &&& b, do: max(a, b)
  def a ||| b, do: min(a, b)
end
