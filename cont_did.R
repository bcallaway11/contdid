
#' @title cont_did
#' 
#' @description A function for difference-in-differences with a continuous treatment in a 
#'  staggered treatment adoption setting.  
#' 
#'  `cont_did` currently supports staggered treatment with continuous treatments using the 
#'  `np` package (=> kernel regression) under the hood.
#' 
#' @inheritParams did::att_gt
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
#' @return cont_did_obj
#' @export
cont_did <- function(yname,
                    tname,
                    gname,
                    idname,
                    xformula=~1,
                    data,
                    target_parameter=c("level", "slope"),
                    aggregation=c("dose", "eventstudy", "none"),
                    allow_unbalanced_panel=FALSE,
                    control_group=c("notyettreated","nevertreated","eventuallytreated"),
                    anticipation=0,
                    weightsname=NULL,
                    alp=0.05,
                    bstrap=FALSE,
                    cband=FALSE,
                    biters=1000,
                    clustervars=NULL,
                    est_method=NULL,
                    base_period="varying",
                    print_details=FALSE,
                    pl=FALSE,
                    cores=1,
                    ...) {


    # check argument formatting                        
    assert_data_frame(data)
    assert_names(c(yname, gname, idname), subset.of = colnames(data))
    if (xformula != ~1) stop("covariates not currently supported, please use xformula=~1")
    assert_choice(target_parameter, choices=c("level", "derivative"))
    assert_choice(aggregation, choices=c("dose", "eventstudy", "none"))
    if (aggregation=="none") stop("currently only support `dose` and `eventstudy` aggregations")
    if (allow_unbalanced_panel) stop("unbalanced panel not currently supported")
    assert_choice(control_group, choices=c("notyettreated","nevertreated","eventuallytreated")
    if (anticipation != 0) warning("anticipation not tested yet, may not work")
    if (!is.null(weightsname)) warning("sampling weights not tested yet, may not work")
    assert_numeric(alp)
    if (!isFALSE(bstrap)) stop("bootstrap not currently supported")
    if (!isFALSE(cband)) stop("uniform confidence band not currently supported")
    if (!is.null(clustervars)) warning("clustered standard errors not tested yet, may not work")
    if (!is.null(est_method)) stop("covariates not supported yet, set est_method=NULL")
    assert_choice(base_period, choices=c("varying","universal"))
    if (!is.FALSE(pl)) stop("parallel processing not supported yet, set pl=FALSE")

    res <- pte2(yname=yname,
             gname=gname,
             tname=tname,
             idname=idname,
             data=data,
             setup_pte_fun=setup_pte,
             subset_fun=two_by_two_subset,
             attgt_fun=cic_attgt,
             xformla=xformla,
             anticipation=anticipation,
             cband=cband,
             alp=alp,
             boot_type=boot_type,
             biters=biters,
             cl=cl,
             ret_quantile=ret_quantile,
             gt_type=gt_type)

  res
}
