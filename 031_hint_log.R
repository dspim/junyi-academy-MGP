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


hint_log_df <- read_csv(
    "data/Log_ProblemHint-000000000003",
    col_types = list(
        "log_problem_quiz_id"=col_character(),
        "log_video_problem_id"=col_character(),
        "user_primary_key" = col_character()
    )
) %>% filter(date <= "2015-10-30") %>%
    mutate(timestamp_TW = ymd_hms(timestamp_TW))

hint_log_df %>% filter(user_primary_key %in% users_and_exam_time$user_primary_key_hash)

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


true_rate <- function(data, of_col, true_false_col){
    of_col <- enquo(of_col)
    true_false_col <- enquo(true_false_col)
    return(
        data %>%
            count(!!of_col,!!true_false_col) %>%
            group_by(!!of_col) %>%
            summarise(rate = sum(n[(!!true_false_col) == "true"]) / sum(n))
    )
}

# 把這樣    
# hint_log_df_fixed %>% count(user_primary_key, is_correct) %>% group_by(user_primary_key) %>% summarise(rate=sum(n[is_correct=="true"])/sum(n))
# 變成這樣
# hint_log_df_fixed %>% true_rate(user_primary_key, is_correct)

hint_log_pre <- hint_log_df_fixed %>% filter(date < "2015-04-24" & date >="2015-01-24")
hint_log_post <- hint_log_df_fixed %>% filter(date < "2015-10-30" & date >="2015-7-30")

get_features <- function(data) data %>%
    group_by(user_primary_key) %>%
    summarise_at(vars(total_time_taken, total_attempt_cnt, hint_cnt), funs(mean))

pre_features <- hint_log_pre %>% get_features
post_features <- hint_log_post %>% get_features


hint_features <- pre_features %>%
    full_join(post_features,
              by = "user_primary_key",
              suffix = c("pre", "post"))

hint_features %>% write_csv("data-committed/03_hint_features.csv")
