defmodule Flex.System do
  @moduledoc """
  An interface to create a Fuzzy Logic Control System (FLS).

  The Fuzzy controllers are very simple conceptually. They consist of an input stage  (fuzzification), a processing stage (inference_engine and output combination), and an output stage (defuzzification).
  """
  use GenServer
  require Logger

  alias Flex.{Variable, EngineAdapter}
  alias Flex.EngineAdapter.{Mamdani, TakagiSugeno}

  defmodule State do
    @moduledoc false
    defstruct rules: nil,
              antecedent: nil,
              consequent: nil,
              lt_ant: nil,
              engine_type: Mamdani
  end

  @typedoc """
  Fuzzy Logic System state.
  - `:rules` - (list) A list of rules that defines the behavior of the Fuzzy logic systems.
  - `:antecedent` - (Map) Input variables.
  - `:consequent` - Output variable.
  - `:lt_ant` - a list of the input variables.
  - `:engine_type` - defines the inference engine behavior (default: Mamdini).
  """
  @type t :: %Flex.System.State{
          rules: [Flex.Rule.t(), ...],
          antecedent: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t(),
          engine_type: Mamdani | TakagiSugeno
        }

  @doc """
  Spawns a Fuzzy Logic System.

  The following options are require:
    - `:rules` - Defines the behavior of the system based on a list of rules.
    - `:antecedent` - (list) Defines the input variables.
    - `:consequent` - Defines the output variable.
  """
  def start_link(params, opt \\ []) do
    GenServer.start_link(__MODULE__, params, opt)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  @doc """
  Computes the Fuzzy Logic System output for a given input vector.
  """
  @spec compute(atom | pid | {atom, any} | {:via, atom, any}, list) :: any
  def compute(pid, input) when is_list(input) do
    GenServer.call(pid, {:compute, input})
  end

  @doc """
  Sets the Inference Engine type.
  """
  @spec set_engine_type(atom | pid | {atom, any} | {:via, atom, any}, atom) :: any
  def set_engine_type(pid, type) when type in [Mamdani, TakagiSugeno] do
    GenServer.call(pid, {:set_engine_type, type})
  end

  def init(params) do
    rule = Keyword.fetch!(params, :rules)
    lt_ant = Keyword.fetch!(params, :antecedent)
    antecedent = fzlt_to_map(lt_ant, %{})
    consequent = Keyword.fetch!(params, :consequent)
    state = %State{rules: rule, antecedent: antecedent, consequent: consequent, lt_ant: lt_ant}
    {:ok, state}
  end

  def handle_call({:compute, input}, _from, %{engine_type: engine_type} = state) do
    output =
      input
      |> EngineAdapter.validation(engine_type, state.lt_ant, state.rules, state.consequent)
      |> fuzzification(state.lt_ant, state.antecedent)
      |> EngineAdapter.inference(engine_type, state.rules, state.consequent)
      |> EngineAdapter.defuzzification(engine_type)

    {:reply, output, state}
  end

  def handle_call({:set_engine_type, type}, _from, state) do
    {:reply, :ok, %{state | engine_type: type}}
  end

  defp fuzzification([], [], ant_map), do: ant_map

  defp fuzzification([input | i_tail], [fz_var | k_tail], ant_map) do
    n_fz_var = Variable.fuzzification(fz_var, input)
    ant_map = Map.put(ant_map, fz_var.tag, n_fz_var)
    fuzzification(i_tail, k_tail, ant_map)
  end

  defp fzlt_to_map([], map), do: map

  defp fzlt_to_map([fz_var | tail], map) do
    map = Map.put(map, fz_var.tag, fz_var)
    fzlt_to_map(tail, map)
  end
end
