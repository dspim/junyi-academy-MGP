library(tibble)
library(magrittr)
library(dplyr)
library(readr)
library(lubridate)


users_and_exam_time <- read_csv(
    "data-committed/01_users_and_exam_time.csv",
    col_types = list(
        "user_primary_key_hash" = col_character()
    )
) %>% mutate_at(vars(pre_exam, post_exam) , funs(ymd_hms))

users_and_exam_time %>% summary
# pre exam 多在 2015-04-24, post exam 都在 2015-10-30

target_users <- users_and_exam_time$user_primary_key_hash

read_log <- function(row) {
    return(
        row$path %T>%
            message() %>%
            read_csv(
                col_types = list(
                    "log_problem_quiz_id" = col_character(),
                    "log_video_problem_id" = col_character(),
                    "user_primary_key" = col_character()
                )
            ) %>% filter(date <= "2015-10-30",
                         user_primary_key %in% target_users)
    )
}

paths <- list.files("data",
                    pattern = "Log_ProblemHint*",
                    full.names = T) %>%
    data_frame(path = .)


hint_log_df <- paths %>% rowwise() %>% do(read_log(.) ) %>% ungroup()

# Filter out anomalous users here
# hint_log_df %>% count(user_primary_key, exercise , sort = T) %>% View

hint_log_df_fixed <- hint_log_df %>% filter(user_primary_key!="-1020355799362345007")


true_rate <- function(col) sum(col=="true")/length(col)

hint_log_s1 <- hint_log_df_fixed %>% filter(date >="2015-02-24" & date < "2015-04-23")
hint_log_s2 <- hint_log_df_fixed %>% filter(date >="2015-09-01" & date < "2015-10-29")


get_features <- function(data) {
    mean_features <- data %>%
        group_by(user_primary_key) %>%
        summarise_at(vars(total_time_taken, total_attempt_cnt, hint_cnt),
                     funs(mean))
    rate_features <- data %>%
        group_by(user_primary_key) %>%
        summarise_at(
            vars(
                review_mode,
                pretest_mode
            ),
            funs(true_rate)
        )
    count_features <- data %>% count(user_primary_key)
    features_df <-
        mean_features %>%
        full_join(rate_features, by = "user_primary_key") %>%
        full_join(count_features, by = "user_primary_key")
    return(features_df)
}

full_features <- hint_log_df_fixed %>% get_features
s1_features <- hint_log_s1 %>% get_features
s2_features <- hint_log_s2 %>% get_features

hint_features <- s1_features %>%
    full_join(s2_features,
              by = "user_primary_key",
              suffix = c("_s1", "_s2")) %>%
    full_join(full_features,
              by = "user_primary_key",
              suffix = c("", "_full"))

hint_features %>% write_csv("data-committed/03_hint_features.csv")
