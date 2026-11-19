# contdid 0.1.3

* Bug fix: `ATT(d)` and `ACRT(d)` from `cont_did()` with
  `aggregation = "dose"` were evaluated with a different B-spline basis
  than the one the dose regression was fitted with, unless `dvals`
  spanned exactly the range of the positive doses. With the default
  `dvals` (the 10% to 99% quantiles of the dose), the estimated
  dose-response curve was biased, most of all near the ends of the dose
  range. The basis now uses the range of the positive doses as its
  boundary knots everywhere (#16; thanks to @AsadGudzevic94).
* Bug fix: with groups and time periods coded as calendar years, naming the
  group column `G` gave `NaN` estimates (ptetools #13). `cont_did()` now
  stores the dose as an internal column, so it never overwrites a user's
  column, and selects each group-time subset using ptetools' internal
  columns only.
* `anticipation` now works: `setup_pte_cont()` did not pass it (or
  `base_period` and `required_pre_periods`) on to `ptetools::setup_pte()`,
  so groups without a valid base period were kept and estimation failed.
  `cont_two_by_two_subset()` now builds each cell with
  `ptetools::two_by_two_subset()`, so base periods, comparison groups and
  anticipation (in units of the time variable) follow `did::att_gt()`.
* A timing group with no more treated units than parameters in the dose
  regression now gives a clear error naming the group, instead of
  "something off with overall influence function" or "non-conformable
  arguments" (ptetools #17).
* `control_group` and `base_period` are now used (#19, #10). They were not
  passed on to ptetools, so `cont_did()` always used not-yet-treated
  comparison units and a varying base period, whatever was requested. With
  a universal base period, the outcome change is now computed between the
  base and current periods matched by unit, which also works when the base
  period comes after the current one (pre-treatment cells).
* `clustervars` now clusters standard errors (analytical and bootstrap) at
  a level above the unit, using ptetools' new support (ptetools #6). It was
  previously ignored with a warning. It is not supported with
  `dose_est_method = "cck"`.
* `bstrap = FALSE` (analytical standard errors) is now passed on to ptetools;
  it was ignored, so the multiplier bootstrap was always used. Analytical
  standard errors are not available for dose-specific effects, where the
  bootstrap is still used (with a warning).
* Bug fix: standard errors of ACRT (overall and event study) were too small
  by a factor equal to the share of treated units in each group-time cell
  (#13). The ACRT influence function was on the scale of the treated units
  only; it is now rescaled to all units, as for `ATT(d)`. In simulations
  the reported SEs were about a third of the actual sampling variability
  before and match it now. Thanks to @AsadGudzevic94 (#17).
* Require `ptetools (>= 1.0.2)`, which computes the standard errors of
  `ATT(d)` and `ACRT(d)` with the same basis. With older `ptetools`
  these standard errors would be too large near the ends of the dose
  range.

# contdid 0.1.2

* Bug fix: `cont_did()` with `target_parameter = "level"` and
  `aggregation = "eventstudy"` passed the continuous dose, rather than a
  treated/comparison indicator, to the underlying DiD estimator. This
  made the estimator weight treated units by their dose and put weight
  on some treated units in the comparison group, so event-study `ATT`
  estimates from earlier versions were biased when treatment effects
  are nonzero. With DRDID >= 1.4.0, which now requires a binary
  treatment indicator, this case failed with an error instead. Other
  combinations of `target_parameter` and `aggregation` were not
  affected.

# contdid 0.1.1

* Resubmission to CRAN following archival on 2026-07-16 (contdid was
  archived because its dependency `ptetools` had been archived;
  `ptetools` has since been restored to CRAN as version 1.0.1).
* Require `ptetools (>= 1.0.1)` in `Imports` to prevent recurrence.
* Update `ggcont_did()` to use `ptetools`'s `autoplot()` methods in
  place of the now-deprecated `ggpte()`/`ggpte_cont()`.

# contdid 0.1.0

* Initial CRAN submission.
* CCK estimation is working for case with two periods.
* Change default parametric specification to cubic polynomial.
* Bug fix for variable names.

# contdid 0.0.002

* Added sanity checks for unexpected input data.

# contdid 0.0.001

* Initial version.
