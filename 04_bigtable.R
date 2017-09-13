library(readr)
library(dplyr)


users_and_exam_time <- read_csv(
    "data-committed/01_users_and_exam_time.csv",
    col_types = list(
        "user_primary_key_hash" = col_character()
        )
    )

# Make sure that
users_and_exam_time %>% nrow() == 5572
