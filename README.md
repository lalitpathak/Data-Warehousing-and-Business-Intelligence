# Data-Warehousing-and-Business-Intelligence

• The objective of the project was to apply theories, methodologies and strategies of Data warehousing.
• Successfully implemented a data warehouse to support business intelligence queries for the airline
  industry with the help of SSIS, SSAS, R, SQL server and Tableau.

## Application of the data warehouse:

• Identification of ratings of the airline and total number passengers travel from airline.
• Sentiment analysis of the customer opinions about the airline.
• Effect of temperature on Passenger traffic from USA to Spain.

## Code Overview 

### Source files 
   Statisa - https://www.statista.com/statistics/802774/monthly-mean-temperature-in-spain/
   Bureau of transportation statistics  - https://www.bts.gov
   Trip advisor - https://www.tripadvisor.ie/Airlines

### Implementation of SSIS & SSAS code and automation through R scripting.

   The Development and Automation of ETL code of project divided into 8 parts:

    1. First part check whether the tables are present into the staging area. Data is truncated from all the staging tables if the              tables are available.
    2. In the Second Step R code is used to Extract the records from the trip advisor. This code is divide into two parts 1st part              extract rating and total number of review information for each airline. Second part of the code is actually extract all the              reviews from the trip advisor and generate .csv file for each airline which contains user id, quote and reviews for the airline.        These files are stored on the local machine. And in next step these files are picked to do the sentimental analysis of the              airline to generate positive, negative and overall sentimental score of the code. Finally this part is merge with the output of          1st part of the code and stored as file on local machine which contains data for the table RAW DATA AIRLINE RATING REVIEWS. This        is completely automated process.
    3. In the Third step of the ETL raw dataset which is manually stored into the lo-cal machine from the Statista is used and performed        cleaning operation and created T ID. This process creates file which contain data for the table [RAW DATA TEMPERATURE].
    4. Three Raw dataset from Bureau of Transportation Statistic are used. Data cleaning operation is performed to check null value in          the dataset. All the dataset are merge into single dataset and records where origin country is US is filter. And single file            stored on local machine which is used as data for the table [RAW DATA AVIATION]. This step used file created in step 4 to create        data file for Raw Data airport table Raw data Airline.
    5. This step 1st check whether dimension tables are present create Dimensiontable if tables are not created initially and load the          data into dimension table from the Staging table Generated from step 1 to 4.
    6. This step is used to create table AIRLINE which contain all the measure value and this table must be populated before loading            data into the fact table.
    7. In this step data in the table AIRLINE is loaded from table RAW DATA AVIATION, RAW DATA AIRLINE RATING AND REVIEWS, RAW DATA            TEMPERATURE. Fact table is loaded from the table airline.In this process cube is automatically deployed to the server through            SSAS.
   
 ### Output_files 
     Folder contains 5 files and used for the staging tables in SQLservers.
     
 ### Reporting Tableau 
     Data warehouse created in Sql Server is Connected Directial to Tableu Software to get the insights.
 ###  Airline_Industry_Data Warehouse.mp4 
      Video Demonstration of Project 
     
