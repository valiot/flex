#funciones de ayuda "normalización, desnormalización"
defmodule Flex.Rule do

  def a &&& b, do: min(a, b)

  def a ||| b, do: max(a, b)

  def  a >>> b do
    case b.type do
      :antecedent ->
        raise("only the consequent variable can use the THEN operation")
      :consequent ->
        %{b | tmp: a}
    end
  end

  def  a ~> b do
    case a.type do
      :antecedent ->
        a.mf_values[b]
      :consequent ->
        new_values = Map.get(a.mf_values, b, []) ++ [a.tmp]
        mf_values = Map.put(a.mf_values, b, new_values)
        %{a | mf_values: mf_values}
    end
  end

  def inference_engine([], _fuzzy_var, acc), do: acc
  def inference_engine([rule | tail], fuzzy_var, acc) do
    nil
  end
end
