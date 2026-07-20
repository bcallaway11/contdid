## Resubmission after CRAN archival

`contdid` was archived from CRAN on 2026-07-16 because its dependency
`ptetools` had itself been archived ("requires archived package
'ptetools'"). `ptetools` has since been fixed and republished on CRAN
(version 1.0.1, 2026-07-20).

This submission (0.1.1):

* Requires `ptetools (>= 1.0.1)` in `Imports`, to guard against this
  recurring.
* Updates `ggcont_did()` to call `ptetools`'s new `autoplot()` methods,
  since the functions it previously called (`ggpte()`, `ggpte_cont()`)
  are now deprecated in `ptetools` 1.0.1.

No other functional changes are included.

## Test environments

- Local Ubuntu 24.04.4 LTS, R 4.6.1: all checks passed without issues.
- GitHub Actions (R-CMD-check.yml): Windows (release, devel), macOS
  (release), Ubuntu (release, devel) — to be run via `workflow_dispatch`
  before submission; results to be added here.

## R CMD check results

0 errors | 0 warnings | 1 note

* Package was archived on CRAN (see explanation above).
