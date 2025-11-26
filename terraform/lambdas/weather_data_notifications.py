import json
import boto3
import os

BUCKET_NAME = os.environ.get("BUCKET_NAME")
s3 = boto3.client("s3")

def handler(event, context):
    for record in event.get('Records', []):
        # just take the body as-is
        message = record['body']
        
        # use messageId as filename
        key = f"{record['messageId']}.json"
        
        # upload to S3
        s3.put_object(Bucket=BUCKET_NAME, Key=key, Body=message)
        
        print(f"Saved {record['messageId']} to s3://{BUCKET_NAME}/{key}")
    
    return {"status": "ok"}
