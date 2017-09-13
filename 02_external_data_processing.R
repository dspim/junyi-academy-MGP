
# Not reproducible yet

library(dplyr)
library(data.table)
library(tidyr)
library(magrittr)

options(scipen = 999)
remedy <- read.csv("/Users/xiaopingguo/Downloads/examimport_log_no_city.csv", fileEncoding = "utf8", stringsAsFactors = F)
out <- read.csv("/Users/xiaopingguo/Downloads/外部成績前後測原始資料_20170902.csv", stringsAsFactors = F)
user <- read.csv("/Users/xiaopingguo/Downloads/Info_UserData.csv", fileEncoding = "utf8", stringsAsFactors = F)
####################

names(remedy)
head(remedy)
remedy$user_primary_key_hash <- factor(remedy$user_primary_key_hash) 
levels(remedy$user_primary_key_hash)
remedy %<>% filter(type=="remedial") %>% 
  separate(timestamp, c('date', 'time', 'utc'), sep = ' ') %>% 
  mutate(date_n= paste0(substr(date, 1,4),substr(date, 6,7)) %>% as.numeric())
table(remedy$date)
table(remedy$date_n)

### 學生
remedy %>% group_by(user_primary_key_hash) %>% 
  summarise(n()) %>% View() # 共36091位學生
### 時間 知識點 學生數 同個時期做的測驗包含不同年級的學生（要想辦法分辨）
remedy %>% group_by(date_n) %>% 
  summarise(count = n(),
            p=length(unique(user_primary_key_hash)),
            quiz = count/p) -> time_people

remedy %>% filter(date_n %in% c(201504,201505,201506)) %>% 
  select(user_primary_key_hash, title) %>% 
  unique() %>% 
  intersect(remedy %>% filter(date_n %in% c(201510,201511,201512)) %>% 
              select(user_primary_key_hash, title) %>% unique() ) -> b #139544個點

length(unique(b$title))
length(unique(b$user_primary_key_hash))
unique(b$title)

### 串User_id
user %>% filter(user_primary_key %in% b$user_primary_key_hash, 
                points >= 0)   -> peo

remedy %>% filter(user_primary_key_hash %in% b$user_primary_key_hash) %>% 
  select(status, title) %>% 
  merge()

#############
try <- remedy$date[1]
paste0(substr(try, 1,4),substr(try, 6,7)) %>% as.numeric()
strsplit(try ," ")[[2]][1] %>% unlist() 
regexpr(try[1], " ")

try %<>% separate(timestamp, c('a', 'b', 'c'), sep = ' ') 

try1 <- data.frame(f=c("a","b", "c","d"), b=c("1","2","3","4"))
try2 <- data.frame(f=c("b","c", "d"), b=c("2","4","5"))
intersect(try1, try2)

try1 <- remedy[c(1:20),]
try2 <- remedy[c(10:20),]




