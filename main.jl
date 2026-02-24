include("src/utils.jl")
include("src/configs.jl")
include("src/objectives.jl")

using .Utils, .Configs, .Objectives
using CSV, DataFrames, MLJ, SymbolicRegression, Statistics
using Zygote

# === USER SETTINGS ===
dataset_name = "unimodal_a" # Name of the dataset
model_type   = "vanillaSR"  # "vanillaSR", "PCSR_wo_mode", or "PCSR_w_mode"

# 1. Load configuration and experimental data
cfg = get_dataset_config(dataset_name)
category = split(dataset_name, "_")[1] 
parent_folder = "results/$(category)-example"

df = CSV.read("./data/$(dataset_name)_experimental.csv", DataFrame; select=[2, 3])
rename!(df, [:pc, :Sw])

# 2. Preprocessing: Mapping to [0, 1] range
X = reshape(s_map(df.pc, cfg.pc_min, cfg.pc_res), :, 1)
y = Sw_map(df.Sw, cfg.Sw_res, cfg.Sw_max)

# 3. Prepare collocation points for physics constraints
col_pc = reshape(collect(range(0, stop=1, length=100)), 1, :)
set_global_context(col_pc, cfg)

# 4. Configure Symbolic Regression model
model = SRRegressor(
    niterations=5,
    binary_operators=(+, *),
    unary_operators=(sin, cos, exp, log),
    # population_size=50,
    # maxsize=150,
    loss_function=(tree, ds, opt) -> pcregressor_objective(tree, ds, opt, model_type),
    timeout_in_seconds=3600.0,
    turbo=true,

    output_directory = "$(parent_folder)/$(dataset_name)_$(model_type)_equations",
    save_to_file = true,
)

# 5. Execute Training
println("Starting training: [$model_type] on [$dataset_name]")
mach = machine(model, X, y)
fit!(mach; verbosity=1)

# 6. Report results
r = report(mach)
println("\nTraining Completed.")
println("Best Equation: ", r.equation_strings[r.best_idx])