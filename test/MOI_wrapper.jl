module TestZaphod

using Test
using JuMP
import Zaphod

function test_runtests()
    optimizer = Zaphod.Optimizer()
    # The most demanding test is `test_conic_PositiveSemidefiniteConeTriangle`
    # which requires 1083 iterations.
    MOI.set(optimizer, MOI.RawOptimizerAttribute("max_iters"), 2000)
    MOI.set(optimizer, MOI.Silent(), true) # comment this to enable output
    model = MOI.Bridges.full_bridge_optimizer(
        MOI.Utilities.CachingOptimizer(
            MOI.Utilities.UniversalFallback(MOI.Utilities.Model{Float64}()),
            optimizer,
        ),
        Float64,
    )
    config = MOI.Test.Config(
        atol = 1e-2,
        exclude = Any[
            MOI.ConstraintBasisStatus,
            MOI.VariableBasisStatus,
            MOI.ConstraintName,
            MOI.VariableName,
            MOI.ObjectiveBound,
        ],
    )
    MOI.Test.runtests(model, config)
    return
end

function runtests()
    for name in names(@__MODULE__; all = true)
        if startswith("$(name)", "test_")
            @testset "$(name)" begin
                getfield(@__MODULE__, name)()
            end
        end
    end
    return
end

end  # module

TestZaphod.runtests()
