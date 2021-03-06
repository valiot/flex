defmodule Flex.Set do
  alias Flex.{Set, MembershipFun}

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

    {mf, c} =
      case mf_type do
        "saturation" ->
          MembershipFun.saturation(mf_params)

        "shoulder" ->
          MembershipFun.shoulder(mf_params)

        "triangle" ->
          MembershipFun.triangle(mf_params)

        "trapezoidal" ->
          MembershipFun.trapezoidal(mf_params)

        _ ->
          raise("Membership function not supported")
      end

    %Set{mf_type: mf_type, tag: tag, mf: mf, mf_params: mf_params, mf_center: c}
  end
end
