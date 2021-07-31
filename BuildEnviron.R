list.packages("tidyverse",
              "rlang",
              "fastDummies",
              "xgboost")
install.packages(list.packages)


library(tidyverse)



# Create directory structure ####
c("data",
  "models",
  "output") %>%
  walk(dir.create)


# Read in source SOA zip and save relevant variables to RDS ####
path.zip <- "https://cdn-files.soa.org/web/ilec-2016/ilec-data-set.zip"
path.grid <- "https://cdn-files.soa.org/web/ilec-2016/prediction-grid-ilec-2021.zip"

temp <- tempfile()
download.file(path.zip,
              temp)

data.ilec <- read_csv(unz(temp, "ILEC 2009-16 20200123.csv"),
                      col_types = list(
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_double(),
                        col_double(),
                        col_double(),
                        col_character(),
                        col_character(),
                        col_double(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_double(),
                        col_double(),
                        col_double(),
                        col_double()))
saveRDS(data.ilec, "data\\FullIlec.rds", compress = F)

unlink(temp)
rm(data.ilec)


temp <- tempfile()
download.file(path.grid,
              temp)

data.grid <- read_csv(unz(temp, "prediction.grid.ilec.2021.csv"),
                      col_types = list(
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_double(),
                        col_double(),
                        col_double(),
                        col_character(),
                        col_character(),
                        col_double(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character(),
                        col_character()
                        )
)
saveRDS(data.grid, "data\\PredGrid.rds", compress = F)

unlink(temp)
rm(data.grid)