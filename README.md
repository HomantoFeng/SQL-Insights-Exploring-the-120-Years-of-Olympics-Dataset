# SQL-Insights-Exploring-the-120-Years-of-Olympics-Dataset ![icons8-mysql-logo-48](https://github.com/swaapnaa/SQL-PROJECTS/assets/149737403/95180ab6-019c-4ba1-9165-e9449cb95614)
SQL Insights: Exploring the 120 Years of Olympics Dataset from Kaggle

## Data Preprocessing

Before loading the dataset into MySQL Workbench, I performed some preprocessing in R ([convert_table.rmd](https://github.com/HomantoFeng/SQL-Insights-Exploring-the-120-Years-of-Olympics-Dataset/blob/main/convert_table.Rmd)) to ensure the data was clean and compatible with SQL operations. This step was necessary to address common data inconsistencies and avoid errors during the import process.

### Key Preprocessing Steps:
1. Handling Missing Values:
   * Replaced NA values in columns with NULL to align with SQL's handling of missing data.
2. Cleaning Text Data:
   * Removed any quotes (e.g., William ""Bill"" Abbott Jr. in the Name column) from columns to ensure smooth data ingestion.

## Data Analysis with SQL: Answering Key Questions

### How It Works:
1. The SQL queries, combined into a single file ([SQL_for_Q1-20.sql](https://github.com/HomantoFeng/SQL-Insights-Exploring-the-120-Years-of-Olympics-Dataset/blob/main/SQL_for_Q1-20.sql)), were executed in MySQL Workbench using the cleaned dataset prepared during the preprocessing step.
2. Each query is designed to answer a specific question, with results generated directly in MySQL Workbench for analysis and interpretation.

