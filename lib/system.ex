defmodule Flex.System do
  @moduledoc """
  An interface to create a Fuzzy Logic Control System (FLS).

  The Fuzzy controllers are very simple conceptually. They consist of an input stage (fuzzification), a processing stage (inference), and an output stage (defuzzification).
  """
  use GenServer
  require Logger

  alias Flex.EngineAdapter
  alias Flex.EngineAdapter.{Mamdani, TakagiSugeno}

  defmodule State do
    @moduledoc false
    defstruct rules: nil,
              antecedents: nil,
              consequent: nil,
              engine_type: Mamdani
  end

  @typedoc """
  Fuzzy Logic System state.
  - `:rules` - (list) A list of rules that defines the behavior of the Fuzzy logic systems.
  - `:consequent` - Output variable.
  - `:antecedents` - a list of the input variables.
  - `:engine_type` - defines the inference engine behavior (default: Mamdini).
  """
  @type t :: %Flex.System.State{
          rules: [Flex.Rule.t(), ...],
          antecedents: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t(),
          engine_type: Mamdani | TakagiSugeno
        }

  @doc """
  Spawns a Fuzzy Logic System.

  The following options are require:
    - `:rules` - Defines the behavior of the system based on a list of rules.
    - `:antecedents` - (list) Defines the input variables.
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
  def compute(pid, input_vector) when is_list(input_vector) do
    GenServer.call(pid, {:compute, input_vector})
  end

  @doc """
  Sets the Inference Engine type.
  """
  @spec set_engine_type(atom | pid | {atom, any} | {:via, atom, any}, atom) :: :ok | {:error, :einval}
  def set_engine_type(pid, type) when type in [Mamdani, TakagiSugeno] do
    GenServer.call(pid, {:set_engine_type, type})
  end

  def set_engine_type(_pid, _type), do: {:error, :einval}

  def init(params) do
    rules = Keyword.fetch!(params, :rules)
    antecedents = Keyword.fetch!(params, :antecedents)
    consequent = Keyword.fetch!(params, :consequent)
    {:ok, %State{rules: rules, antecedents: antecedents, consequent: consequent}}
  end

  def handle_call({:compute, input_vector}, _from, %{engine_type: engine_type} = state) do
    output =
      %EngineAdapter.State{input_vector: input_vector, type: engine_type}
      |> EngineAdapter.validation(state.antecedents, state.rules, state.consequent)
      |> EngineAdapter.fuzzification(state.antecedents)
      |> EngineAdapter.inference(state.rules, state.consequent)
      |> EngineAdapter.defuzzification()
      |> EngineAdapter.get_crisp_output()

    {:reply, output, state}
  end

  def handle_call({:set_engine_type, type}, _from, state) do
    {:reply, :ok, %{state | engine_type: type}}
  end
end
