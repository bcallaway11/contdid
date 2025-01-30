#' @title ggcont_did
#'
#' @param dose_obj a result from running `cont_did`
#' @param type whether to plot ATT(d) or ACRT(d), defaults to `att` for
#'  plotting ATT(d).  For ACRT(d), use "acrt"
#' @description a function to plot results with a continuous treatment
ggcont_did <- function(dose_obj, type = "att") {
    # just call native plotting from `ptetools` package, no adjustments needed
    if (inherits(dose_obj, "pte_results")) {
        # in this case plot the event study
        p <- ggpte(dose_obj)
        # change label if we are estimating a slope
        if (dose_obj$ptep$target_parameter == "slope") {
            p <- p + ylab("acrt")
        }
        p
    } else {
        # in this case, plot effects across doses
        ggpte_cont(dose_obj, type)
    }
}
