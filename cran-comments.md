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

**CRAN comment:** Please add more details about the package functionality and implemented methods in your Description text.

**Response:** The DESCRIPTION text has been updated to include more details about the package functionality and the implemented methods.

---

**CRAN comment:** If there are references describing the methods in your package, please add these in the description field of your DESCRIPTION file

**Response:** The DESCRIPTION file has been updated to include a reference to the paper that proposed the approaches implemented in the package.

---

**CRAN comment:** Please add \value to .Rd files regarding exported methods and explain the functions results in the documentation. Missing Rd-tags: ggcont_did.Rd: \value

**Response:** The documentation for `ggcont_did` has been updated to indicate that it returns a ggplot object. The \value tag has been added to the documentation.

---

**CRAN comment:** Please add small executable examples in your Rd-files to illustrate the use of the exported function but also enable automatic testing.

**Response:** Added a small executable example for the `cont_did` function, which is the main function of the package.  Also, added an example for the `ggcont_did` function, though this example is not run automatically due to the need for a graphical output. The examples are now included in the documentation.