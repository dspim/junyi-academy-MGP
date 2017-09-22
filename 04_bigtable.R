library(readr)
library(dplyr)
library(googledrive)
library(purrr)

# Drive 上的資料
folder <-
    drive_ls(as_id("0B8WvtTLcqtbhZVVkRWIwQmU1Qk0"),
             recursive = T,
             type = "csv")

dir.create("./data/drive_data")
folder %>% rowwise() %>% do(drive_download(
    as_id(.$id),
    path = paste0("./data/drive_data/", .$name),
    overwrite = T
))

read_csv_custom <- function(path)
    read_csv(path, col_types = list("user_primary_key" = col_character()))

bind_col_custom <- function(x, y) full_join(x, y, by="user_primary_key")

files_from_data_committed <- c("data-committed/04_video_out.csv")
files_from_drive <- list.files("data/drive_data" , full.names = T)

files <- c(files_from_data_committed ,  files_from_drive)

full_table <- files %>%
    lapply(read_csv_custom) %>%
    reduce(bind_col_custom)


full_table %>% write_csv("./data-committed/05_big_table.csv")
