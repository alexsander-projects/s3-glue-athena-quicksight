# Introduction

Here we will run ETL jobs with AWS Glue with AWS S3 as source, quering with Athena and visualizing with Amazon Quicksight

## Table of Contents

- [Introduction](#introduction)
- [Steps for Glue and Athena](#steps-for-glue-and-athena)
- [Steps for Quicksight](#steps-for-quicksight)

## Steps for Glue and Athena

![](sourceimages/dataflow.png)
>dataflow

- First create a S3 bucket and upload the `airlines.csv` file containing the data.

- Create an IAM role with the following policy (replace `your-bucket-name` with your actual S3 bucket name):

```yaml
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::your-bucket-name/*",
                "arn:aws:s3:::your-bucket-name"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:GetBucketLocation",
            "Resource": "arn:aws:s3:::your-bucket-name"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "glue:GetDatabase",
                "glue:GetDatabases",
                "glue:CreateTable",
                "glue:UpdateTable",
                "glue:GetTable",
                "glue:GetTables",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:CreatePartition",
                "glue:BatchCreatePartition",
                "glue:GetUserDefinedFunctions"
            ],
            "Resource": "*"
        }
    ]
}
```

- Create an AWS Glue Database.

![](sourceimages/database.png)

- Create a Glue Crawler:

    - Set a unique name.
    - Set the data source as the S3 path to the folder containing the `airlines.csv` file (e.g., `s3://your-bucket-name/path/to/folder/`).
    - Set the IAM role that you created earlier.
    - Set output as the database you created.

![](sourceimages/crawler.png)

- Now, run the crawler. It will automatically create a table with the schemas.

- You may need to edit the schemas for your queries to work. A common practice is to ensure data types are appropriate (e.g., strings, numbers, dates). For this specific dataset, initially setting all data types to `string` can be a safe starting point, and you can refine them later.
> Example: Set all data types as `string`.

- Now head into Athena and start the query editor.

- Select the data catalog and database you created.

- We will run the following query to get some data (replace `YOUR_DATABASE` and `YOUR_TABLE` with your actual Glue database and table names):

```sql
SELECT
  "time.month",
  "statistics.minutes delayed.weather",
  "airport.code"
FROM YOUR_DATABASE.YOUR_TABLE
LIMIT 10;
```

![](sourceimages/query.png)
>output

## Steps for Quicksight

![](sourceimages/dataflow2.png)
>dataflow

- Launch AWS Quicksight.
- Create a New Analysis.
- Select "New Dataset".
- Choose Athena as the data source.
    - Give your data source a name (e.g., "AthenaAirlinesData").
    - Select the Glue Catalog, Database, and Table that you created earlier.
- Click "Edit/Preview data" or "Visualize".
- With the analysis created, select the fields on the left, and Quicksight will show a graph with the data.

![](sourceimages/quicksight.png)

