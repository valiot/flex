defmodule Flex.Set do
  alias Flex.{Set, MembershipFun}

  defstruct mf_type: nil,
            mf: nil,
            mf_params: nil,
            tag: nil

  def new(opt) do
    mf_type = Keyword.fetch!(opt, :mf_type)
    tag = Keyword.fetch!(opt, :tag)
    mf_params = Keyword.fetch!(opt, :mf_params)
    mf =
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

    %Set{mf_type: mf_type, tag: tag, mf: mf, mf_params: mf_params}
  end
end
