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

| Function | Builds a list? | Tail version needs `reverse`? | `Enum` version |
|---|---|---|---|
| List sum | no | no | `Enum.sum/1` |
| Factorial | no | no | `Enum.reduce/3` |
| Fibonacci (linear) | no | no | `Enum.reduce/3` |
| List reverse | yes | — | `Enum.reverse/1` |
| Map | yes | yes | `Enum.map/2` |
| Filter | yes | yes | `Enum.filter/2` |
| Word count | [ ] | [ ] | [ ] |

Each function is implemented with three strategies: body recursion, tail recursion (with an accumulator) and `Enum`. The input sizes range from 10 to 1,000,000 elements.

**Metrics:** execution time, memory usage and reductions, measured with [Benchee](https://github.com/bencheeorg/benchee).

## Repository structure

```
.
├── lib/                  # Implementations (one module per function, three strategies each)
├── test/                 # ExUnit tests checking that all strategies return the same result
├── bench/                # Benchee scripts
├── results/              # Raw benchmark output (CSV/JSON) and environment information
├── analysis/             # Statistical analysis and figures used in the paper
├── mix.exs
└── README.md
```

## Requirements

- Erlang/OTP [version] (JIT enabled)
- Elixir [version]
- Benchee [version]

Run `elixir --version` and record the versions above. They are part of the experimental setup.

## How to reproduce

```bash
# 1. Install dependencies
mix deps.get

# 2. Check that all strategies are equivalent
mix test

# 3. Run the benchmarks (results are written to results/)
MIX_ENV=prod mix run bench/run_all.exs
```

Before running the benchmarks, close other applications and keep the machine plugged in, so that background load does not affect the measurements.

## Execution environment

The results in the paper were obtained on:

- CPU: [ ]
- RAM: [ ]
- OS: [ ]
- Erlang/OTP / Elixir: [ ]

## License

The source code is released under the [MIT License](LICENSE).

## Citation

If you use this code or data, please cite the paper above.
