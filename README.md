# HTOP for Elixir 

An interactive process inspector for Elixir. It helps you: 

- monitor the most CPU intensive job
- trace a process 

This project is inspired by `htop` for Unix and borros the initial code for inspection and tracing from [sasa1977/demo_system](https://github.com/sasa1977/demo_system).

### Main functions 

In order to get the PID of the processes ordered by CPU usage, you can call Htop.top

```
Htop.top()
```

If you want to trace a process with Htop use

```
Htop.trace(pid)
```

## Roadmap

- [ ] graphic visualization of processed like htop
- [ ] more utilities around inspections of which functions and params a process has been calling 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `htop` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:htop, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/htop](https://hexdocs.pm/htop).

### License

```
Copyright 2019 Lorenzo Sinisi

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

```
