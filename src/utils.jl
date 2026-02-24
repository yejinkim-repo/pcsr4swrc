module Utils

using CSV
using DataFrames
using Base.Threads: SpinLock

export s_map, Sw_map, update_list_with_lock, count_sign_changes_v2

"""
    s_map(x, x_min, x_max)
Normalize capillary pressure (pc) to [0, 1] range using log-scale.
"""
function s_map(x::Real, x_min::Real, x_max::Real)
    x_bar = log10(x)
    return (x_bar - log10(x_min)) / (log10(x_max) - log10(x_min))
end

function s_map(x::AbstractVector, x_min::Real, x_max::Real)
    return [(log10(x_) - log10(x_min)) / (log10(x_max) - log10(x_min)) for x_ in x]
end

"""
    Sw_map(y, y_min, y_max)
Normalize water saturation (Sw) to [0, 1] range.
"""
function Sw_map(y::Real, y_min::Real, y_max::Real)
    return (y - y_min) / (y_max - y_min)
end

function Sw_map(y::AbstractVector, y_min::Real, y_max::Real)
    return [(y_ - y_min) / (y_max - y_min) for y_ in y]
end

"""
    update_list_with_lock(lock_obj, data_list, value)
Thread-safe update of loss containers during symbolic regression.
"""
function update_list_with_lock(lock_obj::SpinLock, data_list::Vector, value)
    lock(lock_obj) do
        push!(data_list, value)
    end
end

"""
    count_sign_changes_v2(d2_vals; tol=1e-2)
Calculate the number of modes based on sign changes in the 2nd derivative.
Incorporates a tolerance to ignore numerical noise.
"""
function count_sign_changes_v2(d2_vals; tol=1e-2, outlier_threshold=1e10)
    # Helper to determine sign with tolerance
    function sign_tol(x::Real)
        if isnan(x) || isinf(x) || abs(x) > outlier_threshold
            return 0.0
        elseif x > tol
            return 1.0
        elseif x < -tol
            return -1.0
        else
            return 0.0
        end
    end
    
    signs = sign_tol.(d2_vals)
    
    # Identify transition points while skipping zeros
    sign_changes_idx = []
    for i in 2:length(signs)
        curr = signs[i]
        if curr == 0.0; continue; end
        
        # Find the last non-zero sign to compare
        prev = 0.0
        for j in (i-1):-1:1
            if signs[j] != 0.0
                prev = signs[j]
                break
            end
        end
        
        if prev != 0.0 && prev != curr
            push!(sign_changes_idx, i)
        end
    end
    
    # Mapping sign changes to mode count
    return (length(sign_changes_idx) + 1) ÷ 2
end

end  # module Utils