# CodingWithOmop Excercices 
# A.2. Write custom code to characterise a cohort

  #'2.1 Installing package Eunomia
  #install.packages("remotes")
  remotes::install_github("OHDSI/CohortMethod")

  #install.packages("Eunomia")
  remotes::install_github("OHDSI/Eunomia")

  #'2.2. Loading package Eunomia and connecting to the data
  library(Eunomia)
  connectionDetails <- getEunomiaConnectionDetails()
  db <- connect(connectionDetails)

  querySql(db, "SELECT COUNT(*) FROM person;") #Total of individuals
  getTableNames(db,databaseSchema = 'main')    #Variables names


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

  person_db %>% select(PERSON_ID, YEAR_OF_BIRTH)
  
  #See which code is for females
  querySql(db, "SELECT GENDER_CONCEPT_ID, GENDER_SOURCE_VALUE, GENDER_SOURCE_CONCEPT_ID FROM person GROUP BY GENDER_CONCEPT_ID ;")
  
  female <- filter(person_db, GENDER_CONCEPT_ID == 8532)
  female %>% tally()
  

  #'2.Z. Disconnect from Eunomia
  disconnect(db)
  