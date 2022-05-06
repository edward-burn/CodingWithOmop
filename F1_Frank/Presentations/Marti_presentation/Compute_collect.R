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

genders1 <- age_tab_collected %>% select(gender_concept_id) %>% pull()
genders2 <- age_tab_saved %>% select(gender_concept_id) %>% pull()
genders3 <- age_tab %>% select(gender_concept_id) %>% pull()
