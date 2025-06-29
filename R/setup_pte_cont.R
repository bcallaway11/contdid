#' @title Setup for DiD with a Continuous Treatment
#'
#' @description A function that creates a pte_params object, adding
#'  several different variables that are needed when there is a
#'  continuous treatment.
#'
#' @inheritParams ptetools::setup_pte
#' @inheritParams cont_did
#'
#' @param dvals an optional argument specifying which values of the
#'  treatment to evaluate ATT(d) and/or ACRT(d).  If no values are
#'  supplied, then the default behavior is to set
#'  `dvals` to be the 1st to 99th percentiles of the dose among
#'  units that experience any positive dose.
#'
#' @return \code{pte_params} object
#'
#' @export
setup_pte_cont <- function(yname,
                           gname,
                           tname,
                           idname,
                           data,
                           xformula = ~1,
                           target_parameter,
                           aggregation,
                           treatment_type,
                           required_pre_periods = 1,
                           anticipation = 0,
                           base_period = "varying",
                           cband = TRUE,
                           alp = 0.05,
                           boot_type = "multiplier",
                           weightsname = NULL,
                           gt_type = "att",
                           biters = 100,
                           cl = 1,
                           dname,
                           dvals = NULL,
                           degree = 1,
                           num_knots = 0,
                           ...) {

    data$D <- data[[dname]]

    # make the same call to ptetools::setup_pte as usual
    # we will add some things to this
    ptep <- ptetools::setup_pte(
        yname = yname,
        gname = gname,
        tname = tname,
        idname = idname,
        data = data,
        xformula = xformula,
        cband = cband,
        alp = alp,
        boot_type = boot_type,
        gt_type = gt_type,
        weightsname = weightsname,
        biters = biters,
        cl = cl,
        ...
    )

    first_period <- min(data[[tname]])
    first_period_data <- data[data[[tname]] == first_period, ]
    dose <- first_period_data[[dname]]

    # data sanity checks
    #------------------------
    # drop units that have a treatment timing but no dose
    timing_no_dose <- data[[gname]] != 0 & data[[dname]] == 0
    if (any(timing_no_dose)) {
        data <- data[!timing_no_dose, ]
        warning(paste0(
            "Dropped ", sum(timing_no_dose),
            " units that have a treatment timing but no dose."
        ))
    }
    # set dose equal to 0 for never treated units
    dose_but_untreated <- data[[gname]] == 0 & data[[dname]] != 0
    if (any(dose_but_untreated)) {
        data[[dname]][dose_but_untreated] <- 0
        warning(paste0(
            "Set dose equal to 0 for ", sum(dose_but_untreated),
            " units that have a dose but were in the never treated group."
        ))
    }

    knots <- choose_knots_quantile(dose[dose > 0], num_knots)
    if (is.null(dvals)) {
        dvals <- quantile(dose[dose > 0], probs = seq(.1, .99, .01))
    }

    ptep$dname <- dname
    ptep$degree <- degree
    ptep$num_knots <- num_knots
    ptep$knots <- knots
    ptep$dvals <- dvals

    ptep$target_parameter <- target_parameter
    ptep$aggregation <- aggregation
    ptep$treatment_type <- treatment_type

    shared_env$knots <- knots
    shared_env$dvals <- dvals

    ptep
}
