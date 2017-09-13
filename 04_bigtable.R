library(readr)
library(dplyr)


users_and_exam_time <- read_csv(
    "data-committed/01_users_and_exam_time.csv",
    col_types = list(
        "user_primary_key_hash" = col_character()
        )
    )

# 參加考試的 5572 使用者，與前測 後測的日期
users_and_exam_time %>% glimpse()


users_guidelines <- read_csv(
    "data-committed/02_users_guidelines.csv",
    col_types = list("user_primary_key_hash" = col_character())
)

# 參加考試的 5572 使用者，有遇到的分年細目
users_guidelines %>% glimpse()
