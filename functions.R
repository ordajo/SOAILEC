library(tidyverse)
library(xgboost)
# library(vtreat)
# library(readxl)
library(fastDummies)

hasmorethanone <- function(x) length(unique(x)) > 1


buildGroupedData <- function(x, vars, which.dummy, year.filter = 2016) 
  x %>% 
  filter(Observation_Year < year.filter) %>%
  group_by(Observation_Year, across(one_of(vars))) %>% 
  summarize(Pols = sum(Amount_Exposed),
            Deaths = sum(Death_Claim_Amount),
            Qx = Deaths/Pols) %>%
  filter(!is.na(Qx)) %>%
  ungroup() %>%
  dummy_cols(select_columns = which.dummy,
             remove_first_dummy = T) %>%
  select(where(hasmorethanone),
         -Observation_Year,
         -one_of(which.dummy),
         -Pols,
         -Deaths)

# Lot of repeated code between two blocks.
buildStandardData <- function(x, vars, which.dummy, year.filter = 2016) 
  x %>% 
  filter(Observation_Year < year.filter) %>%
  select(one_of(c(vars, which.dummy)),
         Amount_Exposed, 
         Death_Claim_Amount) %>%
  mutate(Qx = Death_Claim_Amount/Amount_Exposed) %>%
  filter(!is.na(Qx) & !is.infinite(Qx)) %>%
  dummy_cols(select_columns = which.dummy,
             remove_first_dummy = T) %>%
  select(where(hasmorethanone),
         -one_of(which.dummy),
         -Amount_Exposed, 
         -Death_Claim_Amount)


buildModel <- function(data, 
                              vars.group, 
                              vars.dummy,
                              label.curr = "default",
                              dataBuild = buildGroupedData,
                              seed = 123,
                              trees.use = 15,
                       filter.year = 2016) {
  
  data.group <- dataBuild(data, 
                          vars.group, 
                          vars.dummy,
                          year.filter = filter.year)
  
  model.group <- #xgb.cv(
    xgboost(
      data = data.group %>% makeModelData,
      label = data.group %>% makeModelLabel("Qx"),
      nrounds = trees.use,
      seed = seed)#,
  # nrounds = 500,
  # early_stopping_rounds = 3,
  # nfold = 10)
  
  # label.curr <- "AttAge"
  if(!dir.exists(paste0("models\\", label.curr))) 
    dir.create(paste0("models\\", label.curr))
  
  saveRDS(model.group, 
          paste0("models\\",
                 label.curr, 
                 "\\", 
                 label.curr,
                 "Model.rds"))  
  
}


predictGroupedModel <- function(x,
                                vars,
                                which.dummy,
                                label.curr,
                                filter.use,
                                criteria.use) {
  
  rows.clear <- which(
    !eval(
      rlang::parse_expr(
        paste0("x$", 
               filter.use, 
               criteria.use)
      )
    )
  )
  
  
  model <- readRDS(paste0("models\\", label.curr, "\\", label.curr, "Model.rds"))
  preds <- predict(model, 
                   newdata =  x %>%
                     buildPredictionData(vars, which.dummy) %>%
                     select(model$feature_names) %>%
                     makeModelData)
  preds[rows.clear] <- 0
  preds
}


buildPredictionData <- function(x, vars, which.dummy)
  x %>% 
  # filter(Observation_Year == 2016) %>%
  select(one_of(vars)) %>%
  dummy_cols(select_columns = which.dummy,
             remove_first_dummy = T) %>%
  select(-one_of(which.dummy))




# Quick data building functions ####
makeModelData <- function(x) x %>%
  select(-starts_with("Qx"),
         -matches("DeathsEq0"),
         -starts_with("Observation")) %>%
  data.matrix

makeModelLabel <- function(x, response) x %>% 
  select(matches(response)) %>%
  data.matrix

