# Operational Data Warehouse System

Operational data in most organizations lives in fragments: separate 
tables, inconsistent formats, no unified logic. This project builds 
a complete data warehouse from the ground up — from schema design 
to ETL pipelines to a BI layer — following the same principles that 
apply in regulated industrial environments: every record traceable, 
every transformation documented.

## What it does

Designs and implements a relational data warehouse for operational 
management. Integrates multiple data sources through ETL processes 
with data quality controls at each stage. Exposes insights through 
a Tableau dashboard layer.

## Stack

`SQL` `MySQL` `Python` `Tableau` `Jupyter`

## Technical decisions

Schema designed as a normalized relational model to ensure data 
consistency and reduce redundancy. Stored procedures automate 
critical business processes, keeping logic close to the data for 
performance and maintainability. Python integration via 
mysql-connector handles programmatic data extraction and bridges 
raw storage with the analytical layer.

Data quality controls implemented at every ETL stage: row count 
validation, referential integrity checks, and consistency 
verification against source data before loading.

## Structure

```
operational-data-warehouse-system/
├── database/
├── python/
├── tableau/
└── README.md
```

## Author

Mónica Venzor · [LinkedIn](https://linkedin.com/in/monicavenzor) · 
[GitHub](https://github.com/MonicaVenzor)
