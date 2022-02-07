# Power BI Data Quality Monitor
## What is it?
This Data Quality Monitoring tool aims to help make checking Power BI dataset results simple, repeatable, and automated. It will do this by allowing you to run saved DAX queries against a dataset hosted on the Power BI service to make assertions about the results. 

When developing or maintaining datasets you need to be confident that it returns the correct answer. This typically requires obtaining the result from a measure and manually comparing it to a known result. This is usually done when you initially write the measure. Then you go on to add more functionality to the dataset model and test the next set of measures or structure changes. As you continue with this loop you have more and more functionality to re-test or just assume that it still works. This approach can result in more time to finalize the model or worse, publishing non-working code.

The approach with this tool is to save the test queries along the way, add them to a set of tests with assertions that can be repeatedly executed all at once.   A Power BI report imports those test results to report on the success or failure rate. The query results are saved so that they can be reviewed and compared to determine why there are unexpected results. 

## Current state
Currently this tool is in a Proof-of-Concept phase. I have been using the approach on my projects to generate more ideas, which are logged in the discussion area. As of this writing, the only test assertion supported is that the results between two queries are equal. It has been written with PowerShell functions as a starting point for working out the functionality. 
I welcome anyone who might stumble upon this to use the tool and provide any feedback. I will be slowly letting people know about this tool who could benefit and assist. 

## Future state
The future state will be shaped by any community feedback I received and how useful I find the tool in my projects. I expect that it will grow with additional assertion tests first, then to better automation and maybe refactored into a different language that can provide a more robust user experience. 


# How to get started

Since you made it this far, you have already completed the first step, so you might as well continue the journey! While you are on this GitHub page you should star, watch and fork the repository. 
Prerequisite – You must have the Microsoft Power BI management module installed. You only need to do this once. You can find the command in the Setup-PreRequisites.ps1 file. Then follow the steps below. 

## Setting up the tests
1)	Create a local directory that will be used to hold your test project(s). You can keep all your projects in one directory or keep them separated. 
2)	Copy DataQualityMonitor.psm1 and all the files from the Examples repository directory into the folder created.
3)	Edit each of the files to properly set the directory path '<Your local path>' and project name <ProjectName> and save them.
4)	Run the file named 1-Add-NewProject.ps1. This will setup the folder structure needed by the tool.
5)	Edit the file named 2-Add-Connections.ps1. You will add a connection reference for each dataset you wish to execute queries against. You will need to set a Name and the Dataset Id for each one. You can obtain the id from the service by going to the settings of the dataset. You will then copy the GUID from the end of the URL in your browser. You can setup the connection to your development, test, and production datasets at the same time. It is recommended that you include the workspace name in the connection. Run this script when you are done editing it. 
6)	Add queries to the project query directory. This can be found under the directory with the same name as your project. It is named queries. Please see tips for building queries for more information. 
7)	Edit 3-Add-Test.ps1. You will use the connection names you setup in step 5 and the query file names you saved in step 6. Run this script when you are done editing it.

You can repeat steps 5, 6, or 7 to add more connections, queries, or tests at a later time. 

## Executing tests
The file Invoke-AllTest.ps1 will run all the test defined and save the result, i.e., pass or fail, and the query results as json. You might want to keep this file open in a PowerShell tool to easily run it after each set of changes are published. 

## Reporting Test Results
A Power BI report template, name DQM.pbit, is provided in the repository. When you open it for the first time you will set the file path parameter to the ‘runs’ directory under the project directory. The report will refresh with your results. You can save this file in the directory and refresh each test run. 
## How to compare query results 
The query results are stored for each run in a folder under the ‘runs’ folder. They are named with the test name, followed by ‘qry’ then with the connection and query names. You can use any tool that opens json to view the files. I have found that using Power Query in Excel to be the simplest way to import each file and then merge them together. I then write a custom column to subtract the values and filter out the values that equal zero. 
# Tips for building queries
The simplest way to produce test queries is to use the Performance Analyzer feature in Power BI to capture the DAX code. I recommend using a simple table or matrix visual and apply any filters with slicers or the filter panel. 

The 3rd party tools, DAX Studio and Tabular Editor 3, are great for helping write these queries. Then save them to your query folder. 

I recommend you use the DAX FORMAT() function to ensure the results are consistent. The measure’s defined format is not applied to a DAX query when it is executed. 

I also recommend you use an ORDER BY clause at the end of your query. This will help the equal test be successful. 

# How you can help
Please participate in the discussions area, even if it is simply upvoting ideas that I have logged. I welcome any new ideas, comments, bugs, and constructive feedback. If you find this useful, then please let me and anyone else that could benefit from it know. This will help me prioritize the time I continue to spend on the project. 