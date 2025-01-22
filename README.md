
<!-- README.md is generated from README.Rmd. Please edit that file -->

# contdid

<!-- badges: start -->
<!-- badges: end -->

An R package for difference-in-differences with a continuous treatment.

## Installation

You can install the development version of contdid from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bcallaway11/contdid")
#> Using GitHub PAT from the git credential store.
#> Downloading GitHub repo bcallaway11/contdid@HEAD
#> rlang    (1.1.4        -> 1.1.5       ) [CRAN]
#> clock    (0.7.1        -> 0.7.2       ) [CRAN]
#> ptetools (09c94b90d... -> 0bd0233b5...) [GitHub]
#> Installing 2 packages: rlang, clock
#> Installing packages into '/tmp/RtmpZC7eqR/temp_libpath8a017420da7b5'
#> (as 'lib' is unspecified)
#> Adding 'clock_0.7.2.tar.gz' to the cache
#> Adding 'rlang_1.1.5.tar.gz' to the cache
#> Adding 'clock_0.7.2_R_x86_64-pc-linux-gnu.tar.gz' to the cache
#> Adding 'rlang_1.1.5_R_x86_64-pc-linux-gnu.tar.gz' to the cache
#> Downloading GitHub repo bcallaway11/ptetools@HEAD
#> 
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#> * checking for file ‘/tmp/RtmpI27sMv/remotes19ff029535807/bcallaway11-ptetools-0bd0233/DESCRIPTION’ ... OK
#> * preparing ‘ptetools’:
#> * checking DESCRIPTION meta-information ... OK
#> * checking for LF line-endings in source and make files and shell scripts
#> * checking for empty or unneeded directories
#> Omitted ‘LazyData’ from DESCRIPTION
#> * building ‘ptetools_0.0.1.tar.gz’
#> Installing package into '/tmp/RtmpZC7eqR/temp_libpath8a017420da7b5'
#> (as 'lib' is unspecified)
#> Adding 'clock_0.7.2.tar.gz' to the cache
#> Adding 'rlang_1.1.5.tar.gz' to the cache
#> ── R CMD build ─────────────────────────────────────────────────────────────────
#> * checking for file ‘/tmp/RtmpI27sMv/remotes19ff0239ebedbf/bcallaway11-contdid-e8b692b01297be608521a9b1923f3f0be8ba7e4f/DESCRIPTION’ ... OK
#> * preparing ‘contdid’:
#> * checking DESCRIPTION meta-information ... OK
#> * checking for LF line-endings in source and make files and shell scripts
#> * checking for empty or unneeded directories
#> Omitted ‘LazyData’ from DESCRIPTION
#> * building ‘contdid_0.0.001.tar.gz’
#> Installing package into '/tmp/RtmpZC7eqR/temp_libpath8a017420da7b5'
#> (as 'lib' is unspecified)
#> Adding 'clock_0.7.2.tar.gz' to the cache
#> Adding 'rlang_1.1.5.tar.gz' to the cache
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(contdid)

devtools::load_all("~/Dropbox/contdid")
#> ℹ Loading contdid
#> Registered S3 methods overwritten by 'ptetools':
#>   method                    from
#>   print.group_time_att      pte 
#>   print.pte_results         pte 
#>   print.summary.pte_results pte 
#>   summary.group_time_att    pte 
#>   summary.pte_emp_boot      pte 
#>   summary.pte_results       pte
devtools::load_all("~/Dropbox/ptetools")
#> ℹ Loading ptetools
# Simulate data
set.seed(123)
sp <- did::reset.sim()
df <- did::build_sim_dataset(sp)
n <- length(unique(df$id))
D <- runif(n, 0, 1)
# make some untreated units
df$D <- BMisc::time_invariant_to_panel(D, df, "id")
# df$D <- df$D * (df$period >= df$G) * (df$G != 0)
# df <- df[, c("id", "period", "Y", "D")]
cd_res <- cont_did(
  yname = "Y",
  tname = "period",
  idname = "id",
  dname = "D",
  data = df,
  gname = "G",
  target_parameter = "slope",
  aggregation = "dose",
  treatment_type = "continuous",
  control_group = "notyettreated",
  biters = 10,
  cl = 10,
  num_knots = 3,
  degree = 3
)
#> Warning in cont_did(yname = "Y", tname = "period", idname = "id", dname = "D",
#> : clustered standard errors not tested yet, may not work
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: attgt_fun(gt_data = gt_data, ...)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#199: Xe <- sandwich::estfun(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#200: bread <- sandwich::bread(bs_reg)
#> debug at /home/bmc43193/Dropbox/contdid/R/cont_did.R#214: attgt_if(attgt = acrt.overall, inf_func = rep(NA, nrow(Xe)), 
#>     extra_gt_returns = list(att.d = att.d, acrt.d = acrt.d, att.overall = att.overall, 
#>         acrt.overall = acrt.overall, bet = bs_reg_coef, bread = bread, 
#>         Xe = Xe))
#> Warning in this.inf_func[disidx] <- attgt$inf_func: number of items to replace
#> is not a multiple of replacement length
#> Called from: process_dose_gt_fun(res, ptep)
#> debug: att_gt <- process_att_gt(gt_results, ptep)
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in max(abs(b/boot_se), na.rm = TRUE): no non-missing arguments to max;
#> returning -Inf
#> Warning in mboot2(inffunc, alp = alp): critical value for uniform confidence band is somehow smaller than
#>             critical value for pointwise confidence interval...using pointwise
#>             confidence interal
#> Warning in process_att_gt(gt_results, ptep): Not returning pre-test Wald
#> statistic due to NA pre-treatment values
#> debug: o_weights <- overall_weights(att_gt, ...)
#> Called from: overall_weights(att_gt, ...)
#> debug: group <- attgt$group
#> debug: time.period <- attgt$t
#> debug: att <- attgt$att
#> debug: inf_func <- attgt$inf_func
#> debug: ptep <- attgt$ptep
#> debug: bstrap <- ptep$bstrap
#> debug: if (is.null(bstrap)) bstrap <- TRUE
#> debug: bstrap <- TRUE
#> debug: cband <- ptep$cband
#> debug: alp <- ptep$alp
#> debug: biters <- ptep$biters
#> debug: data <- ptep$data
#> debug: tname <- ptep$tname
#> debug: gname <- ptep$gname
#> debug: glist <- sort(unique(group))
#> debug: tlist <- sort(unique(time.period))
#> debug: first_period_data <- data[data[, tname] == tlist[1], ]
#> debug: originalt <- time.period
#> debug: originalgroup <- group
#> debug: originalglist <- glist
#> debug: originaltlist <- tlist
#> debug: time.period <- sapply(originalt, orig2t, originaltlist)
#> debug: group <- sapply(originalgroup, orig2t, originaltlist)
#> debug: glist <- sapply(originalglist, orig2t, originaltlist)
#> debug: tlist <- unique(time.period)
#> debug: maxT <- max(time.period)
#> debug: weights.ind <- first_period_data$.w
#> debug: pg <- sapply(originalglist, function(g) mean(weights.ind * (first_period_data[, 
#>     gname] == g)))
#> debug: pg <- pg/sum(pg)
#> debug: pgg <- pg
#> debug: pg <- pg[match(group, glist)]
#> debug: keeper <- group <= time.period & time.period <= (group + max_e)
#> debug: g_weight <- sapply(glist, function(g) {
#>     is_this_g <- (group == g) & (g <= time.period) & (time.period <= 
#>         (group + max_e))
#>     this_pg <- pg[is_this_g][1]
#>     this_pg/sum(is_this_g)
#> })
#> debug: out_weight <- g_weight[match(group, glist)] * keeper
#> debug: if (sum(out_weight) != 1) stop("something's going wrong calculating overall weights")
#> debug: data.frame(group = group, time.period = time.period, overall_weight = out_weight)
#> debug: 1 + 1


# ggpte(cd_res)
```
