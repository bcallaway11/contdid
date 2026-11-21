## Submission summary

This submission (0.1.3) fixes several bugs and adds features. It requires
`ptetools` (>= 1.1.0), which was submitted to CRAN just before this
release. `ptetools` 1.1.0 changes the internal column names its setup
functions use, which breaks `contdid` 0.1.2 on CRAN; this release adapts
to it. See NEWS.md for the full list. The main changes:

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

## Test environments

- Local Ubuntu 26.04.1 LTS, R 4.5.2
- GitHub Actions
    - windows-latest (R release)
    - windows-latest (R devel)
    - macos-latest (R release)
    - ubuntu-latest (R release)
    - ubuntu-latest (R devel)
    - All five: Status OK (0 errors, 0 warnings, 0 notes)

## R CMD check results

`R CMD check --as-cran`:

0 errors | 0 warnings | 0 notes

(Locally, there is one NOTE that HTML validation of the manual was skipped
because HTML Tidy is not installed on the check machine.)

* CRAN's incoming checks have previously flagged possibly misspelled
  words in DESCRIPTION: "Callaway", "Sant'Anna". These are correctly
  spelled author surnames cited in the package description (Callaway,
  Goodman-Bacon, and Sant'Anna, 2025).

## Reverse dependencies

There are currently no CRAN reverse dependencies for this package.
