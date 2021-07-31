
# Select/Ultimate models only
vars.su <- c("Gender", 
             "Smoker_Status",
             "Duration",
             "Attained_Age"
)

vars.su.dummy <- c("Gender",
                   "Smoker_Status"#,
                   # "Age_Basis"
)


# Insurance_Plan split models
vars.standard <- c("Gender", 
                   "Smoker_Status",
                   "Attained_Age", 
                   "ClassRank",
                   "Duration",
                   "Face_Amount_Band",
                   "SOA_Anticipated_Level_Term_Period",
                   "SOA_Post_level_Term_Indicator",
                   "Select_Ultimate_Indicator"
)



vars.standard.dummy <- c("Gender",
                         "Smoker_Status",
                         "Face_Amount_Band",
                         "SOA_Anticipated_Level_Term_Period",
                         "SOA_Post_level_Term_Indicator",
                         "Select_Ultimate_Indicator"
)

params.standard <- 


# Parameters for group level models
params.models <- list(
  list(String = "Select",
       Vars = vars.su,
       Dummies = vars.su.dummy,
       Filter = "Select_Ultimate_Indicator",
       Criteria = "== \"Select\"",
       DataFunc = buildGroupedData
  ),
  list(String = "Ultimate",
       Vars = vars.su,
       Dummies = vars.su.dummy,
       Filter = "Select_Ultimate_Indicator",
       Criteria = "== \"Ultimate\"",
       DataFunc = buildGroupedData
  )
  
  
)

params.models <- append(params.models,   names(table(data.ilec$Insurance_Plan)) %>%
                           map(~list(String = paste0("Plan_", .x),
                                     Vars = vars.standard,
                                     Dummies = vars.standard.dummy,
                                     Filter = "Insurance_Plan",
                                     Criteria = paste0("== \"", .x, "\""),
                                     DataFunc = buildStandardData)
                           ))
                         

