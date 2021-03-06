
##' set axis limits (x or y) of a `ggplot` object (left hand side of `+`)
##' based on the x (`xlim2`) or y (`ylim2`) limits of another `ggplot` object (right hand side of `+`).
##' This is useful for using `cowplot` or `patchwork` to align `ggplot` objects.
##'
##'
##' @title xlim2
##' @rdname align_axis
##' @param gg ggplot object
##' @param limits vector of limits. If NULL, determine from `gg`. 
##' @return ggplot2 object with new limits
##' @export
##' @examples 
##' library(ggplot2)
##' library(aplot)
##' p1 <- ggplot(mtcars, aes(cyl)) + geom_bar()
##' p2 <- ggplot(subset(mtcars, cyl != 4), aes(cyl)) + geom_bar()
##' p2 + xlim2(p1)
##' @author Guangchuang Yu
xlim2 <- function(gg, limits = NULL) {
    axis_align(gg = gg, limits = limits, axis = 'x')
}

##' @rdname align_axis
##' @title ylim2
##' @export
ylim2 <- function(gg, limits = NULL) {
    axis_align(gg = gg, limits = limits, axis = 'y')
}

axis_align <- function(gg, limits = NULL, axis) {
    if (is.null(limits)) {
        if (axis == "x") {
            limits <- xrange(gg)
        } else {
            limits <- yrange(gg)
        }
    }
    structure(list(limits = limits, axis = axis),
              class = "axisAlign")
}


##' extract x or y ranges of a ggplot
##'
##' 
##' @title plot range of a ggplot object
##' @rdname ggrange
##' @param gg a ggplot object
##' @return range of selected axis
##' @export
##' @author Guangchuang Yu
yrange <- function(gg) {
    ggrange(gg, "y")
}

##' @rdname ggrange
##' @export
xrange <- function(gg) {
    ggrange(gg, "x")
}

##' @importFrom ggplot2 layer_scales
##' @importFrom ggplot2 ggplot_build
ggrange <- function(gg, var) {
    ## https://github.com/YuLab-SMU/aplot/pull/3
    ## res <- layer_scales(gg)[[var]]$range$range 
    res <- layer_scales(gg)[[var]]$limits
    if (is.null(res)) {
        res <- layer_scales(gg)[[var]]$range$range 
    }
    if (is.character(res)) return(res)

    var <- paste0(var, ".range")
    ggplot_build(gg)$layout$panel_params[[1]][[var]]
}

##' @method ggplot_add axisAlign
##' @importFrom ggplot2 ggplot_add
##' @importFrom ggplot2 scale_x_discrete
##' @importFrom ggplot2 scale_y_discrete
##' @importFrom ggplot2 scale_x_continuous
##' @importFrom ggplot2 scale_y_continuous
##' @importFrom methods is
##' @export
ggplot_add.axisAlign <- function(object, plot, object_name) {
    limits <- object$limits

    ## expand_limits <- object$expand_limits
    ## limits[1] <- limits[1] + (limits[1] * expand_limits[1]) - expand_limits[2]
    ## limits[2] <- limits[2] + (limits[2] * expand_limits[3]) + expand_limits[4]

    if (is.numeric(limits)) {
        lim_x <- scale_x_continuous(limits=limits, expand=c(0,0))
        lim_y <- scale_y_continuous(limits = limits, expand = c(0, 0))
    } else {
        lim_x <- scale_x_discrete(limits=limits, expand = c(0, 0.6))
        lim_y <- scale_y_discrete(limits = limits, expand = c(0, 0.6))
    }

    if (object$axis == 'x') {
        ## if (object$by == "x") {
        if (is(plot$coordinates, "CoordFlip")) {
            message("the plot was flipped and the x limits will be applied to y-axis")
            scale_lim <- lim_y
        } else {
            scale_lim <- lim_x
        }
        ## } else {
        ##     if (is(plot$coordinates, "CoordFlip")) {
        ##         message("the plot was flipped and the x limits will be applied to x-axis")
        ##         scale_lim <- scale_x_continuous(limits=limits, expand=c(0,0))
        ##     } else {
        ##         scale_lim <- scale_y_continuous(limits=limits, expand=c(0,0))
        ##     }
        ## }
    } else { ## axis == 'y'
        ## if (object$by == "x") {
        ##     if (is(plot$coordinates, "CoordFlip")) {
        ##         message("the plot was flipped and the y limits will be applied to y-axis")
        ##         scale_lim <- scale_y_continuous(limits = limits, expand = c(0, 0))
        ##     } else {
        ##         scale_lim <- scale_x_continuous(limits = limits, expand = c(0, 0))
        ##     }
        ## } else {
        if (is(plot$coordinates, "CoordFlip")) {
            message("the plot was flipped and the y limits will be applied to x-axis")
            scale_lim <- lim_x
        } else {
            scale_lim <- lim_y
        }
        ## }
    }
    ggplot_add(scale_lim, plot, object_name)
}
