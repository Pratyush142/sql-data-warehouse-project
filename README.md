# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository!
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a 
portfolio project and highlights industry best practices in data engineering and analytics.

---

## Project Requirements

### Building the Data Warehouse (Data Engineering)

### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two sources systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **INtegration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provided clear documentation of the data model to support both business stakeholders and analytics teams.

---
## Data Architecture
<img width="761" height="571" alt="architecture" src="https://github.com/user-attachments/assets/d8d35986-1277-4c71-a190-98c20768fdee" />

1. **Bronze Layer**: Stores raw data as is from the source systems. Data is ingested from CSV Files into SQL Server
     Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare
     data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

### BI: Analytics & Reporting (Data Analytics)

### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behaviour**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key buiness metrics, enabling strategic decision-making.

---

## License

This project is licensed under the [MIT License].(LICENSE). You are free to use, modify, and share this project with proper attribution.

## About Me

Hello, I am Pratyush Kumar Pandey wwith 5+ years of experience as an IT professional.




