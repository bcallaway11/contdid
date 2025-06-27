#' @title Plot Results with a Continuous Treatment
#'
#' @description a function to plot results with a continuous treatment
#'
#' @param dose_obj a result from running `cont_did`
#' @param type whether to plot ATT(d) or ACRT(d), defaults to `att` for
#'  plotting ATT(d).  For ACRT(d), use "acrt"
#'
#' @examples
#' # build small simulated data
#' set.seed(1234)
#' df <- simulate_contdid_data(
#'     n = 5000,
#'     num_time_periods = 4,
#'     num_groups = 4,
#'     dose_linear_effect = 0,
#'     dose_quadratic_effect = 0
#' )
#'
#' # estimate effects of continuous treatment
#' cd_res <- cont_did(
#'     yname = "Y",
#'     tname = "time_period",
#'     idname = "id",
#'     dname = "D",
#'     data = df,
#'     gname = "G",
#'     target_parameter = "slope",
#'     aggregation = "dose",
#'     treatment_type = "continuous",
#'     control_group = "notyettreated",
#'     biters = 50,
#'     cband = TRUE,
#'     num_knots = 1,
#'     degree = 3,
#' )
#'
#' # plot ATT as a function of the dose
#' ggcont_did(cd_res, type = "att")
#'
#' # plot ACRT as a function of the dose
#' ggcont_did(cd_res, type = "acrt")
#'
#' @return A ggplot object
#'
#' @export
ggcont_did <- function(dose_obj, type = "att") {
    # just call native plotting from `ptetools` package, no adjustments needed
    if (inherits(dose_obj, "pte_results")) {
        # in this case plot the event study
        p <- ggpte(dose_obj)
        # change label if we are estimating a slope
        if (dose_obj$ptep$target_parameter == "slope") {
            p <- p + ggplot2::ylab("acrt")
        }
        p
    } else {
        # in this case, plot effects across doses
        ggpte_cont(dose_obj, type)
    }
}
