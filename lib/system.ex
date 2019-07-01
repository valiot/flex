defmodule Flex.System do
  @moduledoc """
  An interface to create a Fuzzy Logic Control System (FLS).

  The Fuzzy controllers are very simple conceptually. They consist of an input stage  (fuzzification), a processing stage (inference_engine and output combination), and an output stage (defuzzification).
  """
  use GenServer
  require Logger

  alias Flex.Variable
  import Flex.Rule

  defmodule State do
    @moduledoc false
    defstruct rules: nil,
              antecedent: nil,
              consequent: nil,
              lt_ant: nil
  end

  @typedoc """
  Fuzzy Logic System state.
  - `:rules` - (list) A list of rules that defines the behavior of the Fuzzy logic systems.
  - `:antecedent` - (Map) Input variables.
  - `:consequent` - Output variable.
  - `:lt_ant` - a list of the input variables.
  """
  @type t :: %Flex.System.State{
          rules: [Flex.Rule.t(), ...],
          antecedent: [Flex.Variable.t(), ...],
          consequent: Flex.Variable.t()
        }

  @doc """
  Spawns a Fuzzy Logic System.

  The following options are require:
    - `:rules` - Defines the behavior of the system based on the a list of rules.
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

  def init(params) do
    rule = Keyword.fetch!(params, :rules)
    lt_ant = Keyword.fetch!(params, :antecedent)
    antecedent = fzlt_to_map(lt_ant, %{})
    consequent = Keyword.fetch!(params, :consequent)
    state = %State{rules: rule, antecedent: antecedent, consequent: consequent, lt_ant: lt_ant}
    {:ok, state}
  end

  def handle_call({:compute, input}, _from, state) do
    output =
      input
      |> fuzzification(state.lt_ant, state.antecedent)
      |> inference_engine(state.rules, state.consequent)
      |> output_combination()
      |> defuzzification()

    {:reply, output, state}
  end

  defp fuzzification([], [], ant_map), do: ant_map

  defp fuzzification([input | i_tail], [fz_var | k_tail], ant_map) do
    n_fz_var = Variable.fuzzification(fz_var, input)
    ant_map = Map.put(ant_map, fz_var.tag, n_fz_var)
    fuzzification(i_tail, k_tail, ant_map)
  end

  @doc false
  def inference_engine(_antecedents, [], consequent), do: consequent

  def inference_engine(antecedents, [rule | tail], consequent) do
    rule_params = get_spec_antecedents(rule.antecedent, antecedents, []) ++ [consequent]

    consequent =
      if is_function(rule.statement) do
        rule.statement.(rule_params)
      else
        args = Map.merge(antecedents, %{consequent.tag => consequent})
        statement(rule.statement, args)
      end

    inference_engine(antecedents, tail, consequent)
  end

  defp get_spec_antecedents([], _antecedents, lt_ant_vars), do: lt_ant_vars

  defp get_spec_antecedents([tag | tail], antecedents, lt_ant_vars) do
    f_var = Map.get(antecedents, tag)
    lt_ant_vars = lt_ant_vars ++ [f_var]
    get_spec_antecedents(tail, antecedents, lt_ant_vars)
  end

  defp output_combination(cons_var) do
    output = Enum.map(cons_var.fuzzy_sets, fn x -> root_sum_square(cons_var.mf_values[x.tag]) end)
    %{cons_var | tmp: output}
  end

  defp root_sum_square(mf_value) do
    mf_value
    |> Enum.map(fn x -> x * x end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  defp defuzzification(fuzzy_output), do: Variable.defuzzification(fuzzy_output)

  defp statement({arg1, arg2, "&&&"}, args), do: statement(arg1, args) &&& statement(arg2, args)
  defp statement({arg1, arg2, "|||"}, args), do: statement(arg1, args) ||| statement(arg2, args)

  defp statement({var_tag, set_tag, "~>"}, args) when is_binary(var_tag) do
    fuzzy_var = Map.get(args, var_tag, :error)
    fuzzy_var ~> set_tag
  end

  defp statement({consequent, set_tag, "~>"}, args), do: statement(consequent, args) ~> set_tag

  defp statement({arg1, con_tag, ">>>"}, args) do
    val = statement(arg1, args)
    consequent = Map.get(args, con_tag)
    val >>> consequent
  end

  defp statement(arg, _args), do: arg

  defp fzlt_to_map([], map), do: map

  defp fzlt_to_map([fz_var | tail], map) do
    map = Map.put(map, fz_var.tag, fz_var)
    fzlt_to_map(tail, map)
  end
end
