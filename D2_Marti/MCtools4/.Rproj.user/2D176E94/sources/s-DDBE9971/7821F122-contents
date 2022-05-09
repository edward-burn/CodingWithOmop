#' @title Compute survival function
#' @description compute survival function indicating the variable to start
#' follow-up, to end follow-up and the event of interest. We have options to
#' include a maximum time or censor by pairs.
#' @param data tibble that contains all the information
#' @param StartEvent names of the different variables for start event
#' @param OutcomeEvent names of the different variables for outcome event
#' @param CensoringEvent names of the different variables for censor event
#' @param MaximumTime maximum time for censor event
#' @param by_pairs censoring by pairs, default FALSE
#' @param PairsIdentifier identifier for pairs, default pairs_id
#' @param ReducedForm if false the new variables are added to data, if true only
#' IndividualIdentifier is conserved from initial data frame
#' @param IndividualIdentifier identifier for each row
#' @return survival matrix
#' @export ComputeSurvivalMatrix
#' @examples
#' N = 100
#' posibles_dates = as.Date(18628:18648,origin="1970-01-01")
#' dia_entrada = sample(posibles_dates, size = N, replace = TRUE)
#' posibles_dates = as.Date(18658:18700,origin="1970-01-01")
#' dia_ev1 = sample (posibles_dates, size = N, replace = TRUE)
#' dia_ev1[sample(1:N,75)] = NA
#' dia_ev2 = sample (posibles_dates, size = N, replace = TRUE)
#' dia_ev2[sample(1:N,75)] = NA
#' dia_ev3 = sample (posibles_dates, size = N, replace = TRUE)
#' dia_ev3[sample(1:N,75)] = NA
#' dia_censor = sample (posibles_dates, size = N, replace = TRUE)
#' ID = 1:N
#' data_test = tibble::tibble(ID,dia_entrada,dia_censor,dia_ev1,dia_ev2,dia_ev3)
#' ComputeSurvivalMatrix(data_test,"dia_entrada",c("dia_ev1","dia_ev2"),"dia_censor",ReducedForm = TRUE, IndividualIdentifier = "ID")
#'
ComputeSurvivalMatrix <- function(data,StartEvent,OutcomeEvent,CensoringEvent,MaximumTime,by_pairs=FALSE,PairsIdentifier = "pairs_id",ReducedForm=FALSE,IndividualIdentifier = "person_id"){

  # Checkings
  if (!hasArg(data)){stop('argument "data" is missing, with no default')}
  if (!hasArg(StartEvent)){stop('argument "StartEvent" is missing, with no default')}
  if (!hasArg(OutcomeEvent)){stop('argument "OutcomeEvent" is missing, with no default')}
  if (!hasArg(CensoringEvent)){
    names.all <- c(StartEvent,OutcomeEvent)
    if (!hasArg(MaximumTime)){stop('Censoring must be provided: argument "CensoringEvent" or argument "MaximumTime" must be included, with no default')}
  }else{names.all <- c(StartEvent,OutcomeEvent,CensoringEvent)}
  if (ReducedForm == TRUE){names.all <- c(names.all,IndividualIdentifier)}
  if (by_pairs == TRUE){names.all <- c(names.all,PairsIdentifier)}
  if (sum(names.all %in% names(data)) != length(names.all)){
    not.contained <- names.all[!(names.all %in% names(data))]
    str.error <- "Variables:"
    for (k in 1:length(not.contained)){
      str.error <- paste(str.error,not.contained[k])
    }
    str.error <- paste(str.error,"are not contained as variables in data")
    stop(str.error)
  }

  date_start   <- as.numeric(unlist(data[,StartEvent]))

  date_event   <- sapply(data[,OutcomeEvent],as.numeric)
  date_event   <- apply(date_event , 1, min, na.rm = TRUE)
  EventName    <- rep("",length(date_event))
  for (k in 1:length(OutcomeEvent)){
    id <- which(date_event == dplyr::pull(data[,OutcomeEvent[k]]))
    for (i in 1:length(id)){
      if(EventName[id[i]]==""){EventName[id[i]] <- OutcomeEvent[k]}else{EventName[id[i]] <- paste0(EventName[id[i]],"=",OutcomeEvent[k])}
    }
  }
  TimeToEvent  <- date_event - date_start

  # Falta editar maximum time conditions
  date_censor  <- sapply(data[,CensoringEvent],as.numeric)
  date_censor  <- apply(date_censor , 1, min, na.rm = TRUE)
  CensorName   <- rep("",length(date_censor))
  for (k in 1:length(CensoringEvent)){
    id <- which(date_censor == dplyr::pull(data[,CensoringEvent[k]]))
    for (i in 1:length(id)){
      if(CensorName[id[i]]==""){CensorName[id[i]] <- CensoringEvent[k]}else{CensorName[id[i]] <- paste0(CensorName[id[i]],"=",CensoringEvent[k])}
    }
  }
  TimeToCensor <- date_censor - date_start
  if (hasArg(MaximumTime)){TimeToCensor[TimeToCensor>MaximumTime] = MaximumTime}

  # Falta editar pair censoring

  time                      <- apply(cbind(TimeToEvent,TimeToCensor),1,min,na.rm = TRUE)
  status                    <- rep(0,length(time))
  status[time==TimeToEvent] <- 1

  if (ReducedForm == TRUE){
    data_outcome <- data[,IndividualIdentifier]
  } else {
    data_outcome <- data
  }
  data_outcome <- dplyr::mutate(data_outcome,TimeToEvent,EventName,TimeToCensor,CensorName,time,status)

  return(data_outcome)
}
