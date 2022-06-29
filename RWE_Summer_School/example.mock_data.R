#### Example using a "mock" database:
# packages -----
library(SqlRender)
library(DatabaseConnector)
library(CohortGenerator)
library(CirceR)
library(FeatureExtraction)
library(here)
library(lubridate)
library(stringr)
library(ggplot2)
library(DBI)
library(dbplyr)
library(dplyr)
library(tidyr)
library(kableExtra)
library(RSQLite)
library(rmarkdown)
library(tableone)
library(scales)
library(forcats)
library(epiR)
library(RPostgreSQL)
library(readxl)
library(lubridate)
library(readxl)
library(dtplyr)
library(duckdb)
devtools::load_all()




# 0. Create a Duckdb mock database directly from R-----
db <- duckdb::dbConnect(duckdb::duckdb(), ":memory:")

person<-tibble(person_id=c("1", "2", "3", "4", "5"),
               gender_concept_id=c("8507","8507", "8532", "8532", "8507"),
               year_of_birth=c(2000,2010, 2003, 2001, 2012),
               month_of_birth=c(01,10,04,06,11),
               day_of_birth=c(01, 01, 01,01,01))

observation_period<-tibble(observation_period_id=c("1","1", "1","1", "1"),
                           person_id=c("1", "2", "3", "4", "5"),
                           observation_period_start_date=c(as.Date("2010-01-01"),as.Date("2010-10-10"), as.Date("2012-01-01"), as.Date("2014-01-01"), as.Date("2012-12-01")),
                           observation_period_end_date=c(as.Date("2010-06-01"),as.Date("2012-12-31"), as.Date("2014-03-01"), as.Date("2015-11-01"), as.Date("2013-02-01")))
outcome<-tibble(cohort_definition_id=c ("1", "1","1", "1"),
                subject_id=c("1","1", "3", "4"),
                cohort_start_date=c(as.Date("2010-02-05"),
                                    as.Date("2010-02-08"),
                                    as.Date("2010-02-20"),
                                    as.Date("2008-02-05")),
                cohort_end_date=c(as.Date("2010-02-05"),
                                  as.Date("2010-02-08"),
                                  as.Date("2010-02-20"),
                                  as.Date("2008-02-05")))

DBI::dbWithTransaction(db, {
  DBI::dbWriteTable(db, "person", person,
                    overwrite = TRUE)
})
DBI::dbWithTransaction(db, {
  DBI::dbWriteTable(db, "observation_period", observation_period,
                    overwrite = TRUE
  )
})
DBI::dbWithTransaction(db, {
  DBI::dbWriteTable(db, "outcome", outcome,
                    overwrite = TRUE
  )
})

# Check how the tables look like
dbReadTable(db, "person")
dbReadTable(db, "observation_period")
dbReadTable(db, "outcome")

rm(person, outcome, observation_period)


# 1. Identify the denominator population-------------
dpop<-collect_denominator_pops(db=db,
                                cdm_database_schema=NULL)
#If we don't specify further specifications, all the population and all the observation time is included
#Default arguments include: age from 0 to 150 years; both sexes; no prior history required.


#Time periods can be specified
dpop_time<-collect_denominator_pops(db=db,
                               cdm_database_schema=NULL,
                               study_start_date= as.Date("2010-01-01"),
                               study_end_date= as.Date("2012-12-31",
                               verbose= FALSE))

#We can add further specifications in terms of age, sex, and prior history requirement.
dpop_option<-collect_denominator_pops(db=db,
                                      cdm_database_schema=NULL,
                                      study_start_date= as.Date("2010-01-01"),
                                      study_end_date= as.Date("2012-12-31"),
                                      study_age_stratas=list(c(10,18)), #List indicating the age groups to be considered
                                      study_sex_stratas=c("Both"),  #Vector with the stratifications in which results are desired
                                      study_days_prior_history =0, #Number of days of prior history required.
                                      verbose= FALSE)

#More than one option for each characteristic is allowed
dpop_mult.options<-collect_denominator_pops(db=db,
                                    cdm_database_schema=NULL,
                                    study_start_date= as.Date("2010-01-01"),
                                    study_end_date= as.Date("2012-12-31"),
                                    study_age_stratas=list(c(10,18), c(10,15)), #List indicating the age groups to be considered
                                    study_sex_stratas=c("Both", "Female", "Male"),  #Vector with the stratifications in which results are desired
                                    study_days_prior_history =c(0,30, 365),#Number of days of prior history required.
                                    verbose=FALSE)


# 2 Calculate incidence rates (IR) based on the denominator population----------
ir<-collect_pop_incidence(db=db, #not working?????
                          results_schema_outcomes=NULL,
                          cohort_ids_outcomes=1,
                          study_denominator_pop=dpop_mult.options,
                          cohort_ids_denominator_pops= c("1"),
                          time_intervals=c("Months"),
                          prior_event_lookbacks = 0,
                          confidence_intervals="exact",
                          repetitive_events = FALSE,
                          verbose= FALSE)






