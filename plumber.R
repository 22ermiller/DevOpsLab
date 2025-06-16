# plumber.R
library(plumber)

# Load the model
model <- readRDS("penguins_model.rds")

#* Predict body mass
#* @param bill_length_mm numeric
#* @param species character
#* @param sex character
#* @get /predict
function(bill_length_mm, species, sex) {
  input <- data.frame(
    bill_length_mm = as.numeric(bill_length_mm),
    species = species,
    sex = sex
  )
  
  pred <- predict(model, newdata = input)
  list(predicted_body_mass_g = pred[1])
}
