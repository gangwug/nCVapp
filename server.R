###load 'shiny' package
if (!require(shiny)) {
  install.packages("shiny")
}
##load 'dplyr' package
if (!require(dplyr)) {
  install.packages("dplyr")
  library(dplyr)
}  else  {
  library(dplyr)
}
##load 'tidyr' package
if (!require(tidyr)) {
  install.packages("tidyr")
  library(tidyr)
}  else  {
  library(tidyr)
}
##load 'purrr' package
if (!require(purrr)) {
  install.packages("purrr")
  library(purrr)
}  else  {
  library(purrr)
}
##load 'devtools' package
if (!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}  else  {
  library(devtools)
}
##load 'nCV' package
if (!require(nCV)) {
  devtools::install_github('gangwug/nCV')
  library(nCV)
}  else  {
  library(nCV)
}
### By default, the file size limit is 5MB. It can be changed by
### setting this option. Here we'll raise limit to 300MB.
options(shiny.maxRequestSize = 300*1024^2, stringsAsFactors = FALSE)
### load the example data
exampleD = readRDS("nCVformat.rds")
###set a flag for 'Run' button
runflagA <- runflagB <-0
###uploading file
shinyServer(function(input, output) {
  ## show the example data
  output$example <- renderTable({
    return( head(exampleD) )
  })
  ## show the input datafile
  output$contents <- renderTable({
    ## input$file1 will be NULL initially. After the user selects and uploads a file, 
    ## it will be a data frame with 'name', 'size', 'type', and 'datapath' columns.
    ## The 'datapath' column will contain the local filenames where the data can be found.
    inFile <- input$file1
    if (is.null(inFile)) {
      return(NULL)
    }
    testD <-  read.csv(inFile$datapath)
    if ( ncol(testD) < 2 ) {
      testD <- read.delim(inFile$datapath)
    } 
    return( head(testD) )
  })
  ## do the nCVnet test
  datasetInputA <- reactive({
    ## Change when the "update" button is pressed
    if ( input$updateA > runflagA) {
      isolate({
        withProgress({
          setProgress(message = "Processing corpus...")
          
          inFile <- input$file1
          if (is.null(inFile)) {
            return(NULL)
          }
          testD <-  read.csv(inFile$datapath)
          if ( ncol(testD) < 2 ) {
            testD <- read.delim(inFile$datapath)
          } 
          colnames(testD)[1] = "geneSym"
          rownames(testD) = testD$geneSym
          ##the bench file
          benchFile <- input$file2
          if (is.null(benchFile)) {
            return(NULL)
          }
          benchD <-  read.csv(benchFile$datapath)
          if ( ncol(benchD) < 2 ) {
            benchD <- read.delim(benchFile$datapath)
          } 
          colnames(benchD)[1] = "geneSym"
          rownames(benchD) = benchD$geneSym
          ##get the paramters for nCVnet test
          hsFlag = as.logical(input$hsFlag)
          npermNum = as.numeric(input$npermNum)
          ##run nCVnet test
          nCVnetD = nCVnet(inputD = testD, benchD = benchD, hs = hsFlag, nperm = npermNum, seedN = 10)
        })
      })
      runflagA <- input$updateA
      return(nCVnetD$zstat)
    }  else  {
      return(NULL)
    }
  })
  ## show the nCVnet test results
  output$nCVnetTest <- renderTable({
    taboutA <- datasetInputA()
    head(taboutA)
  })
  ## do the nCVnet test
  datasetInputB <- reactive({
    ## Change when the "update" button is pressed
    if ( input$updateB > runflagB) {
      isolate({
        withProgress({
          setProgress(message = "Processing corpus...")
          inFile <- input$file1
          if (is.null(inFile)) {
            return(NULL)
          }
          testD <-  read.csv(inFile$datapath)
          if ( ncol(testD) < 2 ) {
            testD <- read.delim(inFile$datapath)
          } 
          colnames(testD)[1] = "geneSym"
          rownames(testD) = testD$geneSym
          ##get the clock gene list
          clockGenes = unlist( strsplit(gsub("\\s+", "", input$inputGenes, perl = TRUE), ",", fixed = TRUE) )
          if (length(clockGenes)) {
            nCVgeneD <- nCVgene(inputD = testD, cgenes = clockGenes)
          } else {
            nCVgeneD <- NULL
          }
        })
      })
      runflagB <- input$updateB
      return(nCVgeneD)
    }  else  {
      return(NULL)
    }
  })
  ## show the prediction result
  output$tabout <- renderTable({
    taboutD <- datasetInputB()
    head(taboutD)
  })
  ## downloading file
  output$downloadData <- downloadHandler(
    filename = function() { 
      if (input$fstyle == "txt") {
        paste("nCV", '.txt', sep='') 
      }  else  {
        paste("nCV", '.csv', sep='') 
      }
    },
    content = function(file) {
      if (input$fstyle == "txt") {
        write.table(datasetInputB(), file, quote = FALSE, sep="\t", row.names=FALSE)
      }  else  {
        write.csv(datasetInputB(), file, row.names=FALSE)
      }
    }
  )
})

