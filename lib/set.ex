defmodule Flex.Set do
  alias Flex.{MembershipFun, Set}

  @moduledoc """
  An interface to create Fuzzy Sets struct.
  """
  defstruct mf_type: nil,
            mf: nil,
            mf_center: nil,
            mf_params: nil,
            tag: nil

  @typedoc """
  Fuzzy Set struct.
  - `:mf_type` - Defines which type of membership function uses the set.
  - `:mf` - Anonymous function reference of the membership function.
  - `:mf_center` - The center point of the membership function.
  - `:mf_params` - The parameters of the membership function.
  - `:tag` - Linguistic name of the fuzzy set.
  """
  @type t :: %__MODULE__{
          mf_type: String.t(),
          mf: fun(),
          mf_center: integer() | float(),
          mf_params: keyword(),
          tag: String.t()
        }

  @doc """
  Creates a Fuzzy set.

  The following options are require:
    * `:mf_type` - (string) Defines which type of membership function uses the set (e.g., "triangle").
    * `:tag` - (string) defines the linguistic name of the fuzzy set (e.g., "too hot"),
    * `:mf_params` - The parameters of the membership function, see Membership functions.
  """
  @spec new(keyword) :: Flex.Set.t()
  def new(opt) do
    mf_type = Keyword.fetch!(opt, :mf_type)
    tag = Keyword.fetch!(opt, :tag)
    mf_params = Keyword.fetch!(opt, :mf_params)

    {mf, c} = build_membership_function(mf_type, mf_params)

    %Set{mf_type: mf_type, tag: tag, mf: mf, mf_params: mf_params, mf_center: c}
  end

  defp build_membership_function("saturation", mf_params), do: MembershipFun.saturation(mf_params)
  defp build_membership_function("shoulder", mf_params), do: MembershipFun.shoulder(mf_params)
  defp build_membership_function("triangle", mf_params), do: MembershipFun.triangle(mf_params)

  defp build_membership_function("trapezoidal", mf_params),
    do: MembershipFun.trapezoidal(mf_params)

  defp build_membership_function("gaussian", mf_params), do: MembershipFun.gaussian(mf_params)
  defp build_membership_function("bell", mf_params), do: MembershipFun.gbell(mf_params)
  defp build_membership_function("pi_shaped", mf_params), do: MembershipFun.pi_shaped(mf_params)
  defp build_membership_function("s_shaped", mf_params), do: MembershipFun.s_shaped(mf_params)
  defp build_membership_function("z_shaped", mf_params), do: MembershipFun.z_shaped(mf_params)
  defp build_membership_function("sigmoid", mf_params), do: MembershipFun.sigmoid(mf_params)

  defp build_membership_function("linear_combination", mf_params),
    do: MembershipFun.linear_combination(mf_params)

  defp build_membership_function(_mf_type, _mf_params),
    do: raise("Membership function not supported")

  @doc """
  Updates a Fuzzy set depending on the gradient.
  """
  @spec update(Flex.Set.t(), list(), number()) :: Flex.Set.t()
  def update(fuzzy_set, gradient, learning_rate) do
    new_mf_params =
      fuzzy_set.mf_params
      |> Enum.zip(gradient)
      |> Enum.map(fn {aij, gradient_j} -> aij - learning_rate * gradient_j end)

    new(mf_type: fuzzy_set.mf_type, tag: fuzzy_set.tag, mf_params: new_mf_params)
  end
end
