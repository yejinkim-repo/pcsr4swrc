module Objectives
using SymbolicRegression, DynamicDiff, DynamicExpressions, Statistics

# Export the functions to be used in main.jl
export set_global_context, pcregressor_objective

# Global storage for collocation points used in physics loss
global_col_pc = nothing
global_cfg = nothing

function set_global_context(col_pc, cfg)
    global global_col_pc = col_pc
    global global_cfg = cfg
end

# Core objective function incorporating Physics-Informed constraints
function pcregressor_objective(tree, dataset::Dataset{T,L}, options::Options, model_type::String) where {T,L}
    # 1. Prediction and Gradient evaluation
    pc_combined = hcat(global_col_pc, dataset.X)
    pred_combined, grad_combined, flag = eval_grad_tree_array(tree, pc_combined, options; variable=true)
    !flag && return L(Inf)

    pred_col_Sw = pred_combined[1:100]
    pred_Sw     = pred_combined[101:end]
    grad_col_Sw = grad_combined[1:100]

    # 2. Data Loss: Standard MSE
    L_data = sum(abs2, pred_Sw .- dataset.y) / length(dataset.y)
    model_type == "vanillaSR" && return L_data

    # 3. Physics Loss: Monotonicity & Boundary conditions
    L_mono = sum(g -> g <= 0.0 ? 0.0 : abs2(g), grad_col_Sw) / length(grad_col_Sw)
    L_init = abs2(global_cfg.Sw_max - pred_col_Sw[1]) + abs2(grad_col_Sw[1])
    L_res  = abs2(0.0 - pred_col_Sw[end]) + abs2(grad_col_Sw[end])

    total_loss = L_data + L_mono + L_init + L_res

    # 4. Mode Loss: Inflection points (PCSR_w_mode only)
    if model_type == "PCSR_w_mode"
        operators = OperatorEnum(binary_operators=options.operators.binops, unary_operators=options.operators.unaops)
        expr_f = Expression(tree; operators=operators, variable_names=["x"])
        eq_d2fdx2 = D(D(expr_f, 1), 1)
        d2_vals = vec(eq_d2fdx2(reshape(global_col_pc, 1, :)))
        
        # Count sign changes in 2nd derivative to check inflection points
        pred_N_mode = count_sign_changes_v2(d2_vals) 
        total_loss += abs2(pred_N_mode - global_cfg.N_mode)
    end

    return total_loss
end

# Helper to count sign changes (used for mode detection)
function count_sign_changes_v2(vals)
    count = 0
    for i in 1:(length(vals)-1)
        if vals[i] * vals[i+1] < 0; count += 1; end
    end
    return count
end

end