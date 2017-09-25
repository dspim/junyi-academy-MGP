library(readr)
library(dplyr)
library(googledrive)
library(purrr)

# Drive 上的資料
folder <-
    drive_ls(as_id("0B8WvtTLcqtbhZVVkRWIwQmU1Qk0"),
             recursive = T,
             type = "csv")

drive_data_path <- "./data/drive_data"
unlink(drive_data_path, recursive = T)
dir.create(drive_data_path)
folder %>% rowwise() %>% do(drive_download(
    as_id(.$id),
    path = file.path(drive_data_path, .$name),
    overwrite = T
))


users_and_exam_time <- users_and_exam_time <- read_csv(
    "data-committed/01_users_and_exam_time.csv",
    col_types = list(
        "user_primary_key_hash" = col_character()
    )
)


target_users <- users_and_exam_time$user_primary_key_hash
n_users <- length(target_users)


check_and_fix_df <- function(df, path) {
    tryCatch({
        fixed_df <- df %>% filter(user_primary_key %in% target_users)
        if (nrow(fixed_df) < nrow(df))
            message(paste(path, "contains users not in target users"))
        return(fixed_df)
    }, error = function(e) {
        warning(paste("failed to fix", path, e))
    })
}

read_csv_custom <- function(path)
    read_csv(path, col_types = list("user_primary_key" = col_character())) %>%
    check_and_fix_df(path)

bind_col_custom <- function(x, y) full_join(x, y, by="user_primary_key")

files_from_data_committed <- c("data-committed/03_hint_features.csv", "data-committed/04_video_out.csv")
files_from_drive <- list.files("data/drive_data" , full.names = T)

files <- c(files_from_data_committed ,  files_from_drive)

full_table <- files %>%
    lapply(read_csv_custom) %>%
    reduce(bind_col_custom)


full_table %>% write_csv("./data-committed/05_big_table.csv")
