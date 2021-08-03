defmodule Flex.EngineAdapter do
  alias Flex.Variable

  @type input_vector() :: list()
  @type antecedent_map() :: map()
  @type rules() :: list()
  @type consequent() :: any()
  @type fuzzy_antecedents() :: any()
  @type fuzzy_consequent() :: any()
  @type antecedent_name_list() :: any()
  @type antecedent() :: any()

  @callback validation(input_vector(), antecedent_map(), rules(), consequent()) :: input_vector()
  @callback inference(any(), rules(), consequent()) :: any()
  @callback fuzzification(input_vector(), antecedent_name_list(), antecedent()) :: any()
  @callback defuzzification(fuzzy_consequent()) :: any()

  def validation(input_vector, module, antecedent_map, rules, consequent),
    do: apply(module, :validation, [input_vector, antecedent_map, rules, consequent])

  def fuzzification(input_vector, module, antecedent_name_list, antecedent),
    do: apply(module, :fuzzification, [input_vector, antecedent_name_list, antecedent])

  def inference(fuzzy_antecedents, module, rules, consequent),
    do: apply(module, :inference, [fuzzy_antecedents, rules, consequent])

  def defuzzification(inference_output, module),
    do: apply(module, :defuzzification, [inference_output])

  def default_fuzzification([], [], ant_map), do: ant_map

  def default_fuzzification([input | i_tail], [fz_var | k_tail], ant_map) do
    n_fz_var = Variable.fuzzification(fz_var, input)
    ant_map = Map.put(ant_map, fz_var.tag, n_fz_var)
    default_fuzzification(i_tail, k_tail, ant_map)
  end
end
