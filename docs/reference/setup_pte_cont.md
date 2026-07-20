# Setup for DiD with a Continuous Treatment

A function that creates a pte_params object, adding several different
variables that are needed when there is a continuous treatment.

## Usage

``` r
setup_pte_cont(
  yname,
  gname,
  tname,
  idname,
  data,
  xformula = ~1,
  target_parameter,
  aggregation,
  treatment_type,
  required_pre_periods = 1,
  anticipation = 0,
  base_period = "varying",
  cband = TRUE,
  alp = 0.05,
  boot_type = "multiplier",
  weightsname = NULL,
  gt_type = "att",
  biters = 100,
  cl = 1,
  dname,
  dvals = NULL,
  degree = 1,
  num_knots = 0,
  ...
)
```

## Arguments

- yname:

  Name of outcome in `data`

- gname:

  Name of group in `data`

- tname:

  Name of time period in `data`

- idname:

  Name of id in `data`

- data:

  balanced panel or repeated cross sections data

- xformula:

  A formula for additional covariates. This is not currently supported.

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

- required_pre_periods:

  The number of required pre-treatment periods to implement the
  estimation strategy. Default is 1.

- anticipation:

  how many periods before the treatment actually takes place that it can
  have an effect on outcomes

- base_period:

  The type of base period to use. This only affects the numeric value of
  results in pre-treatment periods. Results in post-treatment periods
  are not affected by this choice. The default is "varying", where the
  base period will "back up" to the immediately preceding period in
  pre-treatment periods. The other option is "universal" where the base
  period is fixed in pre-treatment periods to be the period right before
  the treatment starts. "Universal" is commonly used in
  difference-in-differences applications, but can be unnatural for other
  identification strategies.

- cband:

  whether or not to report a uniform (instead of pointwise) confidence
  band (default is TRUE)

- alp:

  significance level; default is 0.05

- boot_type:

  which type of bootstrap to use

- weightsname:

  The name of the column that contains sampling weights. The default is
  NULL, in which case no sampling weights are used.

- gt_type:

  which type of group-time effects are computed. The default is "att".
  Different estimation strategies can implement their own choices for
  `gt_type`

- biters:

  number of bootstrap iterations; default is 100

- cl:

  number of clusters to be used when bootstrapping; default is 1

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

- dvals:

  an optional argument specifying which values of the treatment to
  evaluate ATT(d) and/or ACRT(d). If no values are supplied, then the
  default behavior is to set `dvals` to be the 1st to 99th percentiles
  of the dose among units that experience any positive dose.

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

- ...:

  additional arguments

## Value

`pte_params` object
