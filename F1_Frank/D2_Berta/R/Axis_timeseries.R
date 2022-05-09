x.axis_dates <- function(time,start,end, interval) {
  interval1 <- base::paste0(interval," ",time)

  if(time =="year") {
    breaks <- base::seq.Date(from=start, to=end, by =interval1 )
    labels <- "%Y"} else {
      if(time == "month"){
        breaks <- base::seq.Date(from=start, to=end, by =interval1)
        labels <- "%b %Y"
        } else {
            if(time == "week"){
            breaks <- base::seq.Date(from=start, to=end, by =interval1)
            labels <- "%d %b %Y"
            }else {
              if(time == "day"){
              breaks <- base::seq.Date(from=start, to=end, by =interval1)
              labels <- "%d %b %Y"
              }
            }
           }
         }
  ggplot2:: scale_x_date(
  date_labels =labels,
  date_breaks = interval1,
  limits= c(start,
            end)
  )
}
