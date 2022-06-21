#### Connections.R ####

library(dplyr)
install.packages("remotes")
remotes::install_github("OHDSI/Eunomia")
library(Eunomia)
library(RSQLite)
library(DBI)
untar(xzfile(system.file("sqlite", "cdm.tar.xz", package = "Eunomia"), open = "rb"),
      exdir = tempdir())
db <- DBI::dbConnect(RSQLite::SQLite(), paste0(tempdir(),"\\cdm.sqlite"))

cdm_database_schema        <- "main"

person_db               <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".person")))
observation_period_db   <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".observation_period")))
visit_occurrence_db     <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".visit_occurrence")))
condition_occurrence_db <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".condition_occurrence")))
measurement_db          <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".measurement")))
observation_db          <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".observation")))
drug_era_db             <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".drug_era")))
drug_exposure_db        <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".drug_exposure")))
death_db                <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".death")))
care_site_db            <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".CARE_SITE")))
location_db             <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".LOCATION")))
concept_db              <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".CONCEPT")))

person_db
observation_db
drug_era_db

#### Functions_1.R ####

# Lets filter people older than 80 (that were born before 1942)
older80 <- filter(person_db,YEAR_OF_BIRTH<=1942)
older80
# Lets select year of birth and person_id
older80 <- select(filter(person_db,YEAR_OF_BIRTH<=1942),PERSON_ID,YEAR_OF_BIRTH)
older80
# Combine them in an easy code (%>%)
older80 <- person_db %>% filter(YEAR_OF_BIRTH<=1942) %>% select(PERSON_ID,YEAR_OF_BIRTH)
older80

#### Functions_2.R ####

# lets see the different GP identifier
Race <- person_db %>% select(RACE_CONCEPT_ID  )
Race %>% distinct()
# Obtain the unique values for identifiers
Race <- person_db %>% select(RACE_CONCEPT_ID  ) %>% distinct()
Race
# Lets chose these 4 CSI: 20415, 21633, 20866, 21470
age_tab <- person_db %>% mutate(age = 2022 - year_of_birth) %>% filter(age>=80) %>%
  rename(RACE = RACE_CONCEPT_ID) %>% filter(RACE != 0)
age_tab %>% tally()
age_tab %>% group_by(RACE) %>% tally()
age_tab %>% group_by(age) %>% tally()
age_tab %>% group_by(RACE,age) %>% tally()
compute_table <- age_tab %>% group_by(RACE,age) %>% tally()

#### SQL_commands.R ####

# Lets see the SQL commands that are hidden under our R commands
older80 %>% show_query()
Race %>% show_query()
age_tab %>% show_query()
compute_table %>% show_query()

#### Compute_collect.R ####

library(tictoc)

age_tab

tic()
age_tab
toc()

tic()
age_tab_saved <- age_tab %>% compute()
toc()

tic()
age_tab_saved
toc()

nrow(age_tab_saved)

age_tab_collected <- age_tab %>% collect()
age_tab_collected
nrow(age_tab_collected)

genders1 <- age_tab_collected %>% select(GENDER_CONCEPT_ID) %>% pull()
genders2 <- age_tab_saved %>% select(GENDER_CONCEPT_ID) %>% pull()
genders3 <- age_tab %>% select(GENDER_CONCEPT_ID) %>% pull()

#### Joining_tables.R ####

# Lets define two tables we are going to work with
# Table 1: people_db with only the people aged 80 or more
table1 <- person_db %>%
  filter(YEAR_OF_BIRTH==1942) %>%
  select(PERSON_ID,GENDER_CONCEPT_ID,YEAR_OF_BIRTH) %>%
  compute()
table1
# Table 2: death_db with registered deaths between 2010 and 2020
table2 <- condition_occurrence_db %>%
  filter(CONDITION_CONCEPT_ID == 81151) %>%
  select(PERSON_ID,CONDITION_START_DATE) %>%
  group_by(PERSON_ID) %>%
  filter(CONDITION_START_DATE == min(CONDITION_START_DATE)) %>%
  ungroup() %>%
  compute()
table2
# Lets see the elements in each table
table1 %>% tally()
table2 %>% tally()
# Individuals who are in both tables
table1_and_2 <- table1 %>% full_join(table2)
table1_and_2 <- table1 %>% full_join(table2,by="PERSON_ID")
table1 %>% full_join(table2) %>% tally()
table2 %>% full_join(table1) %>% tally()
# Individuals in both tables
table1 %>% inner_join(table2) %>% tally()
table2 %>% inner_join(table1) %>% tally()
# Left join
table1 %>% left_join(table2)
table1 %>% left_join(table2) %>% tally() 
table2 %>% left_join(table1)
table2 %>% left_join(table1) %>% tally()
# Right join
table1 %>% right_join(table2)
table1 %>% right_join(table2) %>% tally() 
table2 %>% right_join(table1)
table2 %>% right_join(table1) %>% tally()
# Anti_join
table1 %>% anti_join(table2)
table1 %>% anti_join(table2) %>% tally()
table2 %>% anti_join(table1)
table2 %>% anti_join(table1) %>% tally()

#### BuildCohortSolution.R ####


