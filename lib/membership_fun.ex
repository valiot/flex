defmodule Flex.MembershipFun do
  @moduledoc """
  An interface to create Membership Functions reference.
  """
  import :math

  @doc """
  Shoulder membership function.
  """
  @spec shoulder([...]) :: {fun(), any}
  def shoulder([a, b, c]) do
    mu = fn x ->
      cond do
        # Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)

        # Right side
        x >= b ->
          1

        # Catch all
        true ->
          0
      end
    end

    {mu, c}
  end

  @doc """
  Saturation membership function.
  """
  @spec saturation([...]) :: {fun(), any}
  def saturation([a, b, c]) do
    mu = fn x ->
      cond do
        # Left side
        x <= a ->
          1

        # Right side
        a != b and a < x and x < b ->
          (x - b) / (a - b)

        # Catch all
        true ->
          0
      end
    end

    {mu, c}
  end

  @doc """
  Triangle membership function.
  """
  @spec triangle([...]) :: {fun(), any}
  def triangle([a, b, c]) do
    mu = fn x ->
      cond do
        # Left side
        a != b and a < x and x < b ->
          (x - a) / (b - a)

        # Medium
        x == b ->
          1

        # Right side
        b != c and b < x and x < c ->
          (c - x) / (c - b)

        # Catch all
        true ->
          0
      end
    end

    {mu, b}
  end

  @doc """
  Trapezoidal membership function.
  """
  @spec trapezoidal([...]) :: {fun(), any}
  def trapezoidal([a, b, c, d]) do
    ctr = (c - b) / 2

    mu = fn x -> trapezoidal_func(x, a, b, c, d) end

    {mu, ctr}
  end

  # Left side
  defp trapezoidal_func(x, a, b, _c, _d) when a != b and a < x and x < b,
    do: (x - a) / (b - a)

  # Medium
  defp trapezoidal_func(x, _a, b, c, _d) when b != c and b <= x and x <= c,
    do: 1

  # Right side
  defp trapezoidal_func(x, _a, _b, c, d) when c != d and c < x and x < d,
    do: (x - d) / (c - d)

  # Catch All
  defp trapezoidal_func(_x, _a, _b, _c, _d), do: 0

  @doc """
  Gaussian membership function.
    * `m` - (number) Mean,
    * `s` - (number) Standard deviation, it must not be equal to 0.
    * `f` - (number) Fuzzification Factor,
  """
  @spec gaussian([...]) :: {fun(), any}
  def gaussian([m, s, f]) when s != 0 do
    mu = fn x ->
      (pow(x - m, 2) / pow(s, 2))
      |> abs()
      |> pow(f)
      |> Kernel.*(-0.5)
      |> exp()
    end

    {mu, m}
  end

  def gaussian([_c, s, _m]), do: raise(ArgumentError, "Bad standard deviation: #{s}")

  @doc """
  Gaussian membership derivatived function.
    * `m` - (number) Mean,
    * `s` - (number) Standard deviation, it must not be equal to 0.
    * `f` - (number) Fuzzification Factor.
    * `mu` - (number) Last membership function value.
  """
  # Respect to the Mean (Center)
  def d_gaussian([m, s, _f], x, mu, 0) when s != 0,
    do: (x - m) * mu / pow(s, 2)

  # Respect to the Slope
  def d_gaussian([m, s, _f], x, mu, 1) when s != 0,
    do: pow(x - m, 2) * mu / pow(s, 3)

  def d_gaussian([_m, _s, _f], _x, _mu, _arg_index), do: 0

  @doc """
  Generalized Bell membership function.
    * `c` - (number) Center.
    * `s` - (number) Slope.
    * `b` - (number) The width of the curve, it must not be equal to 0.

  Definition of Generalized Bell function is:
        y(x) = 1 / (1 + |((x - c) / b)|^(2 * s))
  """
  @spec gbell([...]) :: {fun(), any}
  def gbell([c, s, b]) when b != 0 do
    mu = fn x ->
      ((x - c) / b)
      |> abs()
      |> pow(2 * s)
      |> Kernel.+(1)
      |> pow(-1)
    end

    {mu, c}
  end

  def gbell([_c, _s, b]), do: raise(ArgumentError, "Bad width of the curve: #{b}")

  @doc """
  Generalized Bell membership  derivatived function.
    * `c` - (number) Center.
    * `s` - (number) Slope.
    * `b` - (number) The width of the curve, it must not be equal to 0.

  Definition of Generalized Bell function is:
        y(x) = 1 / (1 + |((x - c) / b)|^(2 * s))
  """
  # Respect to the Mean (Center)
  def d_gbell([c, s, b], x, mu, 0) when b != 0 and x != c,
    do: 2 * s * mu * (1 - mu) / (x - c)

  def d_gbell([_c, _s, b], _x, _mu, 0) when b != 0, do: 0

  # Respect to the Slope
  def d_gbell([c, _s, b], x, mu, 1) when b != 0 and x != c,
    do: -2 * log(abs((x - c) / b)) * mu * (1 - mu)

  def d_gbell([_c, _s, b], _x, _mu, 1) when b != 0, do: 0

  # Respect to the Width
  def d_gbell([c, s, b], x, mu, 2) when b != 0 and x != c,
    do: 2 * s * mu * (1 - mu) / b

  def d_gbell([_c, _s, b], _x, _mu, 2) when b != 0, do: 0

  def d_gbell([_c, _s, b], _x, _mu, _darg_index),
    do: raise(ArgumentError, "Bad width of the curve: #{b}")

  @doc """
  Sigmoidal membership function.
    * `c` - (number) Crossover point.
    * `s` - (number) Slope.

  Definition of Generalized Bell function is:
        y(x) = 1 / (1 + e^(-s(x-c)))
  """
  @spec sigmoid([...]) :: {fun(), any}
  def sigmoid([c, s, _]) do
    mu = fn x ->
      (-s * (x - c))
      |> exp()
      |> Kernel.+(1)
      |> pow(-1)
    end

    {mu, c}
  end

  @doc """
  Z-shaped membership function.
  """
  @spec z_shaped([...]) :: {fun(), any}
  def z_shaped([a, b, _]) when a <= b do
    c = (a + b) / 2

    mu = fn x ->
      cond do
        x <= a ->
          1

        a <= x and x <= (a + b) / 2 ->
          1 - 2 * pow((x - a) / (b - a), 2)

        (a + b) / 2 <= x and x <= b ->
          2 * pow((x - b) / (b - a), 2)

        x >= b ->
          0

        # Catch all
        true ->
          0
      end
    end

    {mu, c}
  end

  def z_shaped([_a, _b, _]), do: raise(ArgumentError, "a <= b is required.")

  @doc """
  S-shaped membership function.
  """
  @spec s_shaped([...]) :: {fun(), any}
  def s_shaped([a, b, _]) when a <= b do
    c = (a + b) / 2

    mu = fn x ->
      cond do
        x <= a ->
          0

        a <= x and x <= (a + b) / 2 ->
          2 * pow((x - a) / (b - a), 2)

        (a + b) / 2 <= x and x <= b ->
          1 - 2 * pow((x - b) / (b - a), 2)

        x >= b ->
          1

        # Catch all
        true ->
          0
      end
    end

    {mu, c}
  end

  def s_shaped([_a, _b, _]), do: raise(ArgumentError, "a <= b is required.")

  @doc """
  Pi-shaped membership function.
  """
  @spec pi_shaped([...]) :: {fun(), any}
  def pi_shaped([a, b, c, d]) when a <= b and b <= c and c <= d do
    center = (a + d) / 2

    mu = fn x -> pi_shaped_func(x, a, b, c, d) end

    {mu, center}
  end

  def pi_shaped([_a, _b, _]), do: raise(ArgumentError, "a <= b <= c <= d is required.")

  defp pi_shaped_func(x, a, _b, _c, _d) when x <= a, do: 0

  defp pi_shaped_func(x, a, b, _c, _d) when a <= x and x <= (a + b) / 2,
    do: 2 * pow((x - a) / (b - a), 2)

  defp pi_shaped_func(x, a, b, _c, _d) when (a + b) / 2 <= x and x <= b,
    do: 1 - 2 * pow((x - b) / (b - a), 2)

  defp pi_shaped_func(x, _a, b, c, _d) when b <= x and x <= c, do: 1

  defp pi_shaped_func(x, _a, _b, c, d) when c <= x and x <= (c + d) / 2,
    do: 1 - 2 * pow((x - c) / (d - c), 2)

  defp pi_shaped_func(x, _a, _b, c, d) when (c + d) / 2 <= x and x <= d,
    do: 2 * pow((x - d) / (d - c), 2)

  defp pi_shaped_func(x, _a, _b, _c, d) when x >= d, do: 0
  defp pi_shaped_func(_x, _a, _b, _c, _d), do: 0

  @doc """
  For Takagi-Sugeno-Kang fuzzy inference, uses this output membership functions that are either constant
  or a linear function that will be combined with the input values.

  Example (2 inputs 1 output):
    z_i = a_i*x + b_i*y + c_i

  where,
    * `z_i` - is the i'th rule output.
    * `x, y` - are the values of input 1 and input 2, respectively.
    * `a_i, b_i, and c_i` - are constant coefficients of the i'th rule output.
    For a zero-order Takagi-Sugeno system, z_i is a constant (a = b = 0).

   ## Example (in Elixir)

      iex> {z_i_mf, nil} = MembershipFun.linear_combination([a_i, b_i, c_i])
      iex> z_i = z_i_mf.([x,y])
  """
  @spec linear_combination([...]) :: {fun(), nil}
  def linear_combination(coefficients) do
    mu = fn input_vector ->
      cond do
        # Invalid data type
        not is_list(input_vector) ->
          raise(
            ArgumentError,
            "Invalid input_vector data type: #{inspect(input_vector)}, it must be a list."
          )

        # Valid input_vector and coefficients.
        length(input_vector) + 1 == length(coefficients) ->
          {coefficients, [constant]} = Enum.split(coefficients, -1)
          linear_combination(input_vector, coefficients) + constant

        # Catch all
        true ->
          raise(
            ArgumentError,
            "Invalid size between the coefficients: #{inspect(coefficients)} and the input_vector: #{inspect(input_vector)} (length(input_vector) + 1 == length(coefficients))"
          )
      end
    end

    {mu, nil}
  end

  defp linear_combination(input_vector, coefficients) do
    input_vector
    |> Enum.zip(coefficients)
    |> Enum.reduce(0, fn {input, coefficient}, acc -> acc + input * coefficient end)
  end

  @doc """
  An interface to execute derivatives of membership functions, where,
    * `z_i` - is the i'th rule output.
    * `x, y` - are the values of input 1 and input 2, respectively.
    * `a_i, b_i, and c_i` - are constant coefficients of the i'th rule output.
    For a zero-order Takagi-Sugeno system, z_i is a constant (a = b = 0).
  """
  def derivative(fuzzy_set, input, membership_grade, darg_index) do
    case fuzzy_set.mf_type do
      "bell" ->
        d_gbell(fuzzy_set.mf_params, input, membership_grade, darg_index)

      "gaussian" ->
        d_gaussian(fuzzy_set.mf_params, input, membership_grade, darg_index)

      _ ->
        raise("Derivative #{inspect(fuzzy_set.mf_type)} not supported.")
    end
  end
end
