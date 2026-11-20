## Submission summary

This submission (0.1.3) fixes several bugs and adds features. It requires
`ptetools` 1.1.0, submitted to CRAN at the same time. See NEWS.md for the
full list. The main changes:

* Bug fix: the standard errors of `ATT(d)` were too small (the
  comparison-group part of its influence function had the wrong sign in
  `ptetools` 1.0.1), so confidence bands undercovered. The standard errors
  of the ACRT were also too small, by a factor equal to the share of
  treated units in each group-time cell.
* Bug fix: `ATT(d)` and `ACRT(d)` were evaluated with a different B-spline
  basis than the one used for fitting, biasing the dose-response curve
  near the ends of the dose range.
* Arguments that were accepted but ignored now work: sampling weights
  (`weightsname`), `control_group`, `base_period`, `anticipation`,
  `clustervars` and `bstrap`.
* Repeated cross sections are supported for the level event study
  (`panel = FALSE`).

<!-- TODO at submission: refresh the test environments, R CMD check
results (--as-cran) and GitHub Actions results below; they are from 0.1.2. -->

## Test environments

- Local Ubuntu 24.04.5 LTS, R 4.6.1 (with `DRDID` 1.4.0):
    - All checks passed without issues.
- GitHub Actions
    - Windows-latest (R release)
    - Windows-latest (R devel)
    - macOS-latest (R release)
    - Ubuntu-latest (R release)
    - Ubuntu-latest (R devel)
    - All checks passed without issues.

## R CMD check results

0 errors | 0 warnings | 0 notes

* CRAN's incoming checks have previously flagged possibly misspelled
  words in DESCRIPTION: "Callaway", "Sant'Anna". These are correctly
  spelled author surnames cited in the package description (Callaway,
  Goodman-Bacon, and Sant'Anna, 2025).

## Reverse dependencies

There are currently no CRAN reverse dependencies for this package.
