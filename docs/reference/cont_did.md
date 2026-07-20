# Difference-in-differences with a Continuous Treatment

A function for difference-in-differences with a continuous treatment in
a staggered treatment adoption setting.

`cont_did` currently supports staggered treatment with continuous
treatments using B-splines under the hood.

## Usage

``` r
cont_did(
  yname,
  dname,
  gname = NULL,
  tname,
  idname,
  xformula = ~1,
  data,
  target_parameter = c("level", "slope"),
  aggregation = c("dose", "eventstudy", "none"),
  treatment_type = c("continuous", "discrete"),
  dose_est_method = c("parametric", "cck"),
  dvals = NULL,
  degree = 3,
  num_knots = 0,
  allow_unbalanced_panel = FALSE,
  control_group = c("notyettreated", "nevertreated", "eventuallytreated"),
  anticipation = 0,
  weightsname = NULL,
  alp = 0.05,
  bstrap = TRUE,
  cband = FALSE,
  boot_type = "multiplier",
  biters = 1000,
  clustervars = NULL,
  est_method = NULL,
  base_period = "varying",
  print_details = FALSE,
  cl = 1,
  ...
)
```

## Arguments

- yname:

  The name of the outcome variable

- dname:

  The name of the treatment variable in the data. The functionality of
  `cont_did` is different from the `did` package in that the treatment
  variable is the "amount" of the treatment in a particular period,
  rather than `gname` which gives the time period when a unit becomes
  treated. The `dname` variable should, for a particular unit, be
  constant across time periods—even in pre-treatment periods. For units
  that never participate in the treatment, the amount of the treatment
  may not be defined in some applications—it is ignored in this
  function.

- gname:

  The name of the timing-group variable, i.e., when treatment starts for
  a particular unit. The value of this variable should be set to be 0
  for units that do not participate in the treatment in any time period.

- tname:

  The name of the column containing the time periods

- idname:

  The individual (cross-sectional unit) id name

- xformula:

  A formula for additional covariates. This is not currently supported.

- data:

  The name of the data.frame that contains the data

- target_parameter:

  Two options are "level" and "slope". In the first case, the function
  will report level effects, i.e., ATT's. In the second case, the
  function will report slope effects, i.e., ACRT's

- aggregation:

  "dose" averages across timing-groups and time periods and provides
  results as a function of the dose. "eventstudy" averages across
  timing-groups and doses and reports results as a function of the
  length of exposure to the treatment.

  "none" is a stub for reporting fully disaggregated results that can be
  processed as desired by the user. This is not currently supported
  though.

  The combination of the arguments `target_parameter` and `aggregation`
  strongly affects the behavior of the function (and target of the
  analysis). For example, setting `target_parameter="level"` and
  `aggregation="eventstudy"` is effectively the same thing as binarizing
  the treatment (i.e., where units are considered treated if they
  experience any positive amount of the treatment) and reporting an
  event study.

- treatment_type:

  "continuous" or "discrete" depending on the nature of the treatment.
  Default is "continuous". "discrete" is not yet supported.

- dose_est_method:

  The method used to estimate the dose-specific effects. The default is
  "parametric", where the user needs to specify the number of knots and
  degree for a B-spline which is assumed to be correctly specified. The
  other option is "cck" which uses the a data-driven nonparametric
  method to estimate the dose-specific effects based on the `npiv`
  package and Chen, Christensen, and Kankanala (ReStud, 2025).

- dvals:

  The values of the treatment at which to compute dose-specific effects.
  If it is not specified, the default choice will be use the percentiles
  of the dose among all ever-treated units.

- degree:

  The degree of the B-Spline used in estimation. The default is 3, which
  in combination with the default choice for the `num-knots`, leads to
  fitting models for the group of treated units that only that is a
  cubic polynomial in the dose. Setting `degree=1` will lead to a linear
  model, while setting `degree=2` will lead to a quadratic model.

- num_knots:

  The number of knots to include for the B-Spline. The default is 0 so
  that the spline is global (i.e., this will amount to fitting a global
  polynomial). There is a bias-variance tradeoff for including more or
  less knots.

- allow_unbalanced_panel:

  Whether or not function should "balance" the panel with respect to
  time and id. The default value is `FALSE` which means that
  [`att_gt()`](https://bcallaway11.github.io/did/reference/att_gt.html)
  will drop all units where data is not observed in all periods. The
  advantage of this is that the computations are faster (sometimes
  substantially).

- control_group:

  Which units to use as the control group. The default is "nevertreated"
  which sets the control group to be the group of units that never
  participate in the treatment. This group does not change across groups
  or time periods. The other option is to set `group="notyettreated"`.
  In this case, the control group is set to the group of units that have
  not yet participated in the treatment in that time period. This
  includes all never treated units, but it includes additional units
  that eventually participate in the treatment, but have not
  participated yet.

- anticipation:

  The number of time periods before participating in the treatment where
  units can anticipate participating in the treatment and therefore it
  can affect their untreated potential outcomes

- weightsname:

  The name of the column containing the sampling weights. If not set,
  all observations have same weight. When weights are time-invariant
  (constant within each unit across periods), all `fix_weights` options
  produce identical results and no special handling is needed.

  When weights vary across time (e.g., time-varying population sizes),
  the default behavior differs by panel type:

  Balanced panel

  :   Each 2x2 DiD comparison uses the weight from the earlier of the
      two time periods involved. For post-treatment cells, this is the
      base period (g-1). For pre-treatment cells with
      `base_period="varying"`, this is the pre-treatment period itself.
      The panel DRDID estimators are used.

  Repeated cross sections and unbalanced panels

  :   Both periods' per-observation weights are passed directly to the
      RC DRDID estimators, so each observation carries its own
      period-specific weight.

  Use the `fix_weights` argument to override the default behavior.

- alp:

  the significance level, default is 0.05

- bstrap:

  Boolean for whether or not to compute standard errors using the
  multiplier bootstrap. Default is `TRUE` (in addition, cband is also by
  default `TRUE` indicating that uniform confidence bands will be
  returned). If `bstrap=FALSE`, analytical standard errors are reported;
  these are cluster-robust when `clustervars` is supplied.

- cband:

  Boolean for whether or not to compute a uniform confidence band that
  covers all of the group-time average treatment effects with fixed
  probability `1-alp`. In order to compute uniform confidence bands,
  `bstrap` must also be set to `TRUE`. The default is `TRUE`.

- boot_type:

  should be one of "multiplier" (the default) or "empirical". The
  multiplier bootstrap is generally much faster, but `attgt_fun` needs
  to provide an expression for the influence function (which could be
  challenging to figure out). If no influence function is provided, then
  the `pte` package will use the empirical bootstrap no matter what the
  value of this parameter.

- biters:

  The number of bootstrap iterations to use. The default is 1000, and
  this is only applicable if `bstrap=TRUE`.

- clustervars:

  A vector of variables names to cluster on. At most, there can be two
  variables (otherwise will throw an error) and one of these must be the
  same as idname which allows for clustering at the individual level.
  Clustered standard errors are available with the multiplier bootstrap
  (`bstrap=TRUE`) or analytically (`bstrap=FALSE`).

- est_method:

  the method to compute group-time average treatment effects. The
  default is "dr" which uses the doubly robust approach in the `DRDID`
  package. Other built-in methods include "ipw" for inverse probability
  weighting and "reg" for first step regression estimators. The user can
  also pass their own function for estimating group time average
  treatment effects. The required signature depends on the data
  structure:

  **Panel data** (`panel=TRUE`):
  `f(y1, y0, D, covariates, i.weights, inffunc, ...)` where `y1` is an
  `n x 1` vector of post-treatment outcomes, `y0` is an `n x 1` vector
  of pre-treatment outcomes, `D` is a binary vector indicating treatment
  group membership, `covariates` is an `n x k` matrix, `i.weights` is a
  vector of sampling weights, and `inffunc` is a logical requesting
  influence-function computation.

  **Repeated cross sections / unbalanced panel** (`panel=FALSE`):
  `f(y, post, D, covariates, i.weights, inffunc, ...)` where `y` is the
  outcome vector (length `n`), `post` is a binary indicator for the
  post-treatment period, `D` is a binary treatment indicator,
  `covariates` is an `n x k` matrix, `i.weights` is a vector of sampling
  weights, and `inffunc` is a logical.

  In both cases the function should return a list that includes `ATT`
  (the estimated group-time average treatment effect) and `att.inf.func`
  (an `n x 1` influence function — one entry per observation passed into
  the estimator). The function can return other things as well, but
  these are the only two that are required. With no covariates
  (`xformla = NULL`), the built-in methods ("dr", "ipw", "reg") all
  reduce to the unconditional difference-in-differences estimator, so
  the choice among them is irrelevant; a custom `est_method` function is
  still called (with an intercept-only `covariates` matrix) and
  determines the estimates.

- base_period:

  Whether to use a "varying" base period or a "universal" base period.
  Either choice results in the same post-treatment estimates of
  ATT(g,t)'s. In pre-treatment periods, using a varying base period
  amounts to computing a pseudo-ATT in each treatment period by
  comparing the change in outcomes for a particular group relative to
  its comparison group in the pre-treatment periods (i.e., in
  pre-treatment periods this setting computes changes from period t-1 to
  period t, but repeatedly changes the value of t)

  A universal base period fixes the base period to always be
  (g-anticipation-1). This does not compute pseudo-ATT(g,t)'s in
  pre-treatment periods, but rather reports average changes in outcomes
  from period t to (g-anticipation-1) for a particular group relative to
  its comparison group. This is analogous to what is often reported in
  event study regressions.

  Using a varying base period results in an estimate of ATT(g,t) being
  reported in the period immediately before treatment. Using a universal
  base period normalizes the estimate in the period right before
  treatment (or earlier when the user allows for anticipation) to be
  equal to 0, but one extra estimate in an earlier period.

- print_details:

  Whether or not to show details/progress of computations. Default is
  `FALSE`.

- cl:

  number of clusters to be used when bootstrapping; default is 1

- ...:

  Additional arguments to be passed to a custom `est_method` function.
  These are ignored when using built-in estimation methods (`"dr"`,
  `"ipw"`, `"reg"`).

## Value

cont_did_obj

## Examples

``` r
# build small simulated data
set.seed(1234)
df <- simulate_contdid_data(
  n = 1000,
  num_time_periods = 4,
  num_groups = 4,
  dose_linear_effect = 0,
  dose_quadratic_effect = 0
)

# estimate effects of continuous treatment
cd_res <- cont_did(
  yname = "Y",
  tname = "time_period",
  idname = "id",
  dname = "D",
  data = df,
  gname = "G",
  target_parameter = "slope",
  aggregation = "dose",
  treatment_type = "continuous",
  control_group = "notyettreated",
  biters = 50,
  cband = TRUE,
  num_knots = 1,
  degree = 3,
)
#> Warning: critical value for uniform confidence band is somehow smaller than
#>             critical value for pointwise confidence interval...using pointwise
#>             confidence interal

summary(cd_res)
#> 
#> Overall ATT:  
#>      ATT    Std. Error     [ 95%  Conf. Int.] 
#>  -0.0332        0.0726    -0.1754      0.1091 
#> 
#> 
#> Overall ACRT:  
#>     ACRT    Std. Error     [ 95%  Conf. Int.]  
#>  -0.2988         0.143     -0.579     -0.0186 *
#> ---
#> Signif. codes: `*' confidence band does not cover 0
#> 
```
