

CREATE EXTERNAl TABLE 
```
CREATE OR REPLACE EXTERNAL TABLE de-project-datatalksclub.trips_data_all.fhv_tripdata
OPTIONS (
  format = 'csv',
  uris = ['gs://mage-zoomcamp-saki-001/fhv_2019_data/*']
);
```
