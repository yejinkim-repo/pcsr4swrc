# pcsr4swrc
A Julia-based framework for discovering water retention curve equations via symbolic regression. 

This repository contains the source code and results for the paper titled:
**"Physics-constrained symbolic regression for discovering closed-form equations of multimodal water retention curves from experimental data"**  
(*Manuscript currently under revision*)


## Installation
This framework is built with Julia. To set up the environment, run the following commands in the Julia REPL:
```julia
using Pkg
Pkg.add(["SymbolicRegression", "MLJ", "Zygote", "DynamicDiff", "CSV", "DataFrames", "Roots"])
```


## Usage
You can run all 24 experimental combinations (8 datasets × 3 model types) by modifying only two variables in `main.jl`.

### 1. Configuration
Open `main.jl` and set the following parameters:
```
dataset_name = "unimodal_a"   # Options: unimodal_a/b, bimodal_a~d, multimodal_a/b
model_type   = "PCSR_w_mode"  # Options: vanillaSR, PCSR_wo_mode, PCSR_w_mode
```

### 2. Execution
Run the script using multiple threads for optimal performance:
```
julia --threads auto main.jl
```


## Structure
The project is organized to manage experiments and results systematically:
- **`main.jl`**: The entry point for training and evaluation.
- **`src/`**: Core source code modules.
    - **`configs.jl`**: Dataset-specific hyperparameters (e.g., $p_{c,min}$, $N_{mode}$).
    - **`objectives.jl`**: Physics-informed loss function implementations.
    - **`utils.jl`**: Data normalization and mathematical utilities.
- **`data/`**: Experimental CSV files.
- **`results/`**: Automatically categorized output folders.
    - `[category]-example/`: Results sorted by soil structure (unimodal/bimodal/multimodal).
- **`LICENSE`**: Open-source license (MIT).

## Structure
```text
├── main.jl                             # Main execution script
├── data/                               # Experimental CSV datasets
│   ├── unimodal_a_experimental.csv
│       ...
├── src/                                # Source code modules
│   ├── configs.jl                      # Dataset-specific hyperparameters
│   ├── objectives.jl                   # Physics-informed loss functions
│   └── utils.jl                        # Normalization & math utilities
├── results/                            # Output directory (automatically generated)
│   ├── unimodal-example/
│   ├── bimodal-example/
│   └── multimodal-example/
├── requirements.txt                    # Dependency list
└── LICENSE                             # MIT License
```
    


## Data preparation
To apply this framework to your own data:
1. File Naming: Save your data in the `data/` folder as `{dataset_name}_experimental.csv`.
2. Parameters: Add the corresponding physical parameters to `src/configs.jl`.
3. Run: Set the `dataset_name` in `main.jl` and execute.


## Status
- The paper is currently under peer review.
- The full dataset and source code are maintained here.
- For citation, please refer to the latest Zenodo release: [https://doi.org/10.5281/zenodo.16764203]
