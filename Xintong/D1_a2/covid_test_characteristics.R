# PDE group StudyAthon for DARWIN, MAY 03-05, 2022 
# https://github.com/edward-burn/CodingWithOmop 

# Get the number and distribution of covid test for a cohort 

library(DBI)
library(dbplyr)
library(dplyr)
library(RPostgreSQL)
library(SqlRender)
library(here)
library(DatabaseConnector)
library(lubridate)
library(reshape2)
library(tidyr)

#=== CONNECTIONS =========================
# # connection using DatabaseConnector
# connectionDetails <-DatabaseConnector::downloadJdbcDrivers("postgresql", "/home")
# 
# connectionDetails <- DatabaseConnector::createConnectionDetails()
# 
# conn <- DatabaseConnector::connect(connectionDetails)
# #DatabaseConnector::disconnect(conn)

# connection using DBI 
server     <- Sys.getenv("DB_SERVER_cdm_aurum_202106")
server_dbi <- Sys.getenv("DB_SERVER_cdm_aurum_202106_dbi")
user       <- Sys.getenv("DB_USER")
password   <- Sys.getenv("DB_PASSWORD")
port       <- Sys.getenv("DB_PORT") 
host       <- Sys.getenv("DB_HOST") 

db <- DBI::dbConnect(RPostgreSQL::PostgreSQL(),
                dbname = server_dbi,
                port = port,
                host = host, 
                user = user, 
                password = password)

targetDialect              <- "postgresql" 
cdm_database_schema        <- "public"
vocabulary_database_schema <- "public"
results_database_schema    <- "results"

person_db               <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".person")))
observation_period_db   <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".observation_period")))
# visit_occurrence_db     <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".visit_occurrence")))
condition_occurrence_db <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".condition_occurrence")))
measurement_db          <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".measurement")))
observation_db          <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".observation")))
# drug_era_db             <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".drug_era")))
# drug_exposure_db        <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".drug_exposure")))
concept_db              <- tbl(db, sql(paste0("SELECT * FROM ",vocabulary_database_schema,".concept")))
concept_ancestor_db     <- tbl(db, sql(paste0("SELECT * FROM ",vocabulary_database_schema,".concept_ancestor")))
death_db                <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".death")))
# care_site_db            <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".CARE_SITE")))
# location_db             <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".LOCATION")))

person_db


#=== create a cohort of COVID-19 patients =========================
# requirement: 1st Dx of COVID-19 between 2021/03/01 - 2021/03/01
# observed in database > 365 days from index 
covid_dx_id <- c(37311061,4100065,439676,37311060)
cond_start_dt <- as.Date("2021-03-01")
cond_end_dt <- as.Date("2021-03-31")

# elig.covid <- condition_occurrence_db %>% 
#   filter(condition_concept_id %in% covid_dx_id & cond_start_dt<= condition_start_date & condition_start_date <= cond_end_dt) %>%
#   compute()
options(scipen = 999)

elig.covid.0<-condition_occurrence_db  %>% 
  select(person_id, condition_concept_id,condition_start_date )%>% 
  # rename("subject_id"="person_id") %>%
  distinct() %>% 
  filter(condition_concept_id %in% covid_dx_id)  %>% 
  rename("cohort_start_date"="condition_start_date") %>% 
  mutate("cohort_end_date"=cohort_start_date) 

elig.covid.1 <-  elig.covid.0 %>%  
  group_by(person_id) %>% 
  slice_min(cohort_start_date, n = 1) %>%
  filter(cond_start_dt<= cohort_start_date & cohort_start_date <= cond_end_dt)
# %>% compute()

cohort.covid <- elig.covid.1 %>% inner_join(observation_period_db, by="person_id") %>%
  filter(cohort_start_date - observation_period_start_date > 365) %>% 
  inner_join(person_db, by="person_id") 
# %>%   compute()

cohort <-  cohort.covid %>% 
  select(person_id,observation_period_start_date,observation_period_end_date,condition_concept_id , cohort_start_date ,cohort_end_date,
         gender_concept_id, year_of_birth) %>%
  collect()  # THIS TAKES AGES ! ----

saveRDS(cohort, "cohort.RDS")
# cohort <- readRDS( "cohort.RDS")

#=== add characteristics ===========================
# add age -----

cohort$age<- NA
cohort<-cohort %>% 
    mutate(age= year(cohort_start_date)-year_of_birth)


# age age groups ----
cohort<-cohort %>% 
  mutate(age_gr=ifelse(age<20,  "<20",
                       ifelse(age>=20 &  age<=44,  "20-44",
                              ifelse(age>=45 & age<=54,  "45-54",
                                     ifelse(age>=55 & age<=64,  "55-64",
                                            ifelse(age>=65 & age<=74, "65-74", 
                                                   ifelse(age>=75 & age<=84, "75-84",      
                                                          ifelse(age>=85, ">=85",
                                                                 NA)))))))) %>% 
  mutate(age_gr= factor(age_gr, 
                        levels = c("<20","20-44","45-54", "55-64",
                                   "65-74", "75-84",">=85"))) 
table(cohort$age_gr, useNA = "always")

# wider age groups
cohort<-cohort %>% 
  mutate(age_gr2=ifelse(age<=44,  "<=44",
                        ifelse(age>=45 & age<=64,  "45-64",    
                               ifelse(age>=65, ">=65",
                                      NA)))) %>% 
  mutate(age_gr2= factor(age_gr2, 
                         levels = c("<=44", "45-64",">=65")))
table(cohort$age_gr2, useNA = "always")



# add gender -----
#8507 male
#8532 female
cohort<-cohort %>% 
  mutate(gender= ifelse(gender_concept_id==8507, "Male",
                        ifelse(gender_concept_id==8532, "Female", NA ))) %>% 
  mutate(gender= factor(gender, 
                        levels = c("Male", "Female")))
table(cohort$gender, useNA = "always")

# if missing (or unreasonable) age or gender, drop ----
cohort<-cohort %>% 
  filter(!is.na(age)) %>% 
  filter(age>=18) %>% 
  filter(age<=110)

cohort<-cohort %>% 
  filter(!is.na(gender))


# add prior observation time -----
cohort<-cohort %>%  
  mutate(prior_obs_days=as.numeric(difftime(cohort_start_date,
                                            observation_period_start_date,
                                            units="days"))) %>% 
  mutate(prior_obs_years=prior_obs_days/365.25) %>% 
  mutate(after_obs_days=as.numeric(difftime(cohort_start_date,
                                            observation_period_end_date,
                                            units="days"))) 
  

# add covid test history ----
# 756055	Measurement of Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2), domain: measurement. 
covid_test_id <- 756055

cohort.person.ids <- cohort%>%select(person_id) %>% pull()

cov_measure <-  measurement_db %>% 
  select(person_id,measurement_concept_id, measurement_date,value_as_concept_id, value_as_number  )%>% 
  inner_join(concept_ancestor_db %>%
               # all descendents
               filter(ancestor_concept_id == covid_test_id) %>% 
               select(descendant_concept_id) %>% 
               rename("measurement_concept_id"="descendant_concept_id"))%>% 
  filter(measurement_concept_id == covid_test_id)%>% 
  filter(person_id %in% cohort.person.ids)%>% 
  collect()

# saveRDS(cov_measure, "cov_measure.RDS")
# cov_measure <- readRDS( "cov_measure.RDS")

length(unique(cov_measure$person_id))
unique(cov_measure$value_as_concept_id)  #  45878583=neg 45884084=pos 45877986=unknown

cov_measure <- distinct_all(cov_measure)

cov_measure <- cov_measure %>% left_join(cohort,by = "person_id") %>% 
  mutate(ms_days_prior_dx= as.numeric(cohort_start_date - measurement_date))%>%
  mutate(test_time = case_when(ms_days_prior_dx < 0 ~ "after",
                               ms_days_prior_dx == 0 ~  "onDX",
                               0 < ms_days_prior_dx & ms_days_prior_dx <= 7 ~ "1week",
                               8<= ms_days_prior_dx & ms_days_prior_dx < 91 ~ "1w_3mo", 
                               91 <= ms_days_prior_dx & ms_days_prior_dx < 181 ~ "3mo_6mo",
                               181 <= ms_days_prior_dx & ms_days_prior_dx < 270 ~ "6mo_9mo",
                               270 <= ms_days_prior_dx & ms_days_prior_dx < 365 ~ "9mo_12mo",
                               TRUE ~ "12mo_over"))

cov_measure %>% group_by( test_time) %>% count()

test_person <- cov_measure %>% group_by(person_id,test_time) %>% count()
test_person <- test_person %>% dcast(person_id ~ test_time, value.var = "n")
# test_person_tot <-  cov_measure %>% filter(0 < ms_days_prior_dx & ms_days_prior_dx <365) %>%
#   group_by(person_id) %>% count()

test_person <- test_person %>% 
  left_join(cov_measure %>% filter(0 < ms_days_prior_dx & ms_days_prior_dx <365) %>%
              group_by(person_id) %>% count() %>% rename("N_test_bf_dx" = "n")
  , by="person_id")

colMeans(test_person, na.rm=T)

#join back to original covid DX cohort. 

cohort.cov.char <- cohort %>% left_join(test_person, by="person_id")
# assign 0 to NA 
cohort.cov.char <- cohort.cov.char %>% mutate_at(c(16:24), ~replace_na(.,0))

# get means 
colMeans(cohort.cov.char[c(16:24)], na.rm=F)

# #====== not use : create and insert cohort in OHDSI way ============
# # create empty cohorts table
# sql<-SqlRender::readSql(here("CreateCohortTable.sql"))
# sql<-SqlRender::translate(sql, targetDialect = targetDialect)
# DatabaseConnector::renderTranslateExecuteSql(conn=conn, 
#                                              sql,
#                                              cohort_database_schema =  results_database_schema,
#                                              cohort_table = "StudyAthon_table_XL")
# rm(sql)
# 
# # add cohort 
# sql<-readSql(here("COVID19_positive_test.sql")) 
# 
# sql<-SqlRender::translate(sql, targetDialect = targetDialect)
# renderTranslateExecuteSql(conn=conn, 
#                           sql, 
#                           cdm_database_schema = cdm_database_schema,
#                           vocabulary_database_schema = vocabulary_database_schema,
#                           target_database_schema = results_database_schema,
#                           # results_database_schema = results_database_schema,
#                           target_cohort_table = "StudyAthon_table_XL",
#                           target_cohort_id = 1)  
# 
# 
# # link to table
# exposure.cohorts_db<-tbl(db, sql(paste0("SELECT * FROM ",
#                                         results_database_schema,".",
#                                         "StudyAthon_table_XL"))) %>% 
#   mutate(cohort_definition_id=as.integer(cohort_definition_id)) 

