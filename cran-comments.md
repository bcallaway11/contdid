## Submission summary

This submission (0.1.2) fixes the ERRORs currently shown on the CRAN check
results page for `contdid`. They were triggered by the release of `DRDID`
1.4.0 (2026-10-22), which now requires the treatment indicator passed to
`DRDID::drdid_panel()` to be binary.

* For the level event-study case of `cont_did()`, `contdid` was passing
  the continuous dose (through `ptetools::did_attgt()`) where `DRDID`
  expects a 0/1 treatment indicator. The dose is now converted to a
  treated/comparison indicator before that call. This also fixes the
  estimates in that case, which were incorrect with earlier versions of
  `DRDID`.
* Adds a unit test checking that the level event study recovers a known,
  nonzero treatment effect.

No other functional changes are included.

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
