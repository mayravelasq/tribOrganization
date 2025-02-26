if (!require(dplyr)) {install.packages("dplyr")}
if (!require(tidyverse)) {install.packages("tidyverse")}

## MAKING LIST OF FILES IN FOLDER
folder = "C:/Users/mvhfg/OneDrive - University of Missouri/North_Limnology/Data_Organization/Trib/tribOrg/feb28-jun20"
files = list.files(
  path = folder,
  pattern = "_Bethel.*csv$",
  ignore.case = F,
  full.names = T #provides path to folder
)

files2 <- list.files("feb28-jun20", pattern="*.csv")

library(readr)
library(stringr)

for(i in 1:length(files)) {
  file_name <- str_sub(string = files[i], start = -18, end = -1)
  file_df <- read.csv(paste0(folder,"/",files2[i]),header = FALSE, sep=",")
  file_df <- file_df[c(3:2714),2:3] #i only need the col 2&3 and keep rows 2:2714
  cols <- names(file_df)[2] #getting the second column 
  file_df[cols] <- lapply(file_df[cols], as.numeric) #making the cols column(s) numeric
  assign( x = file_name, value = file_df, envir = .GlobalEnv)
}

#join them together next and then rename them by wtr_0.5, 1.0, etc

##JOINING DF TOGETHER
library(plyr)
all_df <- join_all(list(`0.5_m_-_Bethel.csv`,`1.0_m_-_Bethel.csv`,`1.5_m_-_Bethel.csv`,
                        `2.0_m_-_Bethel.csv`,`2.5_m_-_Bethel.csv`), by='V2', type='left')

com_df <- setNames(all_df, c("Date_Time",	"wtr_0.5",	"wtr_1.0",	"wtr_1.5",	"wtr_2.0",	"wtr_2.5"))

## Try to do the yes no columns from og excel : Bethel_HOBOTemp 2022-2023

com_df$Diff_1.5_0.5 <- ifelse(abs(com_df$wtr_1.5 - com_df$wtr_0.5) >=1, "Yes", "No")
com_df$Diff_2.5_1.5 <- ifelse(abs(com_df$wtr_2.5 - com_df$wtr_1.5) >=1, "Yes", "No")
com_df$Diff_2.0_1.0 <- ifelse(abs(com_df$wtr_2.0 - com_df$wtr_1.0) >=1, "Yes", "No")

#next steps: join this df and the og bethel one

## Join bethel_hobotemp data with comdf using rbind

o2023_f2024 <- read.csv("Bethel_HOBOTemp_oct2023-feb2024.csv")

o2023_f2024 <- o2023_f2024%>%
  dplyr::rename("Diff_1.5_0.5" = Diff..1.5.0.5.)%>% 
  dplyr::rename("Diff_2.5_1.5" = Diff..2.5.1.5.)%>% 
  dplyr::rename("Diff_2.0_1.0" = Diff..2.1.)

o2023_f2024 <- o2023_f2024%>%
  drop_na()

o2023_j2024 <- rbind(o2023_f2024,com_df)

#complete!

## Make a New CSV of Bethel Hobo data from October 19, 2023 at 12:00PM to June 20, 2024 at 11:00AM

write.csv(o2023_j2024, "C:/Users/mvhfg/OneDrive - University of Missouri/North_Limnology/
          Data_Organization/Trib/tribOrg/oct2023-jun2024.csv",row.names=FALSE)
