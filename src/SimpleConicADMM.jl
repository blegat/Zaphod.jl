module SimpleConicADMM

using LinearAlgebra, SparseArrays

import MathOptInterface
const MOI = MathOptInterface

# Uncomment only one of the four following lines
include("solver.jl")
#include("sol0.jl")
#include("sol1.jl")
#include("sol2.jl")

include("MOI_wrapper.jl")

end # module
