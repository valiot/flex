<br>
<div align="center">
  <img src="assets/valiot-logo-blue.png" alt="Valiot Logo" width="192" height="57" />
</div>
<br>
***

# Flex

A WIP toolkit for fuzzy logic, this library includes functions to make fuzzy sets, variables and rules for creating a Fuzzy Logic System (FLS).

The goal of the FLex is to easily design and efficiently operate fuzzy logic controllers without relying on external libraries.

## Index

* [Features](#features)

* [Installation](#installation)

* [Usage](#usage)

    * [Sets](#sets)
    * [Variables](#variables)
    * [Rules](#rules)
    * [System](#system)

* [Documentation](#documentation)

* [Contributing](#contributing)

* [License](#License)

* [TODO](#todo)

## Features

The following list is the current supported backend for each component of the FLS.

- Linguistic Rules:
  - Lambda function syntax
  - Tuple syntax

- Membership functions:
  - Triangular
  - Trapezoidal
  - Saturation
  - Shoulder

- Inference:
  - Min

- Output Combination:
  - Root-sum-square

- Defuzzification:
  - Centroid


## Installation

The package can be installed by adding `flex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flex, "~> 0.1.0"}
  ]
end
```

## Usage
***
### Sets
**Step 1:** Define all fuzzy sets with `Flex.Set.new/1`, the following options are require:
  - `mf_type` - (string) Defines which type of membership function use the set (e.g., "triangle").
  - `tag` - (string) defines the linguistic name of the fuzzy set (e.g., "too hot"),
  - `mf_params` - The parameters of the membership function, see Membership functions.

```elixir
t_h = Flex.Set.new(tag: "too hot", mf_type: "saturation", mf_params: [-2, 0, -4])
j_r = Flex.Set.new(tag: "just right", mf_type: "triangle", mf_params: [-2, 0, 2])
t_c = Flex.Set.new(tag: "too cold", mf_type: "shoulder", mf_params: [0, 2, 4])

g_h = Flex.Set.new(tag: "getting hotter", mf_type: "saturation", mf_params: [-5, 0, -10])
n_c = Flex.Set.new(tag: "no change", mf_type: "triangle", mf_params: [-5, 0, 5])
g_c = Flex.Set.new(tag: "getting colder", mf_type: "shoulder", mf_params: [0, 5, 10])

co = Flex.Set.new(tag: "cool", mf_type: "saturation", mf_params: [-50, 0, -100])
d_n = Flex.Set.new(tag: "do nothing", mf_type: "triangle", mf_params: [-50, 0, 50])
he = Flex.Set.new(tag: "heat", mf_type: "shoulder", mf_params: [0, 50, 100])
```
### Variables
**Step 2:** Define all fuzzy variables with `Flex.Variable.new/1`, the following options are required:
  * `:tag` - (string) Defines the linguistic name of the fuzzy variable (e.g., "error"),
  * `:fuzzy_sets` - (list) Defines which type of membership function use the set (e.g., "triangle").
  * `:type` - (atom) Defines the type of variable (e.g., :antecedent or :consequent),
  * `:range` - (range) The range in which the variable exist.

```elixir
fuzzy_sets = [t_h, j_r, t_c]
error = Flex.Variable.new(tag: "error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -4..4)

fuzzy_sets = [g_h, n_c, g_c]
dt_error = Flex.Variable.new(tag: "dt_error", fuzzy_sets: fuzzy_sets, type: :antecedent, range: -10..10)

fuzzy_sets = [co, d_n, he]
output = Flex.Variable.new(tag: "output", fuzzy_sets: fuzzy_sets, type: :consequent, range: -100..100)
```
### Rules
Currently there are two types of syntax for defining the rules `statement`:
  * Anonymous function syntax:
```elixir
  r1 = fn [at1, at2, con] ->
      (at1 ~> "too hot" &&& at2 ~> "getting colder") >>> con ~> "cool"
    end
```
  * Tuple syntax:
```elixir
  r1 = {{{{"error", "too hot", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
      ">>>"}, "cool", "~>"}
```
**Step 3:** Define all Linguistic rules with `Flex.Rule.new/1`, the following options are required:
  - `:statement` - Defines the rule behavior.
  - `:antecedent` - (list) Defines the input variables.
  - `:consequent` - Defines the output variable.

```elixir
  import Flex.Rule
  r1 =
    {{{{"error", "too hot", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
      ">>>"}, "cool", "~>"}

  r2 =
    {{{{"error", "just right", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
      ">>>"}, "heat", "~>"}

  r3 =
    {{{{"error", "too cold", "~>"}, {"dt_error", "getting colder", "~>"}, "&&&"}, "output",
      ">>>"}, "heat", "~>"}

  r4 =
    {{{{"error", "too hot", "~>"}, {"dt_error", "no change", "~>"}, "&&&"}, "output", ">>>"},
      "cool", "~>"}

  r5 =
    {{{{"error", "just right", "~>"}, {"dt_error", "no change", "~>"}, "&&&"}, "output", ">>>"},
      "do nothing", "~>"}

  r6 =
    {{{{"error", "too cold", "~>"}, {"dt_error", "no change", "~>"}, "&&&"}, "output", ">>>"},
      "heat", "~>"}

  r7 =
    {{{{"error", "too hot", "~>"}, {"dt_error", "getting hotter", "~>"}, "&&&"}, "output",
      ">>>"}, "cool", "~>"}

  r8 =
    {{{{"error", "just right", "~>"}, {"dt_error", "getting hotter", "~>"}, "&&&"}, "output",
      ">>>"}, "cool", "~>"}

  r9 =
    {{{{"error", "too cold", "~>"}, {"dt_error", "getting hotter", "~>"}, "&&&"}, "output",
      ">>>"}, "cool", "~>"}

  rule1 = Flex.Rule.new(statement: r1, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule2 = Flex.Rule.new(statement: r2, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule3 = Flex.Rule.new(statement: r3, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule4 = Flex.Rule.new(statement: r4, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule5 = Flex.Rule.new(statement: r5, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule6 = Flex.Rule.new(statement: r6, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule7 = Flex.Rule.new(statement: r7, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule8 = Flex.Rule.new(statement: r8, consequent: output.tag, antecedent: [error.tag, dt_error.tag])
  rule9 = Flex.Rule.new(statement: r9, consequent: output.tag, antecedent: [error.tag, dt_error.tag])

  rules = [rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8, rule9]

```
**Note**: You need to `import Flex.Rule` module.

### System
**Step 4:** Define FLS with `Flex.System.start_link/1` or `Flex.System.start_link/2` if you want to overwrite the GenServer options; the following options are require:
  - `:rules` - Defines the behavior of the system based on the a list of rules.
  - `:antecedent` - (list) Defines the input variables.
  - `:consequent` - Defines the output variable.

```elixir
  {:ok, s_pid} = Flex.System.start_link(antecedent: [error, dt_error], consequent: output, rules: rules)
```

**Step 5:** Fit the FLS with a input vector using `Flex.System.compute/2`.
```elixir
  result = Flex.System.compute(s_pid, [-1, -2.5])
  #result ~= -63.4 aprox
```

In `test/system_test.exs` there is an example of use, that is based on this [example](http://robotics.ee.uwa.edu.au/courses/faulttolerant/notes/FT5.pdf).

## Documentation
The docs can be found at [https://hexdocs.pm/flex](https://hexdocs.pm/flex).

## Contributing
  * Fork our repository on github.
  * Fix or add what is needed.
  * Commit to your repository.
  * Issue a github pull request (fill the PR template).

## License
  See [LICENSE](./LICENSE).

## TODO
**TODO: Refactor.**
