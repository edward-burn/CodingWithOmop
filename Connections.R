library(DBI)
library(dbplyr)
library(dplyr)

server     <- Sys.getenv("DB_SERVER_cdm_aurum_202106")
server_dbi <- Sys.getenv("DB_SERVER_cdm_aurum_202106_dbi")
user       <- Sys.getenv("DB_USER")
password   <- Sys.getenv("DB_PASSWORD")
port       <- Sys.getenv("DB_PORT") 
host       <- Sys.getenv("DB_HOST") 

db <- dbConnect(RPostgreSQL::PostgreSQL(),
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
