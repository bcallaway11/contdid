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
