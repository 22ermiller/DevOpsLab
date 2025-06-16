library(shiny)

log <- log4r::logger()
log4r::info(log, "App Started")

ui <- fluidPage(
  titlePanel("Penguin Mass Predictor"),

  # Model input values
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "bill_length",
        "Bill Length (mm)",
        min = 30,
        max = 60,
        value = 45,
        step = 0.1
      ),
      selectInput(
        "sex",
        "Sex",
        c("Male" = "male", "Female" = "female")
      ),
      selectInput(
        "species",
        "Species",
        c("Adelie", "Chinstrap", "Gentoo")
      ),
      # Get model predictions
      actionButton(
        "predict",
        "Predict"
      )
    ),

    mainPanel(
      h2("Penguin Parameters"),
      verbatimTextOutput("vals"),
      h2("Predicted Penguin Mass (g)"),
      textOutput("pred")
    )
  )
)

server <- function(input, output) {

  vals <- reactive({
  list(
    bill_length_mm = input$bill_length,
    species = input$species,
    sex = input$sex
  )
})

# API call triggered by button click
  result <- eventReactive(input$predict, {
    log4r::info(log, "Prediction Requested")
    url <- "http://localhost:8000/predict"
    res <- httr::GET(url, query = vals())
    if (httr::http_error(res)) {
      log4r::error(log, paste("HTTP Error"))
    } else {
      log4r::info(log, "Prediction Returned")
    }
  httr::content(res, as = "parsed", type = "application/json")
  }, ignoreInit = TRUE)



  output$pred <- renderText({
    paste("Predicted body mass (g):", result()[[1]])
  })
  
  output$vals <- renderPrint(vals())
}

# Run the application
shinyApp(ui = ui, server = server)