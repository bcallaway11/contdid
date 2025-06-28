## Test environments

- Local Ubuntu 24.04, R 4.4.1:
    - All checks passed without issues.
- Github Actions
    - Windows-latest (R release)
    - Windows-latest (R devel)
    - macOS-latest (R release)
    - Ubuntu-latest (R release)
    - Ubuntu-latest (R devel)
    - All checks passed without issues.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new package submission.

## Resubmission of a new package

This is a resubmission of a new package that has not yet been accepted to CRAN.
The resubmission addresses the comments from the CRAN review of the initial submission.

**CRAN comment:** Please do not start the description with "This package", package name,
title or similar.

**Response:** The description has been updated to remove the phrase "The package..."

---

**CRAN comment:** \dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...)

**Response:** Repaced \dontrun{} with \donttest for example for `ggcont_did`, which was the
only instance of its use in the package, as this example takes more than 5 seconds to run.