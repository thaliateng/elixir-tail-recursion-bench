quick? = System.get_env("QUICK") == "1"

selected_functions =
  case System.get_env("FUNCTIONS") do
    nil -> :all
    list -> list |> String.split(",", trim: true) |> Enum.map(&String.trim/1)
  end

# Parameters

list_sizes =
  if quick?,
    do: [10, 1_000],
    else: [10, 100, 1_000, 10_000, 100_000, 1_000_000]

# BodyRecursion.reverse/1 is quadratic and would take hours on 100_000+ elements,
# so it is capped here; tail and Enum run on all sizes in "reverse_large".
body_reverse_limit = if quick?, do: 1_000, else: 10_000

# Factorial and Fibonacci results grow as bignums, so they use smaller values of n.
integer_values =
  if quick?,
    do: [10, 100],
    else: [10, 100, 1_000, 5_000, 10_000]

time_config =
  if quick? do
    [warmup: 0.5, time: 1, memory_time: 0.5, reduction_time: 0.5]
  else
    [warmup: 2, time: 5, memory_time: 2, reduction_time: 2]
  end

# Inputs, generated once and shared by all strategies

label = fn n -> "n = #{n}" end

lists = for n <- list_sizes, do: {label.(n), Inputs.integer_list(n)}
body_reverse_lists = Enum.filter(lists, fn {_, l} -> length(l) <= body_reverse_limit end)
large_reverse_lists = Enum.filter(lists, fn {_, l} -> length(l) > body_reverse_limit end)
sentences = for n <- list_sizes, do: {label.(n), Inputs.sentences(n)}
integers = for n <- integer_values, do: {label.(n), n}

double = &Inputs.double/1
even? = &Inputs.even?/1

# Experiments: {name, jobs, inputs}

experiments = [
  {"sum",
   %{
     "body_recursion" => &BodyRecursion.sum/1,
     "tail_recursion" => &TailRecursion.sum/1,
     "enum" => &EnumFunctions.sum/1
   }, lists},
  {"factorial",
   %{
     "body_recursion" => &BodyRecursion.factorial/1,
     "tail_recursion" => &TailRecursion.factorial/1,
     "enum" => &EnumFunctions.factorial/1
   }, integers},
  {"fibonacci",
   %{
     "body_recursion" => &BodyRecursion.fibonacci/1,
     "tail_recursion" => &TailRecursion.fibonacci/1,
     "enum" => &EnumFunctions.fibonacci/1
   }, integers},
  {"reverse",
   %{
     "body_recursion" => &BodyRecursion.reverse/1,
     "tail_recursion" => &TailRecursion.reverse/1,
     "enum" => &EnumFunctions.reverse/1
   }, body_reverse_lists},
  {"reverse_large",
   %{
     "tail_recursion" => &TailRecursion.reverse/1,
     "enum" => &EnumFunctions.reverse/1
   }, large_reverse_lists},
  {"map",
   %{
     "body_recursion" => fn l -> BodyRecursion.map(l, double) end,
     "tail_recursion" => fn l -> TailRecursion.map(l, double) end,
     "enum" => fn l -> EnumFunctions.map(l, double) end
   }, lists},
  {"filter",
   %{
     "body_recursion" => fn l -> BodyRecursion.filter(l, even?) end,
     "tail_recursion" => fn l -> TailRecursion.filter(l, even?) end,
     "enum" => fn l -> EnumFunctions.filter(l, even?) end
   }, lists},
  {"count_words",
   %{
     "body_recursion" => &BodyRecursion.count_words/1,
     "tail_recursion" => &TailRecursion.count_words/1,
     "enum" => &EnumFunctions.count_words/1
   }, sentences}
]

experiments =
  case selected_functions do
    :all ->
      experiments

    names ->
      Enum.filter(experiments, fn {name, _, _} ->
        name in names or (name == "reverse_large" and "reverse" in names)
      end)
  end

# Environment record

File.mkdir_p!("results")

os_version =
  case :os.version() do
    v when is_tuple(v) -> v |> Tuple.to_list() |> Enum.join(".")
    v -> to_string(v)
  end

environment = """
Date (UTC): #{DateTime.utc_now() |> DateTime.to_iso8601()}
Mode: #{if quick?, do: "quick", else: "full"}
Elixir: #{System.version()}
Erlang/OTP: #{:erlang.system_info(:otp_release)}
System version: #{:erlang.system_info(:system_version) |> to_string() |> String.trim()}
Emulator flavor: #{:erlang.system_info(:emu_flavor)}
Logical processors: #{:erlang.system_info(:logical_processors)}
Schedulers online: #{:erlang.system_info(:schedulers_online)}
OS: #{inspect(:os.type())} #{os_version}
List sizes: #{inspect(list_sizes, charlists: :as_lists)}
Body-recursive reverse limit: #{body_reverse_limit}
Factorial and Fibonacci values: #{inspect(integer_values, charlists: :as_lists)}
Times (s): #{inspect(time_config)}
"""

File.write!("results/environment.txt", environment)
IO.puts(environment)

# Run

for {name, jobs, inputs} <- experiments, inputs != [] do
  IO.puts("\n=== #{name} ===\n")

  Benchee.run(
    jobs,
    time_config ++
      [
        inputs: inputs,
        title: name,
        pre_check: true,
        formatters: [
          Benchee.Formatters.Console,
          {Benchee.Formatters.CSV, file: "results/#{name}.csv"},
          {Benchee.Formatters.JSON, file: "results/#{name}.json"}
        ]
      ]
  )
end
