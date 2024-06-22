# Using modelstudio package for explaining models
# Source: https://modelstudio.drwhy.ai/index.html

# load packages
suppressMessages(library(tidyverse))
suppressMessages(library(tidymodels))
library(DALEX)
library(modelStudio)

# load dataset
load('./data/fifa19small.rda')

fifa <- fifa19small |> 
     rename(Reputation = 9) |> 
     remove_rownames() |> 
     column_to_rownames(var = "Name") |> 
     select(-Club, -Overall)

fifa |> 
     glimpse()

# fit a XGBoost model
fit_xgboost <- boost_tree(learn_rate = 0.3) %>%
     set_mode("regression") %>%
     set_engine("xgboost") %>%
     fit(Value.EUR ~ ., data = fifa)

fit_xgboost

# create an explainer object
explainer <- DALEX::explain(
     model = fit_xgboost,
     data  = fifa,
     y     = fifa$Value.EUR,
     label = "XGBoost"
)

# selected observations (rows)
sel_rows <- fifa[1:4, ] # Messi, Ronaldo, Neymar Jr., De Gea (GK)
rownames(sel_rows) <- c("Messi", "Ronaldo", "Neymar", "DeGea")

# modelstudio
modelStudio::modelStudio(explainer, sel_rows)
