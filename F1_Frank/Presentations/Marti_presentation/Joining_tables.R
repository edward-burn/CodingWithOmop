# Lets define two tables we are going to work with
# Table 1: people_db with only the people aged 80 or more
table1 <- person_db %>%
  filter(year_of_birth==1942) %>%
  select(person_id,gender_concept_id,year_of_birth) %>%
  compute()
table1
# Table 2: death_db with registered deaths between 2010 and 2020
table2 <- death_db %>%
  mutate(death_date = year(death_date)) %>%
  filter(death_date>=2010 & death_date<=2020) %>%
  select(person_id,death_date) %>%
  compute()
table2
# Lets see the elements in each table
table1 %>% tally()
table2 %>% tally()
# Individuals who are in both tables
table1_and_2 <- table1 %>% full_join(table2)
table1_and_2 <- table1 %>% full_join(table2,by="person_id")
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
