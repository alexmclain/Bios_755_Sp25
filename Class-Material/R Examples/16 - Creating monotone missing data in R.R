
library(tidyverse)
library(haven)

read_sas("longproject2.sas7bdat")

dat_count <- dat %>% 
  group_by(AID) %>% 
  mutate(min_count = min(count, na.rm = T), 
         max_count = max(count, na.rm = T)) %>% 
  filter(min_count == 1 & max_count == 4) %>% 
  mutate(BMI = case_when(
    is.na(videogameplaytime) ~ NA_real_,
    TRUE ~ BMI
  ), 
  BMIcat = case_when(
    is.na(videogameplaytime) ~ NA_real_,
    TRUE ~ BMIcat
  ))

dat_mono <- dat_count %>% 
  mutate(lag_bmi = lag(BMI), 
         lag2_bmi = lag(BMI,2), 
         lag3_bmi = lag(BMI,3)) %>% 
  mutate(bmi_mono = case_when(
    count == 2 & is.na(lag_bmi) ~ NA_real_,
    count == 3 & is.na(lag_bmi) ~ NA_real_,
    count == 4 & is.na(lag_bmi) ~ NA_real_,
    count == 3 & is.na(lag2_bmi) ~ NA_real_,
    count == 4 & is.na(lag2_bmi) ~ NA_real_,
    count == 4 & is.na(lag3_bmi) ~ NA_real_,
    TRUE ~ BMI
  ), 
  bmicat_mono = case_when(
    count == 2 & is.na(lag_bmi) ~ NA_real_,
    count == 3 & is.na(lag_bmi) ~ NA_real_,
    count == 4 & is.na(lag_bmi) ~ NA_real_,
    count == 3 & is.na(lag2_bmi) ~ NA_real_,
    count == 4 & is.na(lag2_bmi) ~ NA_real_,
    count == 4 & is.na(lag3_bmi) ~ NA_real_,
    TRUE ~ BMIcat
  )) %>% 
  select(-c("min_count", "max_count", "lag_bmi", "lag2_bmi", "lag3_bmi"))

write_csv(dat_mono, "/Users/mclainfamily/Downloads/longproject2.csv")

