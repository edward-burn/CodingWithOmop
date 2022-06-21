# lets see the different GP identifier
GPindentifiers <- person_db %>% select(care_site_id)
GPindentifiers
# Obtain the unique values for identifiers
GPindentifiers <- person_db %>% select(care_site_id) %>% distinct()
GPindentifiers
# Lets chose these 4 CSI: 20415, 21633, 20866, 21470
age_tab <- person_db %>% mutate(age = 2022 - year_of_birth) %>% filter(age>=80) %>%
  rename(GP = care_site_id) %>% filter(GP==20415 | GP==21633 | GP==20866 | GP==21470)
age_tab %>% tally()
age_tab %>% group_by(GP) %>% tally()
age_tab %>% group_by(age) %>% tally()
age_tab %>% group_by(GP,age) %>% tally()
compute_table <- age_tab %>% group_by(GP,age) %>% tally()
