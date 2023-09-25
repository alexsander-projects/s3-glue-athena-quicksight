# Introduction

 Here we will run ETL jobs with AWS Glue with AWS S3 as source, quering with Athena and visualizing with Amazon Quicksight

### Steps for Glue and Athena

 ![]()
 >dataflow

- First create a S3 bucket and upload the csv file containing the data;

- Create an IAM role with the following policy:

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
        }
    ]
}
```

- Create a AWS glue Database;

![]()

- Create a Glue Crawler:

    - Set a unique name;
    - Set the data source as the `path to the csv file`;
    - Set the IAM role that you created earlier;
    - Set output as the database you created.

![]()

- Now, run the crawler, it will automatically create a table with the schemas;

- You need to edit the schemas for our queries to work, either do it manually or edit the schemas as JSON;
>Set all data types as `string`

- Now head into Athena and start the query editor;

- Select the data catalog and database;

- We will run the following query to get some data:

```sql
SELECT
  "time.month",
  "statistics.minutes delayed.weather",
  "airport.code"
FROM airlines85263014.airline;
```

![]()
>output

### Steps for Quicksight

 ![]()
 >dataflow

- Launch AWS Quicksight and create a New Analysis;

- Select New Dataset and upload your csv file;

- With the analysis created, select the fields on the left and quicksight will show a graph with the data:

![]()