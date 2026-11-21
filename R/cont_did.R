# =============================================================================
# Title: Main estimation functions for contdid
# Description: cont_did() and the (g,t)-level estimators and data subsetting
#   it hands to ptetools for DiD with a continuous treatment
# Author: Brant Callaway
# Last update: 2026-11-21
# Date created: 2024-09-11
# =============================================================================

#' @title Difference-in-differences with a Continuous Treatment
#'
#' @description A function for difference-in-differences with a continuous treatment in a
#'  staggered treatment adoption setting.
#'
#'  `cont_did` currently supports staggered treatment with continuous treatments using
#'  B-splines under the hood.
#'
#' @param dname The name of the treatment variable in the data.  The functionality of
#'  `cont_did` is different from the `did` package in that the treatment variable is
#'  the "amount" of the treatment in a particular period, rather than `gname` which
#'  gives the time period when a unit becomes treated.  The `dname` variable should,
#'  for a particular unit, be constant across time periods---even in pre-treatment periods.
#'  For units that never participate in the treatment, the amount of the treatment may
#'  not be defined in some applications---it is ignored in this function.
#' @inheritParams did::att_gt
#' @inheritParams ptetools::pte
#' @param xformula A formula for additional covariates.  This is not currently supported.
#' @param weightsname The name of a column of sampling weights in `data`,
#'  constant over time within each unit (default `NULL`, no weights). The
#'  weights are used in the dose regressions, the comparison-group means,
#'  the averages over the dose distribution and the aggregation across
#'  timing groups, and in the corresponding influence functions. The
#'  default `dvals` and the spline knots are chosen from the unweighted
#'  dose distribution. Not supported with `dose_est_method = "cck"`.
#' @param gname The name of the timing-group variable, i.e., when treatment starts for
#'  a particular unit.  The value of this variable should be set to be 0 for units that
#'  do not participate in the treatment in any time period.
#' @param target_parameter Two options are "level" and "slope".  In the first case, the function
#'  will report level effects, i.e., ATT's.  In the second case, the function will report
#'  slope effects, i.e., ACRT's
#' @param aggregation "dose" averages across timing-groups and time periods and provides results
#'  as a function of the dose.  "eventstudy" averages across timing-groups and doses and reports
#'  results as a function of the length of exposure to the treatment.
#'
#'  "none" is a stub for reporting fully disaggregated results that can be processed as desired
#'  by the user.  This is not currently supported though.
#'
#'  The combination of the arguments `target_parameter` and `aggregation` strongly affects the
#'  behavior of the function (and target of the analysis).  For example, setting
#'  `target_parameter="level"` and `aggregation="eventstudy"` is effectively the same thing
#'  as binarizing the treatment (i.e., where units are considered treated if they experience any
#'  positive amount of the treatment) and reporting an event study.
#'
#' @param treatment_type "continuous" or "discrete" depending on the nature of the treatment.
#'  Default is "continuous".  "discrete" is not yet supported.
#'
#' @param dose_est_method The method used to estimate the dose-specific effects.  The default
#'  is "parametric", where the user needs to specify the number of knots and degree for
#'  a B-spline which is assumed to be correctly specified.  The other option is "cck"
#'  which uses the a data-driven nonparametric method to estimate the dose-specific effects
#'  based on the `npiv` package and Chen, Christensen, and Kankanala (ReStud, 2025).
#'
#' @param dvals The values of the treatment at which to compute dose-specific effects.
#'  If it is not specified, the default choice will be use the percentiles of the dose among
#'  all ever-treated units.
#'
#' @param degree The degree of the B-Spline used in estimation.  The default is 3, which in
#'  combination with the default choice for the `num-knots`, leads to fitting models for
#'  the group of treated units that only that is a cubic polynomial in the dose.  Setting
#'  `degree=1` will lead to a linear model, while setting `degree=2` will lead to a quadratic model.
#'
#' @param num_knots The number of knots to include for the B-Spline.  The default is 0
#'  so that the spline is global (i.e., this will amount to fitting a global polynomial).
#' There is a bias-variance tradeoff for including more or less knots.
#'
#' @return With `aggregation = "dose"`, a `ptetools::dose_obj` with the
#'  dose-specific effects `ATT(d)` and `ACRT(d)` and the overall ATT and ACRT.
#'  With `aggregation = "eventstudy"`, a `ptetools::pte_results` object with
#'  the event study (of ATT or ACRT, depending on `target_parameter`) and
#'  the overall effect. Both have `summary()` methods and can be plotted
#'  with [ggcont_did()].
#'
#' @examples
#' # build small simulated data
#' set.seed(1234)
#' df <- simulate_contdid_data(
#'   n = 1000,
#'   num_time_periods = 4,
#'   num_groups = 4,
#'   dose_linear_effect = 0,
#'   dose_quadratic_effect = 0
#' )
#'
#' # estimate effects of continuous treatment
#' cd_res <- cont_did(
#'   yname = "Y",
#'   tname = "time_period",
#'   idname = "id",
#'   dname = "D",
#'   data = df,
#'   gname = "G",
#'   target_parameter = "slope",
#'   aggregation = "dose",
#'   treatment_type = "continuous",
#'   control_group = "notyettreated",
#'   biters = 50,
#'   cband = TRUE,
#'   num_knots = 1,
#'   degree = 3,
#' )
#'
#' summary(cd_res)
#'
#' @export
cont_did <- function(yname,
                     dname,
                     gname = NULL,
                     tname,
                     idname = NULL,
                     xformula = ~1,
                     data,
                     target_parameter = c("level", "slope"),
                     aggregation = c("dose", "eventstudy", "none"),
                     treatment_type = c("continuous", "discrete"),
                     dose_est_method = c("parametric", "cck"),
                     dvals = NULL,
                     degree = 3,
                     num_knots = 0,
                     allow_unbalanced_panel = FALSE,
                     panel = TRUE,
                     control_group = c("notyettreated", "nevertreated", "eventuallytreated"),
                     anticipation = 0,
                     weightsname = NULL,
                     alp = 0.05,
                     bstrap = TRUE,
                     cband = FALSE,
                     boot_type = "multiplier",
                     biters = 1000,
                     clustervars = NULL,
                     est_method = NULL,
                     base_period = "varying",
                     print_details = FALSE,
                     cl = 1,
                     ...) {
  # check argument formatting
  assert_data_frame(data)
  assert_names(c(yname, dname, idname), subset.of = colnames(data))
  # repeated cross sections (panel = FALSE, #7): so far only the level event
  # study, which runs a binary-treatment DiD in each cell and can use
  # ptetools' repeated cross sections estimator. The dose-specific
  # estimators difference each unit's outcomes, which needs panel data.
  if (isTRUE(panel) && is.null(idname)) {
    stop("idname is required with panel data (panel = TRUE).", call. = FALSE)
  }
  if (xformula != ~1) stop("covariates not currently supported, please use xformula=~1")
  # The choice arguments' defaults list every option; resolve them to a
  # single option (the first, i.e. the default, unless one is given), as
  # match.arg() does. Without this, calling cont_did() with the defaults
  # failed the assertions below (#12).
  target_parameter <- match.arg(target_parameter)
  aggregation <- match.arg(aggregation)
  treatment_type <- match.arg(treatment_type)
  dose_est_method <- match.arg(dose_est_method)
  control_group <- match.arg(control_group)

  assert_choice(target_parameter, choices = c("level", "slope"))
  assert_choice(aggregation, choices = c("dose", "eventstudy", "none"))
  assert_choice(treatment_type, choices = c("continuous", "discrete"))
  if (aggregation == "none") stop("currently only support `dose` and `eventstudy` aggregations")
  if (allow_unbalanced_panel) stop("unbalanced panel not currently supported")
  if (!isTRUE(panel)) {
    if (!(target_parameter == "level" && aggregation == "eventstudy")) {
      stop("With repeated cross sections (panel = FALSE), only ",
           "target_parameter = \"level\" with aggregation = \"eventstudy\" ",
           "is supported so far.", call. = FALSE)
    }
    if (is.null(gname)) {
      stop("gname is required with repeated cross sections ",
           "(panel = FALSE).", call. = FALSE)
    }
  }
  assert_choice(control_group, choices = c("notyettreated", "nevertreated", "eventuallytreated"))
  # "eventuallytreated" (ptetools #29): not-yet-treated comparison units
  # other than the never treated. The cck estimator allows only one treated
  # timing group, so it has no eventually-treated comparison units.
  if (control_group == "eventuallytreated" && identical(dose_est_method, "cck")) {
    stop("control_group = \"eventuallytreated\" needs at least two treated ",
         "timing groups, which dose_est_method = \"cck\" does not support.",
         call. = FALSE)
  }
  if (anticipation != 0) warning("anticipation not tested yet, may not work")
  # sampling weights (#14): the parametric dose estimators and both event
  # studies use them; npiv has no weights
  if (!is.null(weightsname) && identical(dose_est_method, "cck")) {
    stop("weightsname is not supported with dose_est_method = \"cck\" ",
         "(npiv does not take sampling weights).", call. = FALSE)
  }
  assert_numeric(alp)
  if (!is.null(est_method)) stop("covariates not supported yet, set est_method=NULL")
  assert_choice(base_period, choices = c("varying", "universal"))
  assert_choice(dose_est_method, choices = c("parametric", "cck"))
  # clustervars is passed on to ptetools, which clusters analytical and
  # bootstrap standard errors (ptetools #6); the cck estimator does its own
  # inference with npiv, which does not support clustering
  # No untreated units (no gname = 0): ATT(d) and other level parameters need
  # untreated comparison units, but the ACRT is identified from variation in
  # the dose within each timing group (it only involves derivatives of the
  # dose-response curve). For target_parameter = "slope", estimate it with
  # no comparison units: cells hold each cohort's own units
  # (cont_two_by_two_subset()), and ptetools' setup is told not to require
  # comparison units. Level parameters are then reported as NA (#5).
  no_untreated <- !any(data[[gname]] == 0, na.rm = TRUE)
  require_comparison <- TRUE
  if (no_untreated && target_parameter == "slope") {
    message("No untreated units: the ACRT is estimated from variation in the ",
            "dose within each timing group. ATT(d) and the overall ATT are ",
            "not identified and are reported as NA.")
    require_comparison <- FALSE
  }
  if (no_untreated && target_parameter == "level" &&
        length(unique(data[[gname]])) == 1) {
    stop("Every unit is treated at the same time and none is untreated, so ",
         "ATT(d) and other level parameters are not identified. The ACRT is: ",
         "use target_parameter = \"slope\".", call. = FALSE)
  }

  if (!is.null(clustervars) && identical(dose_est_method, "cck")) {
    stop("clustervars is not supported with dose_est_method = \"cck\".",
         call. = FALSE)
  }

  # TODO: checks that dose is constant over time and that treatment is staggered
  # check for balanced panel data

  if (treatment_type == "discrete") {
    stop("discrete treatment not supported yet")
  }

  if (treatment_type == "continuous" && aggregation == "dose" && target_parameter == "slope") {
    attgt_fun <- cont_did_acrt
    gt_type <- "dose"
  }

  if (treatment_type == "continuous" && aggregation == "dose" && target_parameter == "level") {
    attgt_fun <- cont_did_acrt # it will compute both att and acrt
    gt_type <- "dose"
  }

  if (treatment_type == "continuous" && aggregation == "eventstudy" && target_parameter == "slope") {
    attgt_fun <- cont_did_acrt
    gt_type <- "att"
  }

  if (treatment_type == "continuous" && aggregation == "eventstudy" && target_parameter == "level") {
    attgt_fun <- if (isTRUE(panel)) {
      cont_did_att_level
    } else {
      cont_did_att_level_rcs
    }
    gt_type <- "att"
  }

  # set up the timing group variable
  if (is.null(gname)) {
    data$.G <- BMisc::get_group(data, idname = idname, tname = tname, treatname = dname)
    gname <- ".G"
  }

  # cck estimator not supported with staggered adoption yet
  if (dose_est_method == "cck") {
    # one treated timing group (plus, possibly, untreated units)
    if (length(setdiff(unique(data[[gname]]), 0)) != 1) {
      stop("cck estimator not supported with staggered adoption yet")
    }

    if (length(unique(data[[tname]])) != 2) {
      stop("cck estimator not supported with more than two time periods. consider averaging across pre and post treatment periods")
    }

    if (aggregation != "dose") {
      stop("event study not supported with cck estimator yet")
    }

    data <- BMisc::make_balanced_panel(data, idname, tname)
    data$.dy <- BMisc::get_first_difference(data, idname, yname, tname)
    maxT <- max(data[[tname]])
    post_data <- subset(data, data[[tname]] == maxT)
    dose <- post_data[[dname]]
    dy <- post_data$.dy
    # center by the untreated units' mean change; with no untreated units
    # (#5) only the ACRT is identified, and centering does not affect it
    m0 <- if (no_untreated) 0 else mean(dy[dose == 0])
    dy_centered <- dy - m0
    if (is.null(dvals)) {
      # choose dvals the same way as npiv::npiv
      # see line 733 https://github.com/JeffreyRacine/npiv/blob/main/R/npiv.R
      dvals <- seq(min(dose[dose > 0]),
        max(dose[dose > 0]),
        length.out = 50
      )
    }

    # just going to run code here
    cck_res <- npiv::npiv(
      Y = dy_centered[dose > 0],
      X = dose[dose > 0],
      W = dose[dose > 0],
      X.grid = dvals,
      knots = "quantile",
      boot.num = 999,
      J.x.degree = 3,
      K.w.degree = 3
    )

    att.d <- cck_res$h
    att.d_se <- cck_res$asy.se
    # back out implied uniform cband critical value from reported upper bound
    att.d_crit.val <- as.numeric((cck_res$h.upper - att.d) / att.d_se)[1]


    acrt.d <- cck_res$deriv
    acrt.d_se <- cck_res$deriv.asy.se
    # back out implied uniform cband critical value from reported upper bound
    acrt.d_crit.val <- as.numeric((cck_res$h.upper.deriv - acrt.d) / acrt.d_se)[1]

    if (!cband) {
      att.d_crit.val <- qnorm(1 - alp / 2)
      acrt.d_crit.val <- qnorm(1 - alp / 2)
    }
    if (no_untreated) {
      # ATT(d) needs untreated comparison units (#5)
      att.d <- rep(NA_real_, length(att.d))
      att.d_se <- rep(NA_real_, length(att.d))
      att.d_crit.val <- NA_real_
    }

    # Compute average ACR
    average_acr <- mean(cck_res$deriv)

    # Get splines for dosage
    spline_dosage <- npiv::gsl.bs(cck_res$W[, drop = FALSE],
      degree = cck_res$K.w.degree,
      nbreak = (cck_res$K.w.segments + 1),
      knots = as.numeric(quantile(cck_res$W[, drop = FALSE],
        probs = seq(0, 1, length = (cck_res$K.w.segments + 1))
      )),
      deriv = 0,
      intercept = TRUE
    )
    # Sample size
    n_treated <- length(cck_res$Y)
    # compute influence function of spline beta
    infl_reg <- as.numeric(cck_res$Y - cck_res$h) *
      spline_dosage %*% (MASS::ginv(t(spline_dosage) %*% spline_dosage / n_treated))

    # Now, compute the average of the spline derivatives
    average_spline_deriv <- colMeans(npiv::gsl.bs(cck_res$W[, drop = FALSE],
      degree = cck_res$K.w.degree,
      nbreak = (cck_res$K.w.segments + 1),
      knots = as.numeric(quantile(cck_res$W[, drop = FALSE], probs = seq(0, 1, length = (cck_res$K.w.segments + 1)))),
      deriv = 1,
      intercept = TRUE
    ))
    # Now, put all terms together to get the influence function of the average ACR
    infl_avg_acr <- (cck_res$deriv - mean(cck_res$deriv)) + infl_reg %*% average_spline_deriv

    # Compute stanrd error
    se_avg_acr <- sd(infl_avg_acr) / sqrt(n_treated)

    ptep <- setup_pte_cont(
      yname = yname,
      gname = gname,
      tname = tname,
      dname = dname,
      idname = idname,
      data = data,
      target_parameter = target_parameter,
      aggregation = aggregation,
      treatment_type = treatment_type,
      dose_est_method = dose_est_method,
      cband = cband,
      alp = alp,
      boot_type = boot_type,
      gt_type = gt_type,
      weightsname = weightsname,
      control_group = control_group,
      require_comparison = require_comparison,
      biters = biters,
      cl = cl,
      call = call,
      ...
    )

    overall_att_res <- if (no_untreated) NULL else suppressWarnings(
      ptetools::pte_default(
        yname = ptep$yname,
        gname = ptep$gname,
        tname = ptep$tname,
        idname = ptep$idname,
        data = ptep$data,
        d_outcome = TRUE,
        anticipation = ptep$anticipation,
        base_period = ptep$base_period,
        control_group = ptep$control_group,
        weightsname = ptep$weightsname,
        biters = ptep$biters,
        alp = ptep$alp
      )
    )

    dose_order <- order(dose[dose > 0])
    dose_out <- dose[dose > 0][dose_order]
    att.d <- att.d[dose_order]
    att.d_se <- att.d_se[dose_order]
    acrt.d <- acrt.d[dose_order]
    acrt.d_se <- acrt.d_se[dose_order]

    out <- dose_obj(
      dose = dose_out,
      overall_att = if (no_untreated) NA_real_ else
        overall_att_res$overall_att$overall.att,
      overall_att_se = if (no_untreated) NA_real_ else
        overall_att_res$overall_att$overall.se,
      overall_att_inffunc = if (no_untreated) NULL else
        overall_att_res$overall_att$inf.func[[1]],
      overall_acrt = average_acr,
      overall_acrt_se = se_avg_acr,
      overall_acrt_inffunc = infl_avg_acr,
      att.d = att.d,
      att.d_se = att.d_se,
      att.d_crit.val = att.d_crit.val,
      att.d_inffunc = NULL,
      acrt.d = acrt.d,
      acrt.d_se = acrt.d_se,
      acrt.d_crit.val = acrt.d_crit.val,
      acrt.d_inffunc = NULL,
      pte_params = ptep
    )

    return(out)
  }

  res <- pte(
    yname = yname,
    gname = gname,
    tname = tname,
    idname = idname,
    data = data,
    setup_pte_fun = setup_pte_cont,
    subset_fun = if (isTRUE(panel)) cont_two_by_two_subset else cont_rcs_subset,
    panel = panel,
    attgt_fun = attgt_fun,
    xformla = xformula,
    target_parameter = target_parameter,
    aggregation = aggregation,
    treatment_type = treatment_type,
    dose_est_method = dose_est_method,
    anticipation = anticipation,
    # previously not passed on, so ptetools' defaults (not-yet-treated
    # comparison group, varying base period) were always used (#19)
    control_group = control_group,
    base_period = base_period,
    clustervars = clustervars,
    # previously not passed on, so weights had no effect (#14)
    weightsname = weightsname,
    require_comparison = require_comparison,
    bstrap = bstrap,
    gt_type = gt_type,
    cband = cband,
    alp = alp,
    boot_type = boot_type,
    biters = biters,
    cl = cl,
    dname = dname,
    degree = degree,
    num_knots = num_knots,
    dvals = dvals
  )

  res
}

# --- ATT for a Timing Group and Time Period --------------------------------
#
# Internal attgt function used for the level event study. Wraps
# ptetools::did_attgt, which passes `D` to DRDID::drdid_panel as the treatment
# indicator. Within a (g,t) subset, cont_two_by_two_subset() sets D to the
# dose for units in group g and 0 otherwise, so D > 0 identifies the treated
# group. Passing the dose itself would make DRDID weight treated units by
# their dose and put weight (1 - D) of treated units on the comparison side;
# DRDID >= 1.4.0 rejects non-binary D outright.
#
# Arguments:
#   gt_data - gt_data_frame for this (g,t), with D equal to the dose
#   ...     - passed on to ptetools::did_attgt
#
# Returns: ptetools::attgt_if object for the binarized-treatment ATT(g,t)
cont_did_att_level <- function(gt_data, ...) {
  gt_data$D <- as.numeric(gt_data$D > 0)
  ptetools::did_attgt(gt_data, ...)
}

# Level ATT(g,t) with repeated cross sections (#7): the same binary
# treated/comparison indicator as cont_did_att_level(), with ptetools'
# repeated cross sections DiD estimator.
#
# Arguments:
#   gt_data - gt_data_frame for this (g,t), with D equal to the dose
#   ...     - passed on to ptetools::did_rcs_attgt
#
# Returns: ptetools::attgt_if object for the binarized-treatment ATT(g,t)
cont_did_att_level_rcs <- function(gt_data, ...) {
  gt_data$D <- as.numeric(gt_data$D > 0)
  ptetools::did_rcs_attgt(gt_data, ...)
}

# Group-time cell for repeated cross sections (#7): ptetools' repeated
# cross sections 2x2 cell, with the local treatment D equal to the dose for
# group g's observations and 0 for comparison observations (as in
# cont_two_by_two_subset()).
cont_rcs_subset <- function(data, g, tp, control_group = "notyettreated",
                            anticipation = 0, base_period = "varying", ...) {
  cell <- ptetools::two_by_two_rcs_subset(
    data, g, tp,
    control_group = control_group, anticipation = anticipation,
    base_period = base_period, ...
  )
  cell$gt_data$D <- cell$gt_data$.D * (cell$gt_data$.G == g)
  cell
}

#' @title Compute ACRT's for a Timing Group and Time Period
#'
#' @description This is the main function for computing dose-specific
#'  effects of a continuous treatment, given a particular timing group
#'  and time period.
#'
#' @inheritParams ptetools::pte_attgt
#' @inheritParams cont_did
#' @param knots A vector of placements of knots for b-splines.  Since this function
#'  is typically called internally, this would typically be set by the calling
#'  function.
#' @param ... additional arguments
#'
#' @return ptetools::attgt_if object
#' @export
cont_did_acrt <- function(
    gt_data,
    dvals = NULL,
    degree = 1,
    knots = numeric(0),
    ...) {
  # outcome change from the base ("pre") period to the current ("post")
  # period, matched by unit. With a universal base period the base period
  # can come after the current one in pre-treatment cells, so differencing
  # by period order (BMisc::get_first_difference()) gave NA there (#19).
  post_data <- gt_data[gt_data$name == "post", , drop = FALSE]
  pre_data <- gt_data[gt_data$name == "pre", , drop = FALSE]
  dose <- post_data$D
  dy <- post_data$Y - pre_data$Y[match(post_data$id, pre_data$id)]

  # sampling weights (#14), one per unit (all 1 without weightsname)
  w <- post_data$.w
  if (is.null(w)) w <- rep(1, length(dose))
  treated <- dose > 0
  # Treated units with zero weight drop out of the dose regression. Their
  # influence-function entries are 0, and ptetools::process_dose_gt() finds
  # each cell's treated units as the nonzero entries, so they must not be
  # rows of the regression's estfun() either.
  in_reg <- treated & w > 0
  # weights normalized to mean 1 over the cell's treated units, so weighted
  # averages over them are mean(w_t * x)
  w_t <- w[treated] / mean(w[treated])

  dose_est_method <- list(...)$dose_est_method
  if (dose_est_method == "cck") {
    stop("cck estimator not supported with staggered adoption yet")
  }

  # if they were previously saved in shared_env, recover calculated knots
  boundary_knots <- range(dose[dose > 0])
  if (!is.null(shared_env$knots)) {
    knots <- shared_env$knots
    dvals <- shared_env$dvals
    boundary_knots <- shared_env$boundary_knots
  }

  # evaluate every basis with the same boundary knots; otherwise bSpline() and
  # dbs() take them from the range of the points they are evaluated at
  bs <- splines2::bSpline(dose[in_reg], degree = degree, knots = knots, Boundary.knots = boundary_knots) |>
    as.data.frame()
  colnames(bs) <- paste0("bs_", colnames(bs))
  bs$dy <- dy[in_reg]

  # The dose regression needs more treated units than parameters (intercept
  # plus spline terms). With as many units as parameters it fits them
  # exactly (zero residuals, so a degenerate influence function); with
  # fewer it is not identified. Either way, stop with a message that says
  # what is wrong (ptetools #17).
  n_treated <- nrow(bs)
  n_params <- ncol(bs)  # spline terms + intercept (bs also holds dy)
  # (ptetools adds which group and period this is to the error message)
  if (n_treated <= n_params) {
    stop("the dose regression has ", n_treated, " treated unit(s) but ",
         n_params, " parameters (degree = ", degree, ", ", length(knots),
         " interior knot(s), plus an intercept); it needs more treated ",
         "units than parameters. Use a smaller degree or fewer knots, or ",
         "drop this group.", call. = FALSE)
  }

  # weighted least squares; the weights enter sandwich::estfun() and
  # sandwich::bread() below, so the influence function is the weighted one
  reg_w <- w[in_reg]
  bs_reg <- lm(dy ~ ., data = bs, weights = reg_w)

  # dose_grid <- quantile(dose[dose > 0], probs = seq(0, 1, length.out = 100))
  bs_grid <- splines2::bSpline(dvals, degree = degree, knots = knots, Boundary.knots = boundary_knots) |>
    as.data.frame()
  colnames(bs_grid) <- colnames(model.matrix(bs_reg))[-1]

  # mean outcome change of the untreated comparison units; there are none
  # when there are no untreated units (#5), and then ATT(d) is
  # not identified (the ACRT below does not use them)
  untreated_mean <- if (any(dose == 0)) {
    stats::weighted.mean(dy[dose == 0], w[dose == 0])
  } else {
    NA_real_
  }
  att.d <- predict(bs_reg, newdata = bs_grid) - untreated_mean

  # Compute derivative of B-spline basis
  bs_deriv <- splines2::dbs(dvals, degree = degree, knots = knots, Boundary.knots = boundary_knots)

  # Compute derivative of E[Y|D]
  bs_reg_coef <- coef(bs_reg) # Coefficients from regression model
  acrt.d <- bs_deriv %*% bs_reg_coef[-1, drop = FALSE] # Exclude intercept term
  acrt.d <- as.numeric(acrt.d)

  # previous results just plug in different values of D
  # here average across the distribution of the dose to
  # get average treatment effect parameters
  bs_grid2 <- splines2::bSpline(dose[dose > 0], degree = degree, knots = knots, Boundary.knots = boundary_knots) |>
    as.data.frame()
  colnames(bs_grid2) <- colnames(model.matrix(bs_reg))[-1]
  # (weighted averages over the cell's treated units)
  att.overall <- mean(w_t * predict(bs_reg, newdata = bs_grid2)) -
    untreated_mean
  bs_deriv2 <- splines2::dbs(dose[dose > 0], degree = degree, knots = knots, Boundary.knots = boundary_knots)
  acrt_i <- as.numeric(bs_deriv2 %*% bs_reg_coef[-1, drop = FALSE])
  acrt.overall <- mean(w_t * acrt_i)

  # capture components of influence function
  # for inference later
  Xe <- sandwich::estfun(bs_reg)
  bread <- sandwich::bread(bs_reg)
  # confirmed that this is the same as following
  # Xe <- sandwich::estfun(bs_reg)
  # n <- nrow(Xe)
  # M <- t(Xe) %*% Xe / n
  # X <- cbind(1, as.matrix(bs[, -ncol(bs)]))
  # B <- solve(t(X) %*% X / n)
  # Bread <- sandwich::bread(bs_reg) # note B==Bread
  # Meat <- sandwich::meat(bs_reg)
  # sandwich::vcovHC(bs_reg, type = "HC0")
  # sqrt(diag(solve(t(X) %*% X) %*% M %*% solve(t(X) %*% X))) / sqrt(n)
  # Bread %*% Meat %*% Bread
  # B %*% M %*% B

  # return influence function for ACRT^o, but also return components
  # to compute uniform confidence bands for ATT(d) and ACRT(d)
  # to be used outside this function

  # Both components are on the scale of the n1 treated units.
  # First component: from "knowing" the regression coefficients, the
  # influence function of the weighted mean of acrt_i over treated units
  inffunc1 <- w_t * (acrt_i - acrt.overall)

  # Second component: from having estimated the regression coefficients.
  # With zero-weight treated units left out of the regression (n1r < n1
  # rows), Xe %*% bread is on the n1r scale; n1 / n1r puts it on the n1
  # scale, and the zero-weight units' entries stay 0.
  n1 <- sum(treated)
  n1r <- sum(in_reg)
  inffunc2 <- rep(0, n1)
  # augment with 0 for the intercept
  inffunc2[w[treated] > 0] <- (n1 / n1r) *
    as.numeric(Xe %*% bread %*% as.matrix(c(0, colMeans(w_t * bs_deriv2))))

  # untreated units don't contribute to the influence function for the
  # ACRT; rescale from the n1 treated units to all n units in the cell (as
  # for ATT(d) in ptetools::process_dose_gt)
  inffunc <- rep(0, nrow(post_data))
  inffunc[treated] <- (length(dose) / n1) * (inffunc1 + inffunc2)

  # some hack code to get influence function right
  # in aggregations into effects at different doses
  # just keep track of which unit are in the treated group
  # and comparison group for this g-t.  Set inffunc=1
  # for treated units and inffunc=Inf for comparison units.
  # args <- list(...)
  # if ("inffunc_track_treated_and_comparison" %in% names(args)) {
  #   if (args$inffunc_track_treated_and_comparison) {
  #     inffunc <- rep(Inf, nrow(post_data))
  #     inffunc[dose > 0] <- 1
  #   }
  # }

  attgt_if(
    attgt = acrt.overall,
    inf_func = inffunc,
    extra_gt_returns = list(
      att.d = att.d,
      acrt.d = acrt.d,
      att.overall = att.overall,
      acrt.overall = acrt.overall,
      bet = bs_reg_coef,
      bread = bread,
      Xe = Xe
    )
  )
}

#' @title Continuous Two-by-Two Subset
#'
#' @description A function for computing a 2x2 subset of original data with
#'  a continuous treatment. The cell is the same as in
#'  `ptetools::two_by_two_subset()` (base period, comparison group, and
#'  anticipation as in `did::att_gt()`); the local treatment variable `D` is
#'  the dose for units in group `g` and 0 for comparison units.
#'
#' @param data the full dataset
#' @param g the current group
#' @param tp the current time period
#' @inheritParams ptetools::two_by_two_subset
#' @param control_group whether to use "notyettreated" (default),
#'  "nevertreated" or "eventuallytreated"
#' @param require_comparison if \code{FALSE} (used by \code{cont_did()}
#'  when no unit is untreated), the cell holds only group \code{g}'s own
#'  units, which is enough for the ACRT
#' @param ... extra arguments to get the subset correct
#'
#' @return list that contains correct subset of data, \code{n1}
#'  number of observations
#'  in this subset, and \code{disidx} a vector of the correct ids for this
#'  subset.
#'
#' @export
cont_two_by_two_subset <- function(data,
                                   g,
                                   tp,
                                   control_group = "notyettreated",
                                   anticipation = 0,
                                   base_period = "varying",
                                   require_comparison = TRUE,
                                   ...) {
  if (!isTRUE(require_comparison)) {
    # no untreated units (#5): the cell holds only cohort g's own units in
    # the base and current periods, enough for the ACRT, which uses only
    # variation in the dose within the cohort
    base <- ptetools::pte_base_period(data, g, tp, anticipation, base_period)
    rows <- which(data$.G == g & data$.period %in% c(base, tp))
    gt_data <- data[rows, , drop = FALSE]
    gt_data$name <- ifelse(gt_data$.period == tp, "post", "pre")
    gt_data$D <- gt_data$.D
    gt_data <- ptetools::gt_data_frame(gt_data)
    all_ids <- unique(data$.id)
    return(list(gt_data = gt_data, n1 = length(unique(gt_data$.id)),
                disidx = all_ids %in% unique(gt_data$.id)))
  }

  # the cell itself (which units and periods) is ptetools' 2x2 cell, so the
  # base period, comparison group and anticipation follow did::att_gt()
  cell <- ptetools::two_by_two_subset(
    data, g, tp,
    control_group = control_group, anticipation = anticipation,
    base_period = base_period, ...
  )

  # local treatment: the dose (stored by setup_pte_cont() as .D) for units in
  # group g, 0 for comparison units
  cell$gt_data$D <- cell$gt_data$.D * (cell$gt_data$.G == g)
  cell
}
