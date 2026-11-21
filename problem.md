# Turf Management Database

## Problem Statement

Create and manage a relational database for a turf management system. The database stores information about turfs, customers, staff, bookings, payments, maintenance activities, and customer feedback.

The SQL script creates the database and its tables, defines relationships and constraints, inserts sample records, and demonstrates SQL operations and analytical queries.

## Database Tables

- `turfs`: turf name, sport type, location, capacity, hourly price, and status.
- `customers`: customer details and loyalty points.
- `staff`: staff details, roles, salary, and hire date.
- `bookings`: customer bookings, turf, date, time, hours, amount, and status.
- `payments`: payment amount, mode, date, and payment status.
- `maintenance`: maintenance work, assigned staff, date, cost, and notes.
- `customer_feedback`: booking feedback and rating.

## SQL Concepts Demonstrated

- Database and table creation, alteration, truncation, and deletion
- Data types, primary keys, foreign keys, unique, not-null, default, and check constraints
- INSERT, UPDATE, DELETE, and SELECT
- Filtering, sorting, grouping, and HAVING
- INNER, LEFT, and RIGHT JOIN
- UNION and UNION ALL
- Aggregate, string, date/time, mathematical, NULL-handling, and conditional functions
- Common Table Expressions (CTEs)
- Window functions such as ROW_NUMBER, RANK, DENSE_RANK, LAG, and LEAD
- Window frames and running totals

## Execution

Run `etl.sql` in a MySQL environment. The script creates the `turf_management` database, builds its tables, inserts sample data, and runs demonstration queries.

## Scope Note

This SQL file demonstrates database creation, sample data loading, data modification, and analytical queries. It does not define a separate staging-to-target ETL pipeline or an external source-data import process.
