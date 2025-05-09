using LinearAlgebra
using JuMP
using Test
import Zaphod

function test_SOC()
    model = Model(Zaphod.Optimizer)
    set_optimizer_attributes(
        model,
        "ϵ_primal" => 1e-5,
        "ϵ_dual" => 1e-5,
        "ϵ_gap" => 1e-5,
    )
    @variable(model, x[1:3] in SecondOrderCone())
    @constraint(model, x[1] == 1)
    @objective(model, Max, x[2] + x[3])
    optimize!(model)
    display(solution_summary(model))
    return value.(x)
end

@test test_SOC() ≈ inv.([1, √2, √2]) atol = 1e-4

function test_hermitian()
    model = Model(Zaphod.Optimizer)
    set_optimizer_attributes(
        model,
        "ϵ_primal" => 1e-5,
        "ϵ_dual" => 1e-5,
        "ϵ_gap" => 1e-5,
    )
    @variable(model, x)
    @objective(model, Max, x)
    @constraint(model, Hermitian([1 x * im; -x * im 1]) in HermitianPSDCone())
    optimize!(model)
    display(solution_summary(model))
    return value.(x)
end

@test test_hermitian() ≈ 1 atol = 1e-5
