#' @title setup_pte_cont
#'
#' @description A function that creates a pte_params object, adding
#'  several different variables that are needed when there is a
#'  continuous treatment.
#'
#' @inheritParams ptetools::pte_params
#'
#' #' @return \code{pte_params} object
#'
#' @export
setup_pte_cont <- function(yname,
                           gname,
                           tname,
                           idname,
                           data,
                           required_pre_periods = 1,
                           anticipation = 0,
                           base_period = "varying",
                           cband = TRUE,
                           alp = 0.05,
                           boot_type = "multiplier",
                           weightsname = NULL,
                           gt_type = "att",
                           ret_quantile = 0.5,
                           biters = 100,
                           cl = 1,
                           dname,
                           degree = 1,
                           num_knots = 0,
                           ...) {
    # make the same call to ptetools::setup_pte as usual
    # we will add some things to this
    ptep <- ptetools::setup_pte(
        yname = yname,
        gname = gname,
        tname = tname,
        idname = idname,
        data = data,
        cband = cband,
        alp = alp,
        boot_type = boot_type,
        gt_type = gt_type,
        weightsname = weightsname,
        ret_quantile = ret_quantile,
        global_fun = global_fun,
        time_period_fun = time_period_fun,
        group_fun = group_fun,
        biters = biters,
        cl = cl,
        ...
    )

    # dname <- list(...)$dname
    # degree <- list(...)$degree
    # num_knots <- list(...)$num_knots

    first_period <- min(data[[tname]])
    first_period_data <- data[data[[tname]] == first_period, ]
    dose <- first_period_data[[dname]]

    knots <- choose_knots_quantile(dose[dose > 0], num_knots)

    ptep$dname <- dname
    ptep$degree <- degree
    ptep$num_knots <- num_knots
    ptep$knots <- knots

    shared_env$knots <- knots

    ptep
}
