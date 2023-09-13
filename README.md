# Zaphod.jl

[![Build Status](https://github.com/blegat/Zaphod.jl/workflows/CI/badge.svg?branch=master)](https://github.com/blegat/Zaphod.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/blegat/Zaphod.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/blegat/Zaphod.jl)

[Zaphod.jl](https://github.com/blegat/Zaphod.jl) (**Z**aphod is an  **A**DMM/**P**roximal solver for the **Ho**mogeneous Self-**D**ual Embedding) is a simple implementation of an ADMM solver
for conic programs interfacing with [MathOptInterface (MOI)](https://github.com/jump-dev/MathOptInterface.jl).

Much like Zaphod Beeblebrox, its plan is to remain stupidely simple (following the KISS principle) and let its dependencies do all the work.

It is not meant to be the most efficient but rather to be a good example for learning how to write a solver
for [JuMP](https://github.com/jump-dev/JuMP.jl).

The implementation follows quite closely what's described in [SCS paper](https://web.stanford.edu/~boyd/papers/scs.html).

The solver is quite similar to SCS and COSMO although SCS and COSMO should be much faster (as their goal is to be fast, not only simple) and they also support quadratic objective.
One important difference is that Zaphod uses [MathOptSetDistances](https://github.com/matbesancon/MathOptSetDistances.jl).
Therefore, any `MOI.AbstractVectorSet` that satisfies the following 5 conditions is automatically supported:
* `MOI.dual_set` is implemented
* `MathOptSetDistances.projection_on_set` is implemented
* `MOI.Utilities.set_dot` is equivalent to `LinearAlgebra.dot` (we could work around this similarly to how [Dualization](https://github.com/jump-dev/Dualization.jl) to scale `A'` and `b'` of the `Q` matrix equation (8) of the [SCS paper](https://web.stanford.edu/~boyd/papers/scs.html) but for the program to remain self-dual we would actually need to scale both `A'` and `A` by the square root of the scaling so it's equivalent to bridging to the scaled version of the cones, see https://github.com/blegat/Zaphod.jl/pull/2)
* The set is included in the `SUPPORTED_CONE` `Union` in `src/MOI_wrapper.jl`
* The set is included in the `Cones` `@product_of_sets` in `src/MOI_wrapper.jl`

This was used for
* the *Implementation of a solver in Julia* tutorial in the algorithmic bootcamp of the [TraDE-OPT Workshop on Algorithmic and Continuous Optimization](https://trade-opt-itn.eu/workshop-program.html) in July 2022 and
* the *How to write your own conic solver* tutorial in the *Mathematical Optimization in Julia with JuMP* [summer school of the 7th International Conference on Continuous Optimization (ICCOPT)](https://iccopt2022.lehigh.edu/summer-school/summer-school-program/) in July 2022.

## License

`Zaphod.jl` is licensed under the [MIT License](https://github.com/blegat/Zaphod.jl/blob/master/LICENSE.md).

## Installation

Install Zaphod as follows:
```julia
import Pkg
Pkg.add(url="https://github.com/blegat/Zaphod.jl")
```

## Use with JuMP

To use Zaphod with JuMP, use `Zaphod.Optimizer`:

```julia
using JuMP, Zaphod
model = Model(Zaphod.Optimizer)
set_attribute(model, "max_iters", 600)
```

## MathOptInterface API

The Zaphod optimizer supports the following constraints and attributes.

List of supported objective functions:

 * [`MOI.ObjectiveFunction{MOI.ScalarAffineFunction{Float64}}`](@ref)

List of supported variable types:

 * [`MOI.Reals`](@ref)

List of supported constraint types:

 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.EqualTo{Float64}`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.Zeros`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.Nonnegatives`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.SecondOrderCone`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.ExponentialCone`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.DualExponentialCone`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.PowerCone`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.DualPowerCone`](@ref)
 * [`MOI.VectorAffineFunction{Float64}`](@ref) in [`MOI.Scaled{MOI.PositiveSemidefiniteConeTriangle}`](@ref)

## Options

The list of options are

| Option name    | Default value |
|----------------|---------------|
| `max_iters`    | 100           |
| `ϵ_primal`     | 1e-4          |
| `ϵ_dual`       | 1e-4          |
| `ϵ_gap`        | 1e-4          |
| `ϵ_unbounded`  | 1e-7          |
| `ϵ_infeasible` | 1e-7          |
