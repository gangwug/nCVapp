library(shiny)
##uploading file
shinyUI(fluidPage(
  titlePanel(h2("Welcome to nCV") ),
  sidebarLayout(
    
    sidebarPanel(
      fluidRow(
        column(4,
               fileInput('file1', label=h5('Choose input data file'),
                         accept=c('text/csv', 
                                  'text/comma-separated-values,text/plain', '.csv')) ), 
        column(4,
               fileInput('file2', label=h5('Choose reference file'),
                         accept=c('text/csv', 
                                  'text/comma-separated-values,text/plain', '.csv')) ),
        column(4,
               radioButtons('fstyle', label=h5('Files style'),
                            choices=c("csv"='csv', "txt"='txt'),
                            selected='csv', inline=FALSE) )
      ),
      fluidRow(
        column(4,
               radioButtons('hsFlag', label=h5('Human samples'),
                            choices=c("TRUE"=TRUE, "FALSE"=FALSE),
                            selected=TRUE, inline=FALSE) ),
        column(4,
               radioButtons('npermNum', label=h5('nperm'),
                            choices=c("1000"=1000, "10000"=10000, "100000"=100000),
                            selected=1000, inline=FALSE) )
      ),
     br(),
     fluidRow(
       column(3,
              actionButton("updateA", label=h5("Run nCVnet")) )
     ),
     br(),
     fluidRow(
       column(12,
              textInput("inputGenes", label=h5("The clock gene list (10 default clock genes) used to indicate circadian robustness."), value="ARNTL, CLOCK, NPAS2, CRY1, NR1D1, CIART, DBP, PER1, CRY2, PER2") )
     ),
     br(),
     br(),
     fluidRow(
       column(6,
              actionButton("updateB", label=h5("Run nCVgene")) ),
       column(4,
              downloadButton('downloadData', label='Download' ) )
     )
    ),
    
    mainPanel(
      helpText(h4('Starting point: File format') ),
      helpText(h5('The input file contains expression values of all genes from human population (N > 50) samples. The file format should be like below:')),
      tableOutput('example'),
      helpText(h4('Step1: Upload') ),
      helpText(h5('Please take a look at the input data file selected on the left:') ),
      br(),
      tableOutput('contents'),
      ##the temporaly output value for checking the value during running shiny app
      #textOutput('teptext'),
      helpText(h4('Step2: Run nCVnet') ),
      helpText(h5('If the input file is shown as expected, please set parameters on the left and click Run nCVnet button.') ),
      helpText(h4('Step3: Check the p-value from nCVnet test') ),
      tableOutput('nCVnetTest'),
      helpText(h5('If the p-value from nCVnet test is not significant, it is not good to calculate the clock robustness with nCVgene function for this input data.') ),
      helpText(h5('If the p-value from nCVnet test is significant, please type clock gene list on the left and click Run nCVgene button.') ),
      helpText(h4('Step4: Run nCVgene') ),
      helpText(h5('If nCVgene goes well, the nCV values of 6 input genes are shown below:')),
      tableOutput('tabout'),
      helpText(h4('Step5: Download') ),
      helpText(h5('You could download the output results by clicking Download button on the left.'))
    )
  )
))
