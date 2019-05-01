defmodule Flex.Set do
  alias Flex.{Set, MembershipFun}

  defstruct mf_type: nil,
            mf: nil,
            mf_params: nil,
            tag: nil

  def new(opt) do
    mf_type = Keyword.fetch!(opt, :mf_type)
    tag = Keyword.fetch!(opt, :tag)
    %Set{mf_type: mf_type,tag: tag}
  end

  def set_mf(fuzzy_set) do
    params = fuzzy_set.mf_params

    mf =
      case fuzzy_set.mf_type do
        "saturation" ->
          MembershipFun.saturation(params)
        "shoulder" ->
          MembershipFun.shoulder(params)
        "triangle" ->
          MembershipFun.triangle(params)
        "trapezoidal" ->
          MembershipFun.trapezoidal(params)
        _ ->
          raise("Membership function not supported")
      end
    %{fuzzy_set | mf: mf}
  end
end
