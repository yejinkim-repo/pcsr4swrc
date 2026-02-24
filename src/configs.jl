module Configs
export get_dataset_config

# Dictionary to manage hyperparameters for 8 datasets
const DATASET_CONFIGS = Dict(
    "unimodal_a"   => (pc_min=1e-2, pc_res=1e5, Sw_res=0.075, Sw_max=1.0, N_mode=1),
    "unimodal_b"   => (pc_min=1e-1, pc_res=1e6, Sw_res=0.035, Sw_max=1.0, N_mode=1),
    "bimodal_a"    => (pc_min=1e-2, pc_res=1e5, Sw_res=0.1, Sw_max=1.0, N_mode=2),
    "bimodal_b"    => (pc_min=1e-1, pc_res=1e6, Sw_res=0.1, Sw_max=1.0, N_mode=2),
    "bimodal_c"    => (pc_min=1e-3, pc_res=1e6, Sw_res=0.35, Sw_max=1.0, N_mode=2),
    "bimodal_d"    => (pc_min=1e-1, pc_res=1e6, Sw_res=0.05, Sw_max=1.0, N_mode=2),
    "multimodal_a" => (pc_min=1e-2, pc_res=1e6, Sw_res=0.0, Sw_max=1.0, N_mode=3),
    "multimodal_b" => (pc_min=1e-2, pc_res=1e6, Sw_res=0.0, Sw_max=1.0, N_mode=4)
)

function get_dataset_config(name)
    return DATASET_CONFIGS[name]
end

end