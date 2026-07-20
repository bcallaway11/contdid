# =============================================================================
# Title: Local reverse dependency check
# Description: Runs revdeplite against contdid's CRAN reverse dependencies
#   before a CRAN submission. Faster local substitute for the full
#   revdepcheck run done in CI (revdep-check.yml).
# Author: Brant Callaway
# Last update: 2026-07-20
# Date created: 2026-07-20
# =============================================================================

revdeplite::revdeplite(
  target_package = "contdid",
  github_deps = NULL, # no known GitHub-only reverse dependents currently
  check_dir = ".revdeplite"
)
