defmodule Flex.EngineAdapter do
  @type input_vector() :: list()
  @type antecedent_map() :: map()
  @type rules() :: list()
  @type consequent() :: any()
  @type fuzzy_antecedents() :: any()
  @type fuzzy_consequent() :: any()

  @callback validation(input_vector(), antecedent_map(), rules(), consequent()) :: input_vector()
  @callback inference(any(), rules(), consequent()) :: any()
  @callback defuzzification(fuzzy_consequent()) :: any()

  def validation(input_vector, module, antecedent_map, rules, consequent),
    do: apply(module, :validation, [input_vector, antecedent_map, rules, consequent])

  def inference(fuzzy_antecedents, module, rules, consequent),
    do: apply(module, :inference, [fuzzy_antecedents, rules, consequent])

  def defuzzification(inference_output, module),
    do: apply(module, :defuzzification, [inference_output])
end
