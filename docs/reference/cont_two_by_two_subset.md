# Continuous Two-by-Two Subset

A function for computing a 2x2 subset of original data with a continuous
treatment. The cell is the same as in
[`ptetools::two_by_two_subset()`](https://rdrr.io/pkg/ptetools/man/two_by_two_subset.html)
(base period, comparison group, and anticipation as in
[`did::att_gt()`](https://bcallaway11.github.io/did/reference/att_gt.html));
the local treatment variable `D` is the dose for units in group `g` and
0 for comparison units.

## Usage

``` r
cont_two_by_two_subset(
  data,
  g,
  tp,
  control_group = "notyettreated",
  anticipation = 0,
  base_period = "varying",
  require_comparison = TRUE,
  ...
)
```

## Arguments

- data:

  the full dataset

- g:

  the current group

- tp:

  the current time period

- control_group:

  whether to use "notyettreated" (default), "nevertreated" or
  "eventuallytreated"

- anticipation:

  the number of periods of anticipation (i.e., number of periods before
  the treatment happens where the treatment can "already" affect the
  outcome)

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

- require_comparison:

  if `FALSE` (used by
  [`cont_did()`](https://bcallaway11.github.io/contdid/reference/cont_did.md)
  when no unit is untreated), the cell holds only group `g`'s own units,
  which is enough for the ACRT

- ...:

  extra arguments to get the subset correct

## Value

list that contains correct subset of data, `n1` number of observations
in this subset, and `disidx` a vector of the correct ids for this
subset.
