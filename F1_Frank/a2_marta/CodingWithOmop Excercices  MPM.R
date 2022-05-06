# CodingWithOmop Excercices 
# A.2. Write custom code to characterise a cohort

  #'2.1 Installing package Eunomia
  #install.packages("remotes")
  remotes::install_github("OHDSI/CohortMethod")

  #install.packages("Eunomia")
  remotes::install_github("OHDSI/Eunomia")

  #'2.2. Loading package Eunomia and connecting to the data
  library(Eunomia)
  #ohdsi database connector: doesn´t properly support dbplyr (only the ohdsi package)
  #connectionDetails <- getEunomiaConnectionDetails()
  #db <- connect(connectionDetails)
  #querySql(db, "SELECT COUNT(*) FROM person;") #Total of individuals
  #getTableNames(db,databaseSchema = 'main')    #Variables names
  #disconnect(db)

  #dbi connection (non-obvious way, but works with dbplyr) 
  untar(xzfile(system.file("sqlite", "cdm.tar.xz", package = "Eunomia"), open = "rb"),
        exdir =  tempdir())
  db <- DBI::dbConnect(RSQLite::SQLite(), paste0(tempdir(),"\\cdm.sqlite"))

  #'2.3. Create table 1 of characteristics
  library(DBI)
  library(dbplyr)
  library(dplyr)
  library(table1)

  targetDialect              <- "postgresql" 
  cdm_database_schema        <- "main"
  vocabulary_database_schema <- "main"
  results_database_schema    <- "results"
  
  person_db               <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".person")))
  observation_period_db   <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".observation_period")))
  visit_occurrence_db     <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".visit_occurrence")))
  condition_occurrence_db <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".condition_occurrence")))
  measurement_db          <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".measurement")))
  observation_db          <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".observation")))
  drug_era_db             <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".drug_era")))
  drug_exposure_db        <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".drug_exposure")))
  concept_db              <- tbl(db, sql(paste0("SELECT * FROM ",vocabulary_database_schema,".concept")))
  concept_ancestor_db     <- tbl(db, sql(paste0("SELECT * FROM ",vocabulary_database_schema,".concept_ancestor")))
  death_db                <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".death")))
  care_site_db            <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".CARE_SITE")))
  location_db             <- tbl(db, sql(paste0("SELECT * FROM ",cdm_database_schema,".LOCATION")))
  
  person_db
  observation_db
  drug_era_db
  death_db
  concept_db
  concept_ancestor_db
  location_db
  
  #Filter by 50y
  younger50 <- person_db %>% filter(YEAR_OF_BIRTH>=1972) %>% select(PERSON_ID, YEAR_OF_BIRTH)
  younger50 %>% tally()

  #See which code is for females
  #querySql(db, "SELECT GENDER_CONCEPT_ID, GENDER_SOURCE_VALUE, GENDER_SOURCE_CONCEPT_ID FROM person GROUP BY GENDER_CONCEPT_ID ;") #only works with ohdsi connector
  female <- filter(person_db, GENDER_CONCEPT_ID == 8532)
  female %>% tally()
  
  #Create AGE variable
  person_db <- person_db %>% mutate(age = as.numeric(2022 - YEAR_OF_BIRTH)); #person_db %>% select(PERSON_ID,age)
  age = person_db %>% select(age)
  
  #table 1 - collect() option
  person_db_collected <- person_db %>% collect() 
  names(person_db_collected)
  person_db_collected <- person_db_collected %>% mutate(age_cat = cut(age, breaks = c(-1,18,seq(29.999, 89.999, by = 10),150), labels = c('0-18','18-29','30-39','40-49', '50-59', '60-69', '70-79', '80-89', '90+')))
  table1(~  + age + factor(age_cat) + factor(ETHNICITY_SOURCE_VALUE) + factor(RACE_SOURCE_VALUE) | factor(GENDER_SOURCE_VALUE), data= person_db_collected )
  
  #histogram
  person_db_collected$age %>% hist()
  person_db_collected %>% select(age) %>% pull() %>% hist()  #pull creats an array
  
  #Left join to DEATH_DATE from death_db (theory cause Eunomia doesn't have any record within death_db)
  death_rec <- death_db %>% mutate(death_date = year(DEATH_DATE)) %>% select(PERSON_ID,DEATH_DATE) %>% compute()
  person_db %>% left_join(death_rec, by="PERSON_ID")
  
  #'2.Z. Disconnect from Eunomia
  
  