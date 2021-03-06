#' Plot of changes in average performances in time for one or two countries.
#'
#' @param csubject Character of the from "MATH"/"READ"/"SCIE".
#' @param cnts Country codes of countries to compare on a rainbow plot.
#' @param disp Logical vector - first element indicates, if standard errors are to be displayed,
#'        second argument indicates, if trend lines are to be displayed.
#' @param isco_cats ISCO categories to plot - as a character - numbers of categories.
#'
#' @return GGplot2 object.
#'
#' @export

plotTime <- function(csubject, cnts, disp, isco_cats = as.character(1:9)) {
    vals <- c(16,2)
    pisa %>%
        filter(subject == csubject,
               year %in% c("2006", "2009", "2012", "2015"),
               cnt %in% cnts,
               isco %in% c("cnt", isco_cats)) %>% 
        mutate(label = giveLabel(subject, cnt_lab, isco_lab,
				 ave.perf, se, pop.share)) -> sdf
    names(vals) <- unique(c(sdf$cnt_lab[sdf$cnt == cnts[1]], sdf$cnt_lab[sdf$cnt == cnts[2]]))

    ggplot(sdf, aes(x = year, y = ave.perf, shape = cnt_lab,
                    color = isco, group = as.factor(paste0(isco, cnt))), linetype = 2) +
        geom_point_interactive(aes(tooltip = label), size = 1, stroke = 2) +
        theme_tufte(base_size = 8) +
        theme(legend.position = c(0.94, 0.92),
              axis.text.x = element_text(angle = 90),
              #panel.grid.major.y = element_line(linetype = 2, size = 0.5, color = "grey70"),
              panel.grid = element_line(linetype = 2, size = 0.5, color = "grey70")) +
        scale_shape_manual(name = "Country", values = vals) +
        scale_color_manual(values = colors, guide = "none") +
        xlab("Year of study") +
        ylab("Mean performance") +
        facet_grid(~isco, labeller = as_labeller(naming)) -> plt

    if(disp[1])
        plt <- plt + geom_pointrange((aes(ymin = ave.perf - se, ymax = ave.perf + se)), linetype = 2) +
        geom_point_interactive(aes(tooltip = label), size = 1, stroke = 2)
    if(disp[2])
        plt <- plt + geom_line(data = subset(sdf, cnt == cnts[1]), stat = "smooth",
                  linetype = 1, method = "lm", se = F, size = 1, show.legend = F) +
        geom_line(data = subset(sdf, cnt == cnts[2]), stat = "smooth",
                  linetype = 2, alpha = 0.5, method = "lm", se = F, size = 1, show.legend = F)
    plt
}
