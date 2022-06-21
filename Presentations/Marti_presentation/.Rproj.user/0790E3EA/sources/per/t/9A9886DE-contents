# Lets filter people older than 80 (that were born before 1942)
older80 <- filter(person_db,year_of_birth<=1942)
older80
# Lets select year of birth and person_id
older80 <- select(filter(person_db,year_of_birth<=1942),person_id,year_of_birth)
older80
# Combine them in an easy code (%>%)
older80 <- person_db %>% filter(year_of_birth<=1942) %>% select(person_id,year_of_birth)
older80
