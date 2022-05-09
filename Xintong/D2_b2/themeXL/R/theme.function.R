#' Add elena's theme to ggplot chart
#'
#' This function allows you to add a custom theme to your ggplotgraphics.
#' @text_size style
#' @title_size
#' @examples
#' plot.theme.XL()


library(dplyr)
library(tidyr)
library(ggplot2)

plot.theme.XL <- function(plot,text_size=12,title_size=16,yintercept=1){
  # add reference line
  plot+ggplot2::geom_hline(yintercept=yintercept,colour = gray(1/2), lty = 2) +
    # format
    theme_bw()+
    ggplot2::theme(
      legend.title = element_blank(),
      axis.text=element_text(size=text_size),
      axis.title.y=element_text(size=text_size,face="bold"),
      axis.title.x=element_text(size=text_size),
      strip.text = element_text(size=text_size, face="bold"),
      strip.text.y.left = element_text(angle = 0),
      strip.background = element_rect( fill="#f7f7f7"),
      legend.text=element_text(size=16),
      plot.title = element_text( face = "bold", size = title_size),
      axis.text.y = element_text(hjust = 0),
      legend.position = "none")

}



# demonstration of use

# # create sample data
# set.seed(2022)
#
# df <- data.frame(x =1:12,
#                  estimate =runif(12,0.9,1.2),
#                  L =runif(12,0,1),
#                  U =runif(12,1.01,2),
#                  group=rep(c("A","B","C"),4))
# # plotting
# a <- df %>%
#   ggplot( aes(x= as.character(x),color=group)          ) +
#   geom_point(aes(y=round(estimate,2)))+
#   facet_wrap(~ group ) +
#   geom_linerange(aes(ymin=round(L,2),ymax=round(U,2) ))+
#   coord_flip()
#
# a
# plot.theme.XL(a)
