# Simulate data for DiD with a Continuous Treatment

A function that simulates panel data when there is a continuous
treatment.

Besides the parameters that can be passed to the function, some values
are hard coded. The individual fixed effect is drawn from a normal
distribution with mean equal to the group. The time effects are hard
coded to be equal to the time period. The dose is drawn from a uniform
distribution between 0 and 1.

## Usage

``` r
simulate_contdid_data(
  n = 5000,
  num_time_periods = 4,
  num_groups = num_time_periods,
  pg = rep(1/num_groups, num_groups - 1),
  pu = 1/(num_groups),
  dose_linear_effect = 0,
  dose_quadratic_effect = 0
)
```

## Arguments

- n:

  The number of cross-sectional units. Default is 5000.

- num_time_periods:

  The number of time periods. Default is 4.

- num_groups:

  The number of groups. Default is the number of time periods. In this
  case, the groups will consist of a never-treated group and groups that
  become treated in every period starting in the second period.

- pg:

  A vector of probabilities that a unit will be in a particular treated
  group. The default is equal probabilities.

- pu:

  The probability that a unit will be in the never-treated group. The
  default is that it is 1/num_groups.

- dose_linear_effect:

  The linear effect of the treatment. Default is 0.

- dose_quadratic_effect:

  The quadratic effect of the treatment. Default is 0.

## Value

A balanced panel data frame with the following columns:

- id: unit id

- time_period: time period

- Y: outcome

- G: unit's group

- D: amount of the treatment
