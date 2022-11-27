struct ScaledPSDCone <: MOI.AbstractVectorSet
    side_dimension::Int
end

function MOI.Utilities.set_with_dimension(::Type{ScaledPSDCone}, dim)
    side_dimension = side_dimension_for_vectorized_dimension(dim)
    return ScaledPSDCone(side_dimension)
end

Base.copy(x::ScaledPSDCone) = ScaledPSDCone(x.side_dimension)

MOI.side_dimension(x::ScaledPSDCone) = x.side_dimension

function MOI.dimension(x::ScaledPSDCone)
    return div(x.side_dimension * (x.side_dimension + 1), 2)
end

struct ScaledPSDConeBridge{T,G} <: MOI.Bridges.Constraint.SetMapBridge{
    T,
    ScaledPSDCone,
    MOI.PositiveSemidefiniteConeTriangle,
    MOI.VectorAffineFunction{T},
    G,
}
    constraint::MOI.ConstraintIndex{MOI.VectorAffineFunction{T},ScaledPSDCone}
end

function MOI.Bridges.Constraint.concrete_bridge_type(
    ::Type{ScaledPSDConeBridge{T}},
    ::Type{G},
    ::Type{MOI.PositiveSemidefiniteConeTriangle},
) where {T,G<:Union{MOI.VectorOfVariables,MOI.VectorAffineFunction{T}}}
    return ScaledPSDConeBridge{T,G}
end

function MOI.Bridges.map_set(
    ::Type{<:ScaledPSDConeBridge},
    set::MOI.PositiveSemidefiniteConeTriangle,
)
    return ScaledPSDCone(set.side_dimension)
end

function MOI.Bridges.inverse_map_set(
    ::Type{<:ScaledPSDConeBridge},
    set::ScaledPSDCone,
)
    return MOI.PositiveSemidefiniteConeTriangle(set.side_dimension)
end

function _transform_function(
    func::MOI.VectorAffineFunction{T},
    scale,
    moi_to_scs::Bool,
) where {T}
    d = MOI.output_dimension(func)
    scale_factor = fill(scale, d)
    for i in 1:d
        if MOI.Utilities.is_diagonal_vectorized_index(i)
            scale_factor[i] = 1.0
        end
    end
    scaled_constants = func.constants .* scale_factor
    scaled_terms = MOI.VectorAffineTerm{T}[]
    for term in func.terms
        row = term.output_index
        push!(
            scaled_terms,
            MOI.VectorAffineTerm(
                row,
                MOI.ScalarAffineTerm(
                    term.scalar_term.coefficient * scale_factor[row],
                    term.scalar_term.variable,
                ),
            ),
        )
    end
    return MOI.VectorAffineFunction(scaled_terms, scaled_constants)
end

function _transform_function(func::MOI.VectorOfVariables, scale, moi_to_scs)
    new_f = MOI.Utilities.operate(*, Float64, 1.0, func)
    return _transform_function(new_f, scale, moi_to_scs)
end

function _transform_function(func::Vector{T}, scale, moi_to_scs::Bool) where {T}
    d = length(func)
    scale_factor = fill(scale, d)
    for i in 1:d
        if MOI.Utilities.is_diagonal_vectorized_index(i)
            scale_factor[i] = 1.0
        end
    end
    return func .* scale_factor
end

# Map ConstraintFunction from MOI -> SCS
function MOI.Bridges.map_function(::Type{<:ScaledPSDConeBridge}, f)
    return _transform_function(f, √2, true)
end

# Used to map the ConstraintPrimal from SCS -> MOI
function MOI.Bridges.inverse_map_function(::Type{<:ScaledPSDConeBridge}, f)
    return _transform_function(f, 1 / √2, false)
end

# Used to map the ConstraintDual from SCS -> MOI
function MOI.Bridges.adjoint_map_function(::Type{<:ScaledPSDConeBridge}, f)
    return _transform_function(f, 1 / √2, false)
end

# Used to set ConstraintDualStart
function MOI.Bridges.inverse_adjoint_map_function(
    ::Type{<:ScaledPSDConeBridge},
    f,
)
    return _transform_function(f, √2, true)
end
