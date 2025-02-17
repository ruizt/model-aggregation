## Citation

T.D. Ruiz, S. Bhattacharyya, S.C. Emerson (2025). Sparse estimation of parameter support sets for generalized vector autoregressions by resampling and model aggregation. *Journal of Statistical Computation and Simulation.*

## Contents

All codes were written by T.D. Ruiz.

1.  `matlab_codes` contains codes for the methodology implementation and most of the analysis in the paper.

    -   `0_cases_script.m` illustrates implementation of the methods compared in the paper on one simulated dataset

        -   `method2.m` implements the model aggregation method

        -   `method1.m` implements the "benchmark" method

        -   scripts beginning `sim_*` pertain to generating GVAR parameters and simulated data

    -   scripts beginning `1_simulation_*` execute simulations in the paper

    -   `0_diatom_analysis_script.m` executes the data application in the paper

        -   `method0.m` implements a naive LASSO estimate with cross-validated choice of $\lambda$

    -   remaining scripts are dependencies for subsampling/lasso/mle

2.  `r_codes` contains codes for the data visualizations and tables appearing in the paper, and data processing for the application

3.  `data` contains a copy of the diatom data from Barron *et al.* (2005) [[doi:10.25921/smet-t047](https://doi.org/10.25921/smet-t047){.uri}]

4.  `results` contains image files for manuscript figures and `.mat` files containing simulation and data analysis results
