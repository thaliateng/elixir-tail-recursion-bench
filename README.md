# elixir-tail-recursion-bench

Experimental comparison of **body recursion**, **tail recursion** and **`Enum` higher-order functions** in Elixir, measuring execution time, memory usage and reductions on the BEAM virtual machine.

This repository contains the source code, benchmarks, tests and raw results that support the paper:

> Filipe Leonardo dos Santos Leitzke, Thalia Wu Teng, and Adolfo Gustavo Serra Seca Neto. *Recursão de Cauda versus Recursão Comum em Elixir: Uma Avaliação Experimental de Desempenho e Uso de Memória na BEAM*. Graduate Program in Applied Computing (PPGCA), Federal University of Technology – Paraná (UTFPR), 2026.

## Motivation

Elixir has no loops: repetition is written with recursion or with functions from the `Enum` module. A common belief is that tail-recursive functions are always faster and use less memory than body-recursive ones. The Erlang Efficiency Guide lists this as one of the "seven myths" of Erlang performance. This project tests that belief with a controlled experiment.

## Research questions

- **RQ1:** Is tail recursion faster and more memory-efficient than body recursion in Elixir?
- **RQ2:** How do `Enum` functions compare with hand-written recursive versions?
- **RQ3:** How do the differences change as the input size grows?

## Experimental design

| Function | Elixir name | Builds a list? | Tail version needs `reverse`? | `Enum` version |
|---|---|---|---|---|
| List sum | `sum/1` | no | no | `Enum.sum/1` |
| Factorial | `factorial/1` | no | no | `Enum.reduce/3` |
| Fibonacci | `fibonacci/1` | no | no | `Enum.reduce/3` |
| List reverse | `reverse/1` | yes | no | `Enum.reverse/1` |
| Map | `map/2` | yes | yes | `Enum.map/2` |
| Filter | `filter/2` | yes | yes | `Enum.filter/2` |
| Word count | `count_words/1` | no | no | `Enum.reduce/3` |

Each function is implemented with three strategies, one module per strategy:

- `BodyRecursion` (`lib/body_recursion.ex`): body recursion;
- `TailRecursion` (`lib/tail_recursion.ex`): tail recursion with an accumulator;
- `EnumFunctions` (`lib/enum_functions.ex`): functions from the `Enum` module.

Inputs are generated deterministically by `Inputs` (`lib/inputs.ex`):

- lists of integers from 1 to *n*, with *n* in {10, 100, 1,000, 10,000, 100,000, 1,000,000};
- for word count, *n* sentences with 10 words each, drawn from a fixed vocabulary with a fixed seed;
- for factorial and Fibonacci, *n* in {10, 100, 1,000, 5,000, 10,000}, because results grow as big integers.

Fibonacci uses the linear definition (fib(0) = 0, fib(1) = 1): the body-recursive version computes pairs and does the addition after the recursive call, and the tail-recursive version carries the last two values as accumulators.

The body-recursive `reverse/1` uses `reverse(tail) ++ [head]`, which is quadratic, so it is only measured up to 10,000 elements. Tail recursion and `Enum` are measured on all sizes in a separate experiment (`reverse_large`).

**Metrics:** execution time, memory usage and reductions, measured with [Benchee](https://github.com/bencheeorg/benchee).

## Repository structure

```
.
├── lib/
│   ├── body_recursion.ex    # body recursion
│   ├── tail_recursion.ex    # tail recursion
│   ├── enum_functions.ex    # Enum functions
│   └── inputs.ex            # deterministic input generation
├── test/
│   └── equivalence_test.exs # equivalence tests for the three strategies
├── bench/
│   └── run_all.exs          # Benchee script for all functions
├── results/                 # summary CSVs and run environment
├── mix.exs
└── README.md
```

## Requirements

- Erlang/OTP 25 or later (JIT enabled)
- Elixir 1.16.1 or later. Benchee reports incorrect memory measurements on Elixir 1.14 up to 1.16.0-rc.0.
- Benchee 1.3 or later, with `benchee_csv` and `benchee_json` (installed by `mix deps.get`)
- Linux for time measurements. On Windows, the Erlang monotonic clock may advance in steps of about 0.1 ms even though it reports a 100 ns resolution, which makes most run times meaningless. Memory and reductions do not depend on the clock.

The exact versions and the clock resolution used in each run are written to `results/environment.txt`.

## How to reproduce

```bash
# 1. Install dependencies
mix deps.get

# 2. Check that all strategies return the same results
mix test

# 3. Quick run, only to check that everything works (a few minutes)
QUICK=1 mix bench

# 4. Full experiment (takes a long time)
mix bench

# Optional: run only some functions
FUNCTIONS=sum,map mix bench

# Optional: measure only reductions, keeping the time and memory results
REDUCTIONS_ONLY=1 mix bench
```

Environment variables:

- `QUICK=1`: short run with fewer sizes and shorter measurement times, only to check that everything works. Do not use its numbers in the paper.
- `FUNCTIONS=<list>`: comma-separated subset of `sum`, `factorial`, `fibonacci`, `reverse`, `map`, `filter`, `count_words`. `reverse` also runs `reverse_large`.
- `REDUCTIONS_ONLY=1`: measures only reductions and writes only `<function>_reductions.csv` and `results/environment_reductions.txt`.

Each experiment writes three files to `results/`:

- `<function>.csv`: summary statistics of run time and memory (average, median, minimum, maximum, standard deviation, sample size);
- `<function>_reductions.csv`: summary statistics of reductions, since `benchee_csv` and `benchee_json` do not export them;
- `<function>.json`: all raw samples of run time and memory, for the statistical analysis.

The run also writes `results/environment.txt` with the date, mode, Elixir and OTP versions, emulator flavor, number of logical processors and schedulers, OS, clock resolution, input sizes and measurement times.

The JSON files are large, so they are not committed. The ones used in the paper are attached to the [GitHub Releases](https://github.com/thaliateng/elixir-tail-recursion-bench/releases) of this repository.

Before the full run, close other applications, keep the machine plugged in and do not use it while the benchmarks run, so that background load does not affect the measurements.

## Execution environment

Run time and memory (`results/<function>.csv` and the JSON files) were measured on:

- CPU: Intel Core i5-1334U (10 cores: 2 performance + 8 efficiency; 12 threads)
- RAM: 15 GiB
- OS: Arch Linux, kernel 7.2.14-zen
- Erlang/OTP / Elixir: OTP 29 (erts-17.1, JIT) / Elixir 1.20.4
- CPU frequency governor: powersave (intel_pstate); notebook plugged in and not used during the run

Details are in `results/environment.txt` and `results/machine.txt`.

Reductions (`results/<function>_reductions.csv`) were measured separately, because they do not depend on the clock, on:

- CPU: AMD Ryzen 7 2700X (8 cores, 16 threads)
- RAM: 32 GB DDR4-2667 installed; 15.9 GB usable by Windows
- OS: Windows 10 Pro 10.0.19045
- Erlang/OTP / Elixir: OTP 29 (erts-17.0.5, JIT) / Elixir 1.20.3

Details are in `results/environment_reductions.txt`.

## License

The source code is released under the [MIT License](LICENSE).

## Citation

If you use this code or data, please cite the paper above.
