# Set up computing environment if not already available locally
!dir.exists("data\\FullIlec.RDS") source("BuildEnviron.R")

# Custom functions for processing lists
source("functions.R")


# Load data into environment
data.ilec <- readRDS("data\\FullIlec.rds") %>%
  mutate(ClassRank = as.numeric(Preferred_Class)/as.numeric(Number_Of_Preferred_Classes))


# Generate model objects for each split
source("paramsModels.R")

# Fit final submission models
params.models %>%
  walk(
    ~buildModel(
      data.ilec %>% 
        filter(!!rlang::parse_expr(paste0(.x$Filter, .x$Criteria))),
      .x$Vars,
      .x$Dummies,,
      label.curr = paste0(.x$String, "FullData"),
      dataBuild = .x$DataFunc,
      trees.use = 10,
      filter.year = 2017
    )
  )
rm(data.ilec)

# Load data grid for creating final predictions
data.grid <- readRDS("data//PredGrid.rds") %>%
  mutate(ClassRank = as.numeric(Preferred_Class)/as.numeric(Number_Of_Preferred_Classes))

# Create final prediction submission
preds.out <- params.models %>%
  map_dfc(
    ~predictGroupedModel(
      data.grid,
      .x$Vars,
      .x$Dummies,
      paste0(.x$String, "FullData"),
      .x$Filter,
      .x$Criteria
    )
  ) %>%
  setNames(params.models %>% map(~.x$String)) %>%
    transmute(SUPred = Select + Ultimate,
           PlanPred = Plan_Other +
             Plan_Perm +
             Plan_Term +
             Plan_UL +
             Plan_ULSG +
             Plan_VL +
             Plan_VLSG,
           EnsemPred = (SUPred + PlanPred)/2) %>%
  cbind(data.grid) %>%
  select(one_of(names(data.grid)),
         Qx = EnsemPred,
         -ClassRank)

write.csv(preds.out, 
          "output//2017PredictionGrid.csv", 
          row.names = F)