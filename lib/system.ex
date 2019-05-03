defmodule Flex.System do
  @moduledoc """
  Modue
  """
  use GenServer
  require Logger

  alias Flex.Variable

  defmodule State do
    @moduledoc false

    # rules: define the behavior of the Fuzzy logic system
    # antecedents: input fuzzy variables
    # concequent: output fuzzy variable

    defstruct rules: nil,
              antecedent: nil,
              consequent: nil,
              lt_ant: nil
  end

  def start_link(params, opt \\ []) do
    GenServer.start_link(__MODULE__, params, opt)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

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

  defp fzlt_to_map([], map), do: map

  defp fzlt_to_map([fz_var | tail], map) do
    map = Map.put(map, fz_var.tag, fz_var)
    fzlt_to_map(tail, map)
  end

  def handle_call({:compute, input}, _from, state) do
    output =
      input
      #
      |> fuzzification(state.lt_ant, state.antecedent)
      # fz output var
      |> inference_engine(state.rules, state.consequent)
      |> output_combination()
      |> defuzzification()

    {:reply, output, state}
  end

  def fuzzification([], [], ant_map), do: ant_map

  def fuzzification([input | i_tail], [fz_var | k_tail], ant_map) do
    n_fz_var = Variable.fuzzification(fz_var, input)
    ant_map = Map.put(ant_map, fz_var.tag, n_fz_var)
    fuzzification(i_tail, k_tail, ant_map)
  end

  def inference_engine(_antecedents, [], consequent), do: consequent

  def inference_engine(antecedents, [rule | tail], consequent) do
    rule_params = get_spec_antecedents(rule.antecedent, antecedents, []) ++ [consequent]
    consequent = rule.statement.(rule_params)
    inference_engine(antecedents, tail, consequent)
  end

  def get_spec_antecedents([], _antecedents, lt_ant_vars), do: lt_ant_vars

  def get_spec_antecedents([tag | tail], antecedents, lt_ant_vars) do
    f_var = Map.get(antecedents, tag)
    lt_ant_vars = lt_ant_vars ++ [f_var]
    get_spec_antecedents(tail, antecedents, lt_ant_vars)
  end

  def output_combination(cons_var) do
    output = Enum.map(cons_var.fuzzy_sets, fn x -> root_sum_square(cons_var.mf_values[x.tag]) end)
    %{cons_var | tmp: output}
  end

  def root_sum_square(mf_value) do
    mf_value
    |> Enum.map(fn x -> x * x end)
    |> Enum.sum()
    |> :math.sqrt()
  end

  def defuzzification(fuzzy_output), do: Variable.defuzzification(fuzzy_output)
end
