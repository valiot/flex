defmodule Flex.System do
  @moduledoc """
  An interface to create a Fuzzy Logic Control System (FLS).

  The Fuzzy controllers are very simple conceptually. They consist of an input stage (fuzzification), a processing stage (inference), and an output stage (defuzzification).
  """
  use GenServer
  require Logger

  alias Flex.EngineAdapter
  alias Flex.EngineAdapter.{ANFIS, Mamdani, TakagiSugeno}

  defmodule State do
    @moduledoc false
    defstruct rules: nil,
              antecedents: nil,
              consequent: nil,
              engine_type: Mamdani,
              engine_output: %EngineAdapter.State{},
              sets_in_rules: [],
              learning_rate: 0.05,
              initial_gamma: 1000
  end

  @typedoc """
  Fuzzy Logic System state.
  - `:rules` - (list) A list of rules that defines the behavior of the Fuzzy logic systems.
  - `:consequent` - Output variable.
  - `:antecedents` - a list of the input variables.
  - `:engine_type` - defines the inference engine behavior (default: Mamdini).
  - `:sets_in_rules` - list of sets involve in the rules (optional, required by ANFIS).
  - `:learning_rate` - is the speed at which the system parameters are adjusted (ANFIS only).
  - `:initial_gamma` - is the speed at which the system parameters are adjusted (LSE, ANFIS only).
  """
  @type t :: %Flex.System.State{
          rules: [Flex.Rule.t(), ...],
          antecedents: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t(),
          engine_type: Mamdani | TakagiSugeno | ANFIS,
          engine_output: EngineAdapter.engine_state(),
          sets_in_rules: list(),
          learning_rate: number(),
          initial_gamma: number()
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
  Adjust the consequent free parameters of the FIS (only avaliable with ANFIS engine), using the following methods:
    - Learning method: Steepest gradient Backpropagation.
    - Energy function: 0.5 * (target - output)^2
  """
  @spec forward_pass(atom | pid | {atom, any} | {:via, atom, any}, number()) ::
          {:ok, number()} | {:error, :einval}
  def forward_pass(pid, desired_output) when is_number(desired_output) do
    GenServer.call(pid, {:forward_pass, desired_output})
  end

  @doc """
  Adjust the premise free parameters of the FIS (only avaliable with ANFIS engine), using the following methods:
    - Learning method: Steepest gradient Backpropagation.
    - Energy function: 0.5 * (target - output)^2
  """
  @spec backward_pass(atom | pid | {atom, any} | {:via, atom, any}, number()) ::
          {:ok, number()} | {:error, :einval}
  def backward_pass(pid, desired_output) when is_number(desired_output) do
    GenServer.call(pid, {:backward_pass, desired_output})
  end

  @doc """
  Adjust the free parameters of the FIS (only avaliable with ANFIS engine), using the following methods:
    - Learning method: Steepest gradient Backpropagation.
    - Energy function: 0.5 * (target - output)^2
  Note: this functions fires both forward and backward passes.
  """
  @spec hybrid_online_learning(atom | pid | {atom, any} | {:via, atom, any}, number()) ::
          {:ok, number()} | {:error, :einval}
  def hybrid_online_learning(pid, desired_output) when is_number(desired_output) do
    GenServer.call(pid, {:hybrid_online_learning, desired_output})
  end

  @doc """
  Adjust the free parameters of the FIS (only avaliable with ANFIS engine), using the following methods:
    - Forward method: Least Square Estimate.
    - Learning method: Steepest gradient Backpropagation.
    - Energy function: 0.5 * (target - output)^2
  Note: this functions fires both forward and backward passes with a batch of data.
  """
  @spec hybrid_offline_learning(
          atom | pid | {atom, any} | {:via, atom, any},
          list(),
          list(),
          number()
        ) ::
          {:ok, number()} | {:error, :einval}
  def hybrid_offline_learning(pid, inputs, targets, epochs)
      when is_list(inputs) and is_list(targets) and is_number(epochs) do
    GenServer.call(pid, {:hybrid_offline_learning, inputs, targets, epochs}, :infinity)
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
    initial_gamma = Keyword.get(params, :initial_gamma, 1000)
    sets_in_rules = Keyword.get(params, :sets_in_rules, [])

    {:ok,
     %State{
       rules: rules,
       antecedents: antecedents,
       consequent: consequent,
       engine_type: engine_type,
       learning_rate: learning_rate,
       sets_in_rules: sets_in_rules,
       initial_gamma: initial_gamma
     }}
  end

  def handle_call({:compute, input_vector}, _from, state) do
    output = compute_fis(input_vector, state)
    {:reply, output.crisp_output, %{state | engine_output: output}}
  end

  def handle_call(
        {:forward_pass, target},
        _from,
        %{engine_type: engine_type, engine_output: engine_output} = state
      )
      when engine_type == ANFIS do
    de_do5 = -(target - engine_output.crisp_output)

    consequent = ANFIS.forward_pass(de_do5, state.learning_rate, engine_output)

    {:reply, {:ok, de_do5}, %{state | consequent: consequent}}
  end

  def handle_call(
        {:backward_pass, target},
        _from,
        %{engine_type: engine_type, engine_output: engine_output} = state
      )
      when engine_type == ANFIS do
    de_do5 = -(target - engine_output.crisp_output)

    antecedents = ANFIS.backward_pass(de_do5, state, engine_output)

    {:reply, {:ok, de_do5}, %{state | antecedents: antecedents}}
  end

  def handle_call(
        {:hybrid_online_learning, target},
        _from,
        %{engine_type: engine_type, engine_output: engine_output} = state
      )
      when engine_type == ANFIS do
    de_do5 = -(target - engine_output.crisp_output)

    consequent = ANFIS.forward_pass(de_do5, state.learning_rate, engine_output)

    antecedents = ANFIS.backward_pass(de_do5, state, engine_output)

    {:reply, {:ok, de_do5}, %{state | consequent: consequent, antecedents: antecedents}}
  end

  def handle_call(
        {:hybrid_offline_learning, inputs, b_matrix, epochs},
        _from,
        %{
          engine_type: engine_type,
          initial_gamma: initial_gamma,
          antecedents: antecedents,
          consequent: consequent
        } = state
      )
      when engine_type == ANFIS do
    {antecedents, consequent} =
      for _epoch <- 1..epochs, reduce: {antecedents, consequent} do
        {antecedents, consequent} ->
          a_matrix =
            build_matrix_a(inputs, %{state | antecedents: antecedents, consequent: consequent})

          consequent = ANFIS.least_square_estimate(a_matrix, b_matrix, initial_gamma, state)

          antecedents =
            for {input_vector, target} <- Enum.zip(inputs, b_matrix), reduce: antecedents do
              antecedents ->
                back_learning_state = %{state | antecedents: antecedents, consequent: consequent}
                prediction = compute_fis(input_vector, back_learning_state)
                de_do5 = -(target - prediction.crisp_output)
                ANFIS.backward_pass(de_do5, back_learning_state, prediction)
            end

          {antecedents, consequent}
      end

    {:reply, :ok, %{state | antecedents: antecedents, consequent: consequent}}
  end

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

  # Catch invalid calls
  def handle_call({_call, _target}, _from, state),
    do: {:reply, {:error, :einval}, state}

  defp compute_fis(input_vector, %{engine_type: engine_type} = state) do
    %EngineAdapter.State{input_vector: input_vector, type: engine_type}
    |> EngineAdapter.validation(state.antecedents, state.rules, state.consequent)
    |> EngineAdapter.fuzzification(state.antecedents)
    |> EngineAdapter.inference(state.rules, state.consequent)
    |> EngineAdapter.defuzzification()
  end

  defp build_matrix_a(inputs, state) do
    inputs
    |> Enum.map(fn input_vector ->
      output = compute_fis(input_vector, state)
      w_n = get_wn(output.fuzzy_consequent)
      build_vector_at(w_n, input_vector)
    end)
  end

  defp get_wn(fuzzy_consequent) do
    w =
      fuzzy_consequent.fuzzy_sets
      |> Enum.reduce([], fn output_fuzzy_set, acc ->
        acc ++ [fuzzy_consequent.mf_values[output_fuzzy_set.tag]]
      end)
      |> List.flatten()

    ws = Enum.sum(w)

    Enum.map(w, fn w_i -> w_i / ws end)
  end

  defp build_vector_at(w_n, input_vector) do
    Enum.reduce(w_n, [], fn w_n_i, acc ->
      acc ++ Enum.map(input_vector ++ [1], fn x_i -> x_i * w_n_i end)
    end)
  end
end
