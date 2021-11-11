defmodule Flex.EngineAdapter do
  alias Flex.Variable
  alias Flex.EngineAdapter.{Mamdani, State, TakagiSugeno}

  defmodule State do
    @moduledoc false
    defstruct type: nil,
              input_vector: nil,
              fuzzy_antecedents: nil,
              fuzzy_consequent: nil,
              crisp_output: nil
  end

  @typedoc """
  Engine Adapter State.
  - `:type` - defines the inference engine behavior (default: Mamdini).
  - `:fuzzy_antecedents` - fuzzification output.
  - `:fuzzy_consequent` - inference output.
  - `:crisp_output` - defuzzification output.
  """
  @type engine_state() :: %Flex.EngineAdapter.State{
          type: Mamdani | TakagiSugeno,
          input_vector: list(),
          fuzzy_antecedents: map(),
          fuzzy_consequent: Flex.Variable.t(),
          crisp_output: integer() | float()
        }

  @type antecedents() :: [Flex.Variable.t(), ...]
  @type rules() :: [Flex.Rule.t(), ...]
  @type consequent() :: Flex.Variable.t()

  @callback validation(engine_state(), antecedents(), rules(), consequent()) :: engine_state()
  @callback fuzzification(engine_state(), antecedents()) :: engine_state()
  @callback inference(engine_state(), rules(), consequent()) :: engine_state()
  @callback defuzzification(engine_state()) :: engine_state()

  def validation(engine_state, antecedents, rules, consequent),
    do: apply(engine_state.type, :validation, [engine_state, antecedents, rules, consequent])

  def fuzzification(engine_state, antecedents),
    do: apply(engine_state.type, :fuzzification, [engine_state, antecedents])

  def inference(engine_state, rules, consequent),
    do: apply(engine_state.type, :inference, [engine_state, rules, consequent])

  def defuzzification(engine_state),
    do: apply(engine_state.type, :defuzzification, [engine_state])

  def get_crisp_output(%State{crisp_output: crisp_output}), do: crisp_output

  def default_fuzzification([], [], ant_map), do: ant_map

  def default_fuzzification([input | i_tail], [fz_var | k_tail], ant_map) do
    n_fz_var = Variable.fuzzification(fz_var, input)
    ant_map = Map.put(ant_map, fz_var.tag, n_fz_var)
    default_fuzzification(i_tail, k_tail, ant_map)
  end
end
