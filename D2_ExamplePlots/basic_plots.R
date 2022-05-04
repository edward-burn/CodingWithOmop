# plots needing improvement!

library(fpp3)
library(ggplot2)

# files downloaded from 
# https://github.com/OHDSI/ShinyDeploy/tree/master/UkaTkaSafetyEffectiveness/data
# note after downloading, you will need to change the below paths
preference_score_dist_t8257_c8256 <- readRDS(" ....  /preference_score_dist_t8257_c8256.rds") # add path
covariate_balance_t8257_c8256 <- readRDS(" ....  /covariate_balance_t8257_c8256.rds") # add path

# balance plot -----
table(covariate_balance_t8257_c8256$database_id)
table(covariate_balance_t8257_c8256$analysis_id)
table(covariate_balance_t8257_c8256$target_id)
table(covariate_balance_t8257_c8256$comparator_id)
table(covariate_balance_t8257_c8256$outcome_id)

covariate_balance_t8257_c8256 %>% 
  filter(database_id=="thin") %>% 
  filter(analysis_id=="1") %>% 
  filter(outcome_id=="8208") %>% 
  ggplot() +
  geom_point(aes(abs(std_diff_before), abs(std_diff_after)))+
  xlim(0,1)+
  ylim(0,1)

# preference score plot ----
table(preference_score_dist_t8257_c8256$database_id)
table(preference_score_dist_t8257_c8256$target_id)
table(preference_score_dist_t8257_c8256$comparator_id)

preference_score_dist_t8257_c8256 %>% 
  filter(database_id=="thin") %>%  
  ggplot() +
  geom_area(aes(abs(preference_score), abs(comparator_density)), fill="red", alpha=0.2)+
  geom_area(aes(abs(preference_score), abs(target_density)), alpha=0.6)


# Time series plot -----
# data from 
# https://robjhyndman.com/hyndsight/forecastingdata/
hospital <- monash_forecasting_repository(4656014)
hospital <- hospital %>%
  mutate(month = yearmonth(start_timestamp)) %>%
  as_tsibble(index=month) %>%
  select(-start_timestamp)
table(hospital$series_name)
hospital %>% 
  filter(series_name=="T752") %>% 
  ggplot() +
  geom_point(aes(month, value)) +
  geom_line(aes(month, value))

births <- monash_forecasting_repository(4656049)
births <- births %>%
  mutate(date = start_timestamp) %>%
  as_tsibble(index=date) %>%
  select(-start_timestamp)
table(births$series_name)
births$day_of_week <- weekdays(as.Date(births$date))
births %>% 
  filter(year(date) %in% c(1970)) %>% 
  ggplot() +
  geom_point(aes(date, value, colour=day_of_week)) +
  ylim(0,NA)



