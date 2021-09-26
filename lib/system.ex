defmodule Flex.System do
  @moduledoc """
  An interface to create a Fuzzy Logic Control System (FLS).

  The Fuzzy controllers are very simple conceptually. They consist of an input stage (fuzzification), a processing stage (inference), and an output stage (defuzzification).
  """
  use GenServer
  require Logger

  alias Flex.EngineAdapter
  alias Flex.EngineAdapter.{Mamdani, TakagiSugeno, ANFIS}

  defmodule State do
    @moduledoc false
    defstruct rules: nil,
              antecedents: nil,
              consequent: nil,
              engine_type: Mamdani,
              engine_output: %EngineAdapter.State{},
              learning_rate: 0.05
  end

  @typedoc """
  Fuzzy Logic System state.
  - `:rules` - (list) A list of rules that defines the behavior of the Fuzzy logic systems.
  - `:consequent` - Output variable.
  - `:antecedents` - a list of the input variables.
  - `:engine_type` - defines the inference engine behavior (default: Mamdini).
  - `:engine_output` - previous engine state with its output.
  - `:engine_output` - previous engine state with its output.
  """
  @type t :: %Flex.System.State{
          rules: [Flex.Rule.t(), ...],
          antecedents: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t(),
          engine_type: Mamdani | TakagiSugeno | ANFIS,
          engine_output: EngineAdapter.engine_state(),
          learning_rate: number()
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
  Adjust the free parameters of the FIS (only avaliable with ANFIS engine), using the following methods:
    - Learning method: Backpropagation.
    - Energy function: 0.5 * (target - output)^2
  """
  @spec adapt(atom | pid | {atom, any} | {:via, atom, any}, number()) ::
          {:ok, number()} | {:error, :einval}
  def adapt(pid, desired_output) when is_number(desired_output) do
    GenServer.call(pid, {:adapt, desired_output})
  end

  @doc """
  Sets the Inference Engine type.
  """
  @spec set_engine_type(atom | pid | {atom, any} | {:via, atom, any}, atom) ::
          :ok | {:error, :einval}
  def set_engine_type(pid, type) when type in [Mamdani, TakagiSugeno, ANFIS] do
    GenServer.call(pid, {:set_engine_type, type})
  end

  def set_engine_type(_pid, _type), do: {:error, :einval}

  @doc """
  Sets the Learning rate (etha).
  """
  @spec set_learning_rate(atom | pid | {atom, any} | {:via, atom, any}, number()) ::
          :ok | {:error, :einval}
  def set_learning_rate(pid, learning_rate) when is_number(learning_rate) do
    GenServer.call(pid, {:set_learning_rate, learning_rate})
  end

  def set_learning_rate(_pid, _learning_rate), do: {:error, :einval}

  @doc """
  Gets the current system state.
  """
  @spec get_state(atom | pid | {atom, any} | {:via, atom, any}) :: Flex.System.t()
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def init(params) do
    rules = Keyword.fetch!(params, :rules)
    antecedents = Keyword.fetch!(params, :antecedents)
    consequent = Keyword.fetch!(params, :consequent)

    engine_type = Keyword.get(params, :engine_type, Mamdani)
    learning_rate = Keyword.get(params, :learning_rate, 0.05)

    {:ok,
     %State{
       rules: rules,
       antecedents: antecedents,
       consequent: consequent,
       engine_type: engine_type,
       learning_rate: learning_rate
     }}
  end

  def handle_call({:compute, input_vector}, _from, %{engine_type: engine_type} = state) do
    output =
      %EngineAdapter.State{input_vector: input_vector, type: engine_type}
      |> EngineAdapter.validation(state.antecedents, state.rules, state.consequent)
      |> EngineAdapter.fuzzification(state.antecedents)
      |> EngineAdapter.inference(state.rules, state.consequent)
      |> EngineAdapter.defuzzification()

    {:reply, output.crisp_output, %{state | engine_output: output}}
  end

  def handle_call(
        {:adapt, target},
        _from,
        %{engine_type: engine_type, engine_output: engine_output} = state
      )
      when engine_type == ANFIS do
    dE_do5 = -(target - engine_output.crisp_output)

    consequent = ANFIS.forward_pass(dE_do5, state.learning_rate, engine_output)

    {:reply, {:ok, dE_do5}, %{state | consequent: consequent}}
  end

  def handle_call({:adapt, _target}, _from, state),
    do: {:reply, {:error, :einval}, state}

  def handle_call({:set_engine_type, type}, _from, state) do
    {:reply, :ok, %{state | engine_type: type}}
  end

  def handle_call({:set_learning_rate, learning_rate}, _from, %{engine_type: engine_type} = state)
      when engine_type == ANFIS do
    {:reply, :ok, %{state | learning_rate: learning_rate}}
  end

  def handle_call({:set_learning_rate, _learning_rate}, _from, state),
    do: {:reply, {:error, :einval}, state}

  def handle_call(:get_state, _from, state),
    do: {:reply, {:ok, state}, state}
end
