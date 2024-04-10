
# Data Ingestion


#### What is data loading, or data ingestion?
Data ingestion is the process of extracting data from a producer, transporting it to a convenient environment, and preparing it for usage by normalising it, sometimes cleaning, and adding metadata.

=======================================================
## Extracting Data
### The considerations of extracting data
Most data is stored behind an API

- Sometimes that’s a RESTful api for some business application, returning records of data.
- Sometimes the API returns a secure file path to something like a json or parquet file in a bucket that enables you to grab the data in bulk,
- Sometimes the API is something else (mongo, sql, other databases or applications) and will generally return records as JSON - the most common interchange format.

So here’s what you need to consider on extraction, to prevent the pipelines from breaking, and to keep them running smoothly.

- Hardware limits
- Network limits
- Source api limits: Each source might have some limits such as how many requests you can do per second.

### Streaming in python via generators
To process data in a stream in python, we use generators, which are functions that can return multiple times - by allowing multiple returns, the data can be released as it’s produced, as stream, instead of returning it all at once as a batch.

```
```
=======================================================
## Normalising data
You often hear that data people spend most of their time “cleaning” data. What does this mean?

Let’s look granularly into what people consider data cleaning.

Usually we have 2 parts:

- Normalising data without changing its meaning,
- and filtering data for a use case, which changes its meaning.

### Introducing dlt
dlt is a python library created for the purpose of assisting data engineers to build simpler, faster and more robust pipelines with minimal effort.

You can think of dlt as a loading tool that implements the best practices of data pipelines enabling you to just “use” those best practices in your own pipelines, in a declarative way.
```
# define the connection to load to. 
# We now use duckdb, but you can switch to Bigquery later
pipeline = dlt.pipeline(pipeline_name="taxi_data",
						destination='duckdb', 
						dataset_name='taxi_rides')

# run the pipeline with default settings, and capture the outcome
info = pipeline.run(data, 
                    table_name="users", 
                    write_disposition="replace")

# show the outcome
print(info)
```

=======================================================
## Incremental loading
Incremental loading means that as we update our datasets with the new data, we would only load the new data, as opposed to making a full copy of a source’s data all over again and replacing the old version.

By loading incrementally, our pipelines run faster and cheaper.

### dlt currently supports 2 ways of loading incrementally:
   1. Append
   2. Merge




> [!NOTE]
> the content can refer to here [workshop intro ](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/workshops/dlt_resources/data_ingestion_workshop.md#the-considerations-of-extracting-data)
