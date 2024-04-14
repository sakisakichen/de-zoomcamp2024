
### Q0: CREATE EXTERNAl TABLE & table

```
CREATE OR REPLACE EXTERNAL TABLE de-project-datatalksclub.ny_taxi.external_green_tripdata
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-saki-001/2022_greentaxi_parquet/*']
);
```
```
CREATE OR REPLACE  TABLE de-project-datatalksclub.ny_taxi.materialized_green_tripdata
AS (
SELECT * FROM de-project-datatalksclub.ny_taxi.external_green_tripdata
);
```

### Question 1. What is count of records for the 2022 Green Taxi Data?
```
SELECT count(*)
 FROM `de-project-datatalksclub.ny_taxi.external_green_tripdata`;
```

### Question 2.Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?
```
-- -- 0 Bytes
-- SELECT count(distinct PULocationID) as cnt 
-- from `de-project-datatalksclub.ny_taxi.external_green_tripdata`;

-- 6.41MB
SELECT count(distinct PULocationID) as cnt 
from `de-project-datatalksclub.ny_taxi.materialized_green_tripdata`;
```

### Question 3. How many records have a fare_amount of 0?
```
SELECT count(*) as cnt 
FROM de-project-datatalksclub.ny_taxi.external_green_tripdata
where fare_amount = 0;
```

### Question 4. What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)
```
--Cluster on lpep_pickup_datetime Partition by PUlocationID
CREATE OR REPLACE TABLE de-project-datatalksclub.ny_taxi.partitioned_green_tripdata
PARTITION BY date(lpep_pickup_datetime)
cluster by PULocationID as (
  SELECT * FROM de-project-datatalksclub.ny_taxi.materialized_green_tripdata
)
```
### Question 5. Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive) Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values?
```
SELECT distinct PULocationID 
FROM de-project-datatalksclub.ny_taxi.partitioned_green_tripdata
WHERE lpep_pickup_datetime between '2022-06-01' and '2022-06-30'
```

### Question 6.Where is the data stored in the External Table you created?
GCP Bucket 


### Question 7. It is best practice in Big Query to always cluster your data
False

### Question 8.Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?
0 Bytes , its not reading the data, its counts the metadata,
for the external table, its storages in Bucket, not in big query, so no metadata






