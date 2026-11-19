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
