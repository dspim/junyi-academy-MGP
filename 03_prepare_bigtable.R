# Not reproducible ready

library(readr)
library(dplyr)

df <- read_csv("data/list_20170913_jytime.csv", 
               col_types = list(
                   "user_primary_key_hash" = col_character()
               ))

df %>%
    select(user_primary_key_hash, timestamp1, timestamp2) %>%
    unique() %>%
    rename(pre_exam= timestamp1, post_exam = timestamp2) %>%
    write_csv("data-committed/01_users_and_exam_time.csv")
